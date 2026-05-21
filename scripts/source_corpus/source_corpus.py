"""Quran source corpus ingestion helpers.

The module parses downloaded provider files and preserves text exactly as it is
received. Tests use tiny fixtures and never fetch live APIs.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, Iterable, List

EXPECTED_SURAH_COUNT = 114
EXPECTED_AYAH_COUNT = 6236


@dataclass(frozen=True)
class ArabicVerse:
    surah: int
    ayah: int
    text: str
    provider: str = "tanzil"
    version: str = "unknown"
    attribution: str = "Tanzil Quran text, user-supplied local file"

    @property
    def verse_key(self) -> str:
        return f"{self.surah}:{self.ayah}"


@dataclass(frozen=True)
class VerseTranslation:
    surah: int
    ayah: int
    language: str
    text: str
    provider: str
    version: str
    attribution: str

    @property
    def verse_key(self) -> str:
        return f"{self.surah}:{self.ayah}"


@dataclass
class MergedVerse:
    verse_key: str
    surah: int
    ayah: int
    arabic_text: str
    translations: Dict[str, str] = field(default_factory=dict)
    metadata: Dict[str, Dict[str, str]] = field(default_factory=dict)

    def to_json(self) -> Dict[str, object]:
        return {
            "verse_key": self.verse_key,
            "surah": self.surah,
            "ayah": self.ayah,
            "arabic_text": self.arabic_text,
            "translations": self.translations,
            "metadata": self.metadata,
            "checksum": checksum_text(self.arabic_text),
        }


def checksum_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def parse_tanzil_lines(
    lines: Iterable[str],
    *,
    provider: str = "tanzil",
    version: str = "unknown",
    attribution: str = "Tanzil Quran text, user-supplied local file",
) -> List[ArabicVerse]:
    verses: List[ArabicVerse] = []
    seen = set()

    for line_number, raw_line in enumerate(lines, start=1):
        line = raw_line.rstrip("\n")
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        parts = line.split("|", 2)
        if len(parts) != 3:
            raise ValueError(f"Invalid Tanzil line {line_number}: expected surah|ayah|text")
        surah = int(parts[0])
        ayah = int(parts[1])
        text = parts[2]
        if not text:
            raise ValueError(f"Missing Arabic text at {surah}:{ayah}")
        key = f"{surah}:{ayah}"
        if key in seen:
            raise ValueError(f"Duplicate verse_key {key}")
        seen.add(key)
        verses.append(
            ArabicVerse(
                surah=surah,
                ayah=ayah,
                text=text,
                provider=provider,
                version=version,
                attribution=attribution,
            )
        )

    return verses


def parse_quranenc_csv(rows: Iterable[str]) -> List[VerseTranslation]:
    reader = csv.DictReader(rows)
    required = {"surah", "ayah", "language", "text", "provider", "version", "attribution"}
    missing = required.difference(reader.fieldnames or [])
    if missing:
        raise ValueError(f"Missing QuranEnc columns: {sorted(missing)}")

    translations: List[VerseTranslation] = []
    for row_number, row in enumerate(reader, start=2):
        text = row["text"]
        if not text:
            raise ValueError(f"Missing translation text at CSV row {row_number}")
        translations.append(
            VerseTranslation(
                surah=int(row["surah"]),
                ayah=int(row["ayah"]),
                language=row["language"],
                text=text,
                provider=row["provider"],
                version=row["version"],
                attribution=row["attribution"],
            )
        )
    return translations


def merge_corpus(
    arabic_verses: Iterable[ArabicVerse],
    translations: Iterable[VerseTranslation],
) -> List[MergedVerse]:
    merged: Dict[str, MergedVerse] = {}

    for verse in arabic_verses:
        if verse.verse_key in merged:
            raise ValueError(f"Duplicate verse_key {verse.verse_key}")
        if not verse.text:
            raise ValueError(f"Missing Arabic text at {verse.verse_key}")
        merged[verse.verse_key] = MergedVerse(
            verse_key=verse.verse_key,
            surah=verse.surah,
            ayah=verse.ayah,
            arabic_text=verse.text,
            metadata={
                "arabic": {
                    "provider": verse.provider,
                    "version": verse.version,
                    "attribution": verse.attribution,
                }
            },
        )

    for translation in translations:
        verse = merged.get(translation.verse_key)
        if verse is None:
            raise ValueError(f"Translation references missing Arabic verse {translation.verse_key}")
        verse.translations[translation.language] = translation.text
        verse.metadata[translation.language] = {
            "provider": translation.provider,
            "version": translation.version,
            "attribution": translation.attribution,
        }

    return sorted(merged.values(), key=lambda item: (item.surah, item.ayah))


def validate_full_corpus(
    verses: Iterable[MergedVerse],
    *,
    expected_surahs: int = EXPECTED_SURAH_COUNT,
    expected_ayahs: int = EXPECTED_AYAH_COUNT,
) -> None:
    verse_list = list(verses)
    surahs = {verse.surah for verse in verse_list}
    if len(surahs) != expected_surahs:
        raise ValueError(f"Expected {expected_surahs} surahs, found {len(surahs)}")
    if len(verse_list) != expected_ayahs:
        raise ValueError(f"Expected {expected_ayahs} ayahs, found {len(verse_list)}")
    for verse in verse_list:
        if not verse.arabic_text:
            raise ValueError(f"Missing Arabic text at {verse.verse_key}")


def write_jsonl(verses: Iterable[MergedVerse], output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", encoding="utf-8") as handle:
        for verse in verses:
            handle.write(json.dumps(verse.to_json(), ensure_ascii=False, sort_keys=True))
            handle.write("\n")


def _read_lines(path: Path) -> List[str]:
    return path.read_text(encoding="utf-8").splitlines()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--tanzil", type=Path, required=True)
    parser.add_argument("--quranenc", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--skip-full-validation", action="store_true")
    args = parser.parse_args()

    arabic = parse_tanzil_lines(_read_lines(args.tanzil))
    translations: List[VerseTranslation] = []
    if args.quranenc:
        translations = parse_quranenc_csv(_read_lines(args.quranenc))
    merged = merge_corpus(arabic, translations)
    if not args.skip_full_validation:
        validate_full_corpus(merged)
    write_jsonl(merged, args.output)


if __name__ == "__main__":
    main()
