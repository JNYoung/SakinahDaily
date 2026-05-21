import unittest

from source_corpus import (
    merge_corpus,
    parse_quranenc_csv,
    parse_tanzil_lines,
    validate_full_corpus,
)


class SourceCorpusTest(unittest.TestCase):
    def test_parse_tanzil_lines(self):
        verses = parse_tanzil_lines(["1|1|بسم الله", "1|2|الحمد لله"])

        self.assertEqual(verses[0].verse_key, "1:1")
        self.assertEqual(verses[1].text, "الحمد لله")

    def test_parse_quranenc_csv(self):
        rows = [
            "surah,ayah,language,text,provider,version,attribution",
            "1,1,en,In the name,quranenc,2024,QuranEnc",
        ]

        translations = parse_quranenc_csv(rows)

        self.assertEqual(translations[0].verse_key, "1:1")
        self.assertEqual(translations[0].language, "en")

    def test_merge_by_verse_key(self):
        arabic = parse_tanzil_lines(["1|1|بسم الله"])
        translations = parse_quranenc_csv(
            [
                "surah,ayah,language,text,provider,version,attribution",
                "1,1,en,In the name,quranenc,2024,QuranEnc",
            ]
        )

        merged = merge_corpus(arabic, translations)

        self.assertEqual(merged[0].translations["en"], "In the name")
        self.assertIn("checksum", merged[0].to_json())

    def test_reject_missing_arabic_text(self):
        with self.assertRaises(ValueError):
            parse_tanzil_lines(["1|1|"])

    def test_reject_duplicate_verse_key(self):
        with self.assertRaises(ValueError):
            parse_tanzil_lines(["1|1|بسم الله", "1|1|بسم الله"])

    def test_full_corpus_validation_count(self):
        merged = merge_corpus(parse_tanzil_lines(["1|1|بسم الله"]), [])

        with self.assertRaises(ValueError):
            validate_full_corpus(merged)

        validate_full_corpus(merged, expected_surahs=1, expected_ayahs=1)


if __name__ == "__main__":
    unittest.main()
