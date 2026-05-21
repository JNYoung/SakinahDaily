# Source Corpus Ingestion

This package parses local Quran source files and writes normalized JSONL. It does not fetch live APIs, generate Quran text, or modify imported source text.

## Supported Inputs

- Tanzil-style Arabic file: `surah|ayah|text`
- QuranEnc-style CSV with columns: `surah`, `ayah`, `language`, `text`, `provider`, `version`, `attribution`

## Example

```sh
python3 scripts/source_corpus/source_corpus.py \
  --tanzil raw/tanzil.txt \
  --quranenc raw/quranenc.csv \
  --output build/quran_verses.jsonl
```

Full-corpus validation expects 114 surahs and 6,236 ayahs.
