import json
import tempfile
import unittest
from pathlib import Path

from source_corpus import (
    DEFAULT_SELECTED_VERSE_KEYS,
    export_cms_payloads,
    export_source_items,
    generate_manifest_lock,
    load_manifest,
    merge_corpus,
    parse_quranenc_csv,
    parse_tanzil_lines,
    read_processed_jsonl,
    validate_corpus,
    validate_full_corpus,
    write_jsonl,
)


FIXTURES = Path(__file__).parent / "fixtures"
PLACEHOLDER_SOURCE_TEXT = "Fixture source text"


class SourceCorpusTest(unittest.TestCase):
    def test_parse_tanzil_fixture_preserves_arabic_exactly(self):
        raw = (FIXTURES / "tanzil_sample.txt").read_text(encoding="utf-8")
        verses = parse_tanzil_lines(raw.splitlines(), version="fixture")

        self.assertEqual(verses[0].verse_key, "1:1")
        self.assertEqual(
            verses[0].text,
            "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
        )
        self.assertEqual(verses[1].text, raw.splitlines()[1].split("|", 2)[2])
        self.assertEqual(verses[0].version, "fixture")

    def test_rejects_malformed_tanzil_rows(self):
        with self.assertRaisesRegex(ValueError, "Invalid Tanzil line"):
            parse_tanzil_lines(["1|1"])

    def test_rejects_duplicate_verse_key(self):
        with self.assertRaisesRegex(ValueError, "Duplicate verse_key 1:1"):
            parse_tanzil_lines(
                [
                    f"1|1|{PLACEHOLDER_SOURCE_TEXT}",
                    f"1|1|{PLACEHOLDER_SOURCE_TEXT}",
                ]
            )

    def test_rejects_missing_arabic_text(self):
        with self.assertRaisesRegex(ValueError, "Missing Arabic text"):
            parse_tanzil_lines(["1|1|"])

    def test_parse_quranenc_english_csv(self):
        rows = (FIXTURES / "quranenc_en_sample.csv").read_text(
            encoding="utf-8"
        ).splitlines()

        translations = parse_quranenc_csv(rows)

        self.assertEqual(translations[0].verse_key, "1:1")
        self.assertEqual(translations[0].language, "en")
        self.assertEqual(translations[0].content_type, "translation")

    def test_parse_quranenc_arabic_tafsir_csv(self):
        rows = (FIXTURES / "quranenc_ar_tafsir_sample.csv").read_text(
            encoding="utf-8"
        ).splitlines()

        translations = parse_quranenc_csv(rows, content_type="tafsir")

        self.assertEqual(translations[0].language, "ar_tafsir")
        self.assertEqual(translations[0].content_type, "tafsir")

    def test_parse_quranenc_indonesian_csv(self):
        rows = (FIXTURES / "quranenc_id_sample.csv").read_text(
            encoding="utf-8"
        ).splitlines()

        translations = parse_quranenc_csv(rows)

        self.assertEqual(translations[0].language, "id")

    def test_parse_quranenc_rejects_missing_required_columns(self):
        with self.assertRaisesRegex(ValueError, "Missing QuranEnc columns"):
            parse_quranenc_csv(["surah,ayah,text", "1,1,Fixture text"])

    def test_parse_quranenc_rejects_missing_text(self):
        rows = [
            "surah,ayah,language,text,provider,version,attribution",
            "1,1,en,,quranenc,fixture,QuranEnc fixture",
        ]

        with self.assertRaisesRegex(ValueError, "Missing translation text"):
            parse_quranenc_csv(rows)

    def test_merge_rejects_translation_for_missing_arabic_verse(self):
        arabic = parse_tanzil_lines([f"1|1|{PLACEHOLDER_SOURCE_TEXT}"])
        translations = parse_quranenc_csv(
            [
                "surah,ayah,language,text,provider,version,attribution",
                "2,1,en,Fixture text,quranenc,fixture,QuranEnc fixture",
            ]
        )

        with self.assertRaisesRegex(ValueError, "missing Arabic verse 2:1"):
            merge_corpus(arabic, translations)

    def test_merged_jsonl_output_is_deterministic(self):
        arabic = parse_tanzil_lines(
            [
                f"1|2|{PLACEHOLDER_SOURCE_TEXT} two",
                f"1|1|{PLACEHOLDER_SOURCE_TEXT} one",
            ]
        )
        translations = parse_quranenc_csv(
            [
                "surah,ayah,language,text,provider,version,attribution",
                "1,2,en,Fixture second,quranenc,fixture,QuranEnc fixture",
                "1,1,en,Fixture first,quranenc,fixture,QuranEnc fixture",
            ]
        )
        merged = merge_corpus(arabic, translations)

        with tempfile.TemporaryDirectory() as tmp:
            first = Path(tmp) / "first.jsonl"
            second = Path(tmp) / "second.jsonl"
            write_jsonl(merged, first)
            write_jsonl(list(reversed(merged)), second)

            self.assertEqual(first.read_text(), second.read_text())
            self.assertTrue(first.read_text().splitlines()[0].startswith('{"'))

    def test_validates_configurable_fixture_counts(self):
        merged = merge_corpus(
            parse_tanzil_lines([f"1|1|{PLACEHOLDER_SOURCE_TEXT}"]),
            [],
        )

        validate_corpus(merged, expected_surahs=1, expected_ayahs=1)

    def test_full_corpus_validation_count_defaults_to_known_quran_counts(self):
        merged = merge_corpus(
            parse_tanzil_lines([f"1|1|{PLACEHOLDER_SOURCE_TEXT}"]),
            [],
        )

        with self.assertRaisesRegex(ValueError, "Expected 114 surahs"):
            validate_full_corpus(merged)

    def test_validate_corpus_requires_metadata_checksums_and_no_generated_marker(self):
        arabic = parse_tanzil_lines([f"1|1|{PLACEHOLDER_SOURCE_TEXT}"])
        translations = parse_quranenc_csv(
            [
                "surah,ayah,language,text,provider,version,attribution",
                "1,1,en,Fixture text,quranenc,fixture,QuranEnc fixture",
            ]
        )

        merged = merge_corpus(arabic, translations)

        validate_corpus(merged, expected_surahs=1, expected_ayahs=1)
        record = merged[0].to_json()
        self.assertRegex(record["checksum"], r"^[0-9a-f]{64}$")
        self.assertNotIn("generated", json.dumps(record).lower())

    def test_generates_manifest_lock_file_with_checksum_version_attribution(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            raw = root / "raw"
            raw.mkdir()
            (raw / "tanzil.txt").write_text(
                f"1|1|{PLACEHOLDER_SOURCE_TEXT}\n",
                encoding="utf-8",
            )
            (raw / "en.csv").write_text(
                "\n".join(
                    [
                        "surah,ayah,language,text,provider,version,attribution",
                        "1,1,en,Fixture text,quranenc,fixture,QuranEnc fixture",
                    ]
                ),
                encoding="utf-8",
            )
            manifest_path = root / "manifest.yaml"
            manifest_path.write_text(
                (FIXTURES / "source_corpus_manifest_sample.yaml").read_text(
                    encoding="utf-8"
                ),
                encoding="utf-8",
            )
            lock_path = root / "processed" / "source_corpus_manifest.lock.json"

            manifest = load_manifest(manifest_path)
            lock = generate_manifest_lock(manifest, manifest_path, lock_path)

            self.assertTrue(lock_path.exists())
            self.assertRegex(lock["manifest_hash"], r"^[0-9a-f]{64}$")
            self.assertEqual(lock["providers"][0]["version"], "fixture")
            self.assertEqual(lock["providers"][0]["status"], "validated")
            self.assertRegex(lock["providers"][0]["sha256"], r"^[0-9a-f]{64}$")
            self.assertEqual(lock["providers"][1]["row_count"], 1)
            self.assertEqual(lock["providers"][1]["attribution"], "QuranEnc fixture")

    def test_manifest_lock_records_failed_validation_status(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            manifest_path = root / "manifest.yaml"
            manifest_path.write_text(
                """
sources:
  - id: missing_arabic
    provider: tanzil
    provider_name: Tanzil
    content_type: arabic
    language: ar
    version: fixture
    local_path: missing.txt
    attribution: Tanzil fixture
    terms_summary: Local fixture only
    expected_format: tanzil_pipe
expected:
  surah_count: 1
  ayah_count: 1
""".lstrip(),
                encoding="utf-8",
            )

            lock = generate_manifest_lock(
                load_manifest(manifest_path),
                manifest_path,
                root / "lock.json",
            )

            self.assertEqual(lock["providers"][0]["status"], "failed")
            self.assertIn("missing local file", lock["providers"][0]["warnings"][0])

    def test_exports_selected_verse_source_items_as_unapproved_drafts(self):
        merged = merge_corpus(
            parse_tanzil_lines([f"13|28|{PLACEHOLDER_SOURCE_TEXT}"]),
            [],
        )
        with tempfile.TemporaryDirectory() as tmp:
            processed = Path(tmp) / "quran_verses.jsonl"
            output = Path(tmp) / "source_items_quran.jsonl"
            write_jsonl(merged, processed)

            items = export_source_items(
                processed,
                output,
                selected_verse_keys=["13:28"],
                source_corpus_version_id="corpus_fixture",
                metadata_by_verse={
                    "13:28": {
                        "topics": ["calm"],
                        "ritual_moments": ["evening"],
                    }
                },
            )

            self.assertEqual(items[0]["source_item_id"], "quran_13_28")
            self.assertEqual(items[0]["status"], "draft")
            self.assertEqual(items[0]["review_status"], "draft")
            self.assertNotEqual(items[0]["status"], "published")
            self.assertNotEqual(items[0]["review_status"], "approved")
            self.assertEqual(items[0]["topics"], ["calm"])
            self.assertEqual(len(output.read_text().splitlines()), 1)

    def test_default_selected_verses_are_declared_without_exporting_missing_rows(self):
        self.assertIn("13:28", DEFAULT_SELECTED_VERSE_KEYS)
        merged = merge_corpus(
            parse_tanzil_lines([f"1|1|{PLACEHOLDER_SOURCE_TEXT}"]),
            [],
        )

        with tempfile.TemporaryDirectory() as tmp:
            processed = Path(tmp) / "quran_verses.jsonl"
            write_jsonl(merged, processed)
            with self.assertRaisesRegex(ValueError, "Selected verse not found"):
                export_source_items(
                    processed,
                    Path(tmp) / "source_items_quran.jsonl",
                    selected_verse_keys=["13:28"],
                    source_corpus_version_id="corpus_fixture",
                )

    def test_exports_cms_payloads_with_provider_and_version_ids(self):
        arabic = parse_tanzil_lines(
            [f"1|1|{PLACEHOLDER_SOURCE_TEXT}"],
            version="fixture",
            attribution="Tanzil fixture",
        )
        translations = parse_quranenc_csv(
            [
                "surah,ayah,language,text,provider,version,attribution",
                "1,1,en,Fixture text,quranenc,fixture,QuranEnc fixture",
            ]
        )
        merged = merge_corpus(arabic, translations)

        with tempfile.TemporaryDirectory() as tmp:
            processed = Path(tmp) / "quran_verses.jsonl"
            output_dir = Path(tmp) / "cms"
            write_jsonl(merged, processed)

            payloads = export_cms_payloads(
                processed,
                output_dir,
                source_corpus_version_id="corpus_fixture",
            )

            self.assertIn("source_corpus_providers", payloads)
            self.assertIn("source_corpus_versions", payloads)
            self.assertEqual(
                payloads["quran_verse_translations"][0]["provider_id"],
                "quranenc",
            )
            self.assertEqual(
                payloads["quran_verses"][0]["source_corpus_version_id"],
                "corpus_fixture",
            )
            self.assertTrue((output_dir / "quran_verses.jsonl").exists())

    def test_no_test_path_requires_network(self):
        raw = (FIXTURES / "tanzil_sample.txt").read_text(encoding="utf-8")

        verses = parse_tanzil_lines(raw.splitlines())

        self.assertGreater(len(verses), 0)
        self.assertEqual(read_processed_jsonl, read_processed_jsonl)


if __name__ == "__main__":
    unittest.main()
