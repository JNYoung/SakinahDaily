"""Quran source corpus ingestion helpers.

The module parses downloaded provider files and preserves text exactly as it is
received. Tests use tiny fixtures and never fetch live APIs.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
from datetime import datetime, timezone
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, Iterable, List, Optional

EXPECTED_SURAH_COUNT = 114
EXPECTED_AYAH_COUNT = 6236
DEFAULT_SELECTED_VERSE_KEYS = [
    "13:28",
    "20:25",
    "20:26",
    "94:5",
    "14:7",
    "71:10",
    "2:153",
    "65:3",
    "20:114",
    "17:24",
    "39:53",
    "48:4",
]
GENERATED_SOURCE_MARKERS = ("generated quran", "machine-translated", "ai-generated")


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
    content_type: str = "translation"

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


def checksum_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


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
        try:
            surah = int(parts[0])
            ayah = int(parts[1])
        except ValueError as error:
            raise ValueError(f"Invalid Tanzil line {line_number}: surah and ayah must be integers") from error
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


def parse_quranenc_csv(
    rows: Iterable[str],
    *,
    content_type: str = "translation",
) -> List[VerseTranslation]:
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
                content_type=content_type,
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
            "content_type": translation.content_type,
        }

    return sorted(merged.values(), key=lambda item: (item.surah, item.ayah))


def validate_corpus(
    verses: Iterable[MergedVerse],
    *,
    expected_surahs: int = EXPECTED_SURAH_COUNT,
    expected_ayahs: int = EXPECTED_AYAH_COUNT,
) -> None:
    verse_list = list(verses)
    surahs = {verse.surah for verse in verse_list}
    seen = set()
    if len(surahs) != expected_surahs:
        raise ValueError(f"Expected {expected_surahs} surahs, found {len(surahs)}")
    if len(verse_list) != expected_ayahs:
        raise ValueError(f"Expected {expected_ayahs} ayahs, found {len(verse_list)}")
    for verse in verse_list:
        if verse.verse_key in seen:
            raise ValueError(f"Duplicate verse_key {verse.verse_key}")
        seen.add(verse.verse_key)
        if not verse.arabic_text:
            raise ValueError(f"Missing Arabic text at {verse.verse_key}")
        record = verse.to_json()
        if not record["checksum"]:
            raise ValueError(f"Missing checksum at {verse.verse_key}")
        metadata = verse.metadata.get("arabic")
        if not _metadata_complete(metadata):
            raise ValueError(f"Missing Arabic provider metadata at {verse.verse_key}")
        for language in verse.translations:
            if not _metadata_complete(verse.metadata.get(language)):
                raise ValueError(
                    f"Missing {language} provider metadata at {verse.verse_key}"
                )
        encoded = json.dumps(record, ensure_ascii=False).lower()
        if any(marker in encoded for marker in GENERATED_SOURCE_MARKERS):
            raise ValueError(f"Generated-source marker found at {verse.verse_key}")


def validate_full_corpus(
    verses: Iterable[MergedVerse],
    *,
    expected_surahs: int = EXPECTED_SURAH_COUNT,
    expected_ayahs: int = EXPECTED_AYAH_COUNT,
) -> None:
    validate_corpus(
        verses,
        expected_surahs=expected_surahs,
        expected_ayahs=expected_ayahs,
    )


def _metadata_complete(metadata: Optional[Dict[str, str]]) -> bool:
    if not metadata:
        return False
    return all(metadata.get(key) for key in ("provider", "version", "attribution"))


def write_jsonl(verses: Iterable[MergedVerse], output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", encoding="utf-8") as handle:
        for verse in sorted(verses, key=lambda item: (item.surah, item.ayah)):
            handle.write(json.dumps(verse.to_json(), ensure_ascii=False, sort_keys=True))
            handle.write("\n")


def read_processed_jsonl(path: Path) -> List[Dict[str, object]]:
    records = []
    with path.open(encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, start=1):
            if not line.strip():
                continue
            try:
                records.append(json.loads(line))
            except json.JSONDecodeError as error:
                raise ValueError(f"Invalid JSONL at line {line_number}") from error
    return records


def load_manifest(path: Path) -> Dict[str, object]:
    manifest = _parse_simple_yaml(path.read_text(encoding="utf-8"))
    manifest["_path"] = str(path)
    if "sources" not in manifest:
        manifest["sources"] = _sources_from_legacy_manifest(manifest)
    return manifest


def _sources_from_legacy_manifest(manifest: Dict[str, object]) -> List[Dict[str, object]]:
    providers = manifest.get("providers", {})
    if not isinstance(providers, dict):
        return []
    sources = []
    for provider_id, details in providers.items():
        if not isinstance(details, dict):
            continue
        sources.append(
            {
                "id": provider_id,
                "provider": provider_id,
                "provider_name": provider_id,
                "content_type": "arabic" if provider_id == "tanzil" else "translation",
                "language": "ar" if provider_id == "tanzil" else "en",
                "version": details.get("version", "unknown"),
                "local_path": details.get("local_path", ""),
                "attribution": details.get("attribution", ""),
                "terms_summary": details.get("terms_summary", ""),
                "expected_format": details.get("format", ""),
                "required": details.get("required", False),
            }
        )
    return sources


def _parse_simple_yaml(raw: str) -> Dict[str, object]:
    result: Dict[str, object] = {}
    current_key: Optional[str] = None
    current_item: Optional[Dict[str, object]] = None
    for raw_line in raw.splitlines():
        if not raw_line.strip() or raw_line.lstrip().startswith("#"):
            continue
        indent = len(raw_line) - len(raw_line.lstrip(" "))
        line = raw_line.strip()
        if indent == 0 and line.endswith(":"):
            current_key = line[:-1]
            result[current_key] = [] if current_key == "sources" else {}
            current_item = None
            continue
        if current_key == "sources":
            if line.startswith("- "):
                current_item = {}
                result["sources"].append(current_item)  # type: ignore[index, union-attr]
                remainder = line[2:]
                if remainder:
                    key, value = _split_yaml_pair(remainder)
                    current_item[key] = value
            elif current_item is not None:
                key, value = _split_yaml_pair(line)
                current_item[key] = value
            continue
        if current_key and isinstance(result.get(current_key), dict):
            key, value = _split_yaml_pair(line)
            result[current_key][key] = value  # type: ignore[index]
    return result


def _split_yaml_pair(line: str) -> tuple[str, object]:
    if ":" not in line:
        raise ValueError(f"Invalid manifest line: {line}")
    key, value = line.split(":", 1)
    return key.strip(), _parse_yaml_scalar(value.strip())


def _parse_yaml_scalar(value: str) -> object:
    if not value:
        return ""
    if (value.startswith('"') and value.endswith('"')) or (
        value.startswith("'") and value.endswith("'")
    ):
        return value[1:-1]
    lowered = value.lower()
    if lowered == "true":
        return True
    if lowered == "false":
        return False
    try:
        return int(value)
    except ValueError:
        return value


def generate_manifest_lock(
    manifest: Dict[str, object],
    manifest_path: Path,
    lock_path: Path,
) -> Dict[str, object]:
    manifest_hash = checksum_file(manifest_path)
    base_dir = manifest_path.parent
    providers = []
    for source in manifest.get("sources", []):
        if not isinstance(source, dict):
            continue
        providers.append(_lock_entry_for_source(source, base_dir))
    lock = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "manifest_hash": manifest_hash,
        "providers": providers,
    }
    lock_path.parent.mkdir(parents=True, exist_ok=True)
    lock_path.write_text(
        json.dumps(lock, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    return lock


def _lock_entry_for_source(source: Dict[str, object], base_dir: Path) -> Dict[str, object]:
    local_path = str(source.get("local_path", ""))
    path = Path(local_path)
    if not path.is_absolute():
        path = base_dir / path
    entry = {
        "id": source.get("id", ""),
        "provider": source.get("provider", ""),
        "provider_name": source.get("provider_name", ""),
        "content_type": source.get("content_type", ""),
        "language": source.get("language", ""),
        "version": source.get("version", ""),
        "local_path": local_path,
        "attribution": source.get("attribution", ""),
        "terms_summary": source.get("terms_summary", ""),
        "expected_format": source.get("expected_format", ""),
        "sha256": "",
        "row_count": 0,
        "verse_count": 0,
        "status": "failed",
        "warnings": [],
    }
    if not path.exists():
        entry["warnings"].append(f"missing local file: {local_path}")  # type: ignore[index, union-attr]
        return entry
    try:
        entry["sha256"] = checksum_file(path)
        if source.get("content_type") == "arabic":
            verses = parse_tanzil_lines(
                _read_lines(path),
                provider=str(source.get("provider", "tanzil")),
                version=str(source.get("version", "unknown")),
                attribution=str(source.get("attribution", "")),
            )
            entry["verse_count"] = len(verses)
            entry["row_count"] = len(verses)
        else:
            rows = parse_quranenc_csv(
                _read_lines(path),
                content_type=str(source.get("content_type", "translation")),
            )
            entry["row_count"] = len(rows)
        if not _source_metadata_complete(source):
            entry["warnings"].append("missing provider/version/attribution metadata")  # type: ignore[index, union-attr]
        entry["status"] = "validated" if not entry["warnings"] else "failed"
    except ValueError as error:
        entry["warnings"].append(str(error))  # type: ignore[index, union-attr]
    return entry


def _source_metadata_complete(source: Dict[str, object]) -> bool:
    return all(source.get(key) for key in ("provider", "version", "attribution"))


def ingest_manifest(manifest: Dict[str, object], manifest_path: Path) -> List[MergedVerse]:
    base_dir = manifest_path.parent
    arabic: List[ArabicVerse] = []
    translations: List[VerseTranslation] = []
    missing = []
    for source in manifest.get("sources", []):
        if not isinstance(source, dict):
            continue
        local_path = Path(str(source.get("local_path", "")))
        if not local_path.is_absolute():
            local_path = base_dir / local_path
        if not local_path.exists():
            missing.append(str(source.get("local_path", "")))
            continue
        if source.get("content_type") == "arabic":
            arabic.extend(
                parse_tanzil_lines(
                    _read_lines(local_path),
                    provider=str(source.get("provider", "tanzil")),
                    version=str(source.get("version", "unknown")),
                    attribution=str(source.get("attribution", "")),
                )
            )
        else:
            translations.extend(
                parse_quranenc_csv(
                    _read_lines(local_path),
                    content_type=str(source.get("content_type", "translation")),
                )
            )
    if missing:
        raise FileNotFoundError(f"Missing source corpus local files: {', '.join(missing)}")
    merged = merge_corpus(arabic, translations)
    expected = manifest.get("expected", {})
    if isinstance(expected, dict):
        validate_corpus(
            merged,
            expected_surahs=int(expected.get("surah_count", EXPECTED_SURAH_COUNT)),
            expected_ayahs=int(expected.get("ayah_count", EXPECTED_AYAH_COUNT)),
        )
    return merged


def export_source_items(
    processed_jsonl: Path,
    output_path: Path,
    *,
    selected_verse_keys: Iterable[str] = DEFAULT_SELECTED_VERSE_KEYS,
    source_corpus_version_id: str,
    metadata_by_verse: Optional[Dict[str, Dict[str, List[str]]]] = None,
) -> List[Dict[str, object]]:
    records_by_key = {record["verse_key"]: record for record in read_processed_jsonl(processed_jsonl)}
    items = []
    for verse_key in selected_verse_keys:
        record = records_by_key.get(verse_key)
        if record is None:
            raise ValueError(f"Selected verse not found in processed corpus: {verse_key}")
        extra = (metadata_by_verse or {}).get(verse_key, {})
        source_item = {
            "source_item_id": f"quran_{verse_key.replace(':', '_')}",
            "source_type": "quran_ayah",
            "verse_key": verse_key,
            "canonical_ref": f"Quran {verse_key}",
            "arabic_excerpt": record["arabic_text"],
            "topics": extra.get("topics", []),
            "ritual_moments": extra.get("ritual_moments", []),
            "source_corpus_version_id": source_corpus_version_id,
            "status": "draft",
            "review_status": "draft",
        }
        items.append(source_item)
    _write_dict_jsonl(items, output_path)
    return items


def export_cms_payloads(
    processed_jsonl: Path,
    output_dir: Path,
    *,
    source_corpus_version_id: str,
) -> Dict[str, List[Dict[str, object]]]:
    records = read_processed_jsonl(processed_jsonl)
    providers: Dict[str, Dict[str, object]] = {}
    versions: Dict[str, Dict[str, object]] = {}
    verses = []
    verse_translations = []
    verse_tafsirs = []
    for record in records:
        metadata = record.get("metadata", {})
        if not isinstance(metadata, dict):
            metadata = {}
        arabic_meta = metadata.get("arabic", {})
        provider_id = str(arabic_meta.get("provider", ""))
        _collect_provider(providers, provider_id, arabic_meta)
        _collect_version(versions, source_corpus_version_id, provider_id, arabic_meta)
        verses.append(
            {
                "verse_key": record["verse_key"],
                "surah": record["surah"],
                "ayah": record["ayah"],
                "arabic_text": record["arabic_text"],
                "provider_id": provider_id,
                "source_corpus_version_id": source_corpus_version_id,
                "checksum": record["checksum"],
            }
        )
        translations = record.get("translations", {})
        if not isinstance(translations, dict):
            continue
        for language, text in translations.items():
            meta = metadata.get(language, {})
            translation_provider_id = str(meta.get("provider", ""))
            _collect_provider(providers, translation_provider_id, meta)
            _collect_version(
                versions,
                f"{source_corpus_version_id}_{language}",
                translation_provider_id,
                meta,
            )
            row = {
                "verse_key": record["verse_key"],
                "language": language,
                "text": text,
                "provider_id": translation_provider_id,
                "source_corpus_version_id": f"{source_corpus_version_id}_{language}",
                "attribution": meta.get("attribution", ""),
            }
            if meta.get("content_type") == "tafsir" or language.endswith("_tafsir"):
                verse_tafsirs.append(row)
            else:
                verse_translations.append(row)
    payloads = {
        "source_corpus_providers": sorted(providers.values(), key=lambda row: row["provider_id"]),
        "source_corpus_versions": sorted(versions.values(), key=lambda row: row["source_corpus_version_id"]),
        "quran_verses": verses,
        "quran_verse_translations": verse_translations,
        "quran_verse_tafsirs": verse_tafsirs,
    }
    output_dir.mkdir(parents=True, exist_ok=True)
    for name, rows in payloads.items():
        _write_dict_jsonl(rows, output_dir / f"{name}.jsonl")
    return payloads


def _collect_provider(
    providers: Dict[str, Dict[str, object]],
    provider_id: str,
    metadata: Dict[str, object],
) -> None:
    if provider_id and provider_id not in providers:
        providers[provider_id] = {
            "provider_id": provider_id,
            "provider_name": provider_id,
            "attribution": metadata.get("attribution", ""),
        }


def _collect_version(
    versions: Dict[str, Dict[str, object]],
    version_id: str,
    provider_id: str,
    metadata: Dict[str, object],
) -> None:
    if version_id and version_id not in versions:
        versions[version_id] = {
            "source_corpus_version_id": version_id,
            "provider_id": provider_id,
            "version": metadata.get("version", ""),
            "attribution": metadata.get("attribution", ""),
        }


def _write_dict_jsonl(rows: Iterable[Dict[str, object]], output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", encoding="utf-8") as handle:
        for row in rows:
            handle.write(json.dumps(row, ensure_ascii=False, sort_keys=True))
            handle.write("\n")


def _read_lines(path: Path) -> List[str]:
    return path.read_text(encoding="utf-8").splitlines()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path)
    parser.add_argument("--tanzil", type=Path)
    parser.add_argument("--quranenc", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--lock-file", type=Path)
    parser.add_argument("--skip-full-validation", action="store_true")
    args = parser.parse_args()

    if args.manifest:
        manifest = load_manifest(args.manifest)
        merged = ingest_manifest(manifest, args.manifest)
        if args.lock_file:
            lock = generate_manifest_lock(manifest, args.manifest, args.lock_file)
            failed = [entry for entry in lock["providers"] if entry["status"] != "validated"]
            if failed:
                raise SystemExit(f"Manifest validation failed for {len(failed)} source file(s)")
    else:
        if not args.tanzil:
            parser.error("--tanzil is required when --manifest is not provided")
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
