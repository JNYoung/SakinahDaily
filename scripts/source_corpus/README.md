# Source Corpus Ingestion

This package parses local Quran source files and writes normalized JSONL. It does not fetch live APIs, generate Quran text, machine-translate meanings, or modify imported source text.

## Raw Files

Place user-supplied provider files under ignored local paths such as:

- `data/source/raw/tanzil/quran-simple-clean.txt`
- `data/source/raw/quranenc/en.csv`
- `data/source/raw/quranenc/ar_tafsir.csv`
- `data/source/raw/quranenc/id.csv`

Do not commit full Quran corpus files, licensed audio, secrets, production CMS config, or generated production `quran_verses.jsonl` unless the project explicitly asks for that later.

## Manifest Ingestion

```sh
python3 scripts/source_corpus/source_corpus.py \
  --manifest docs/content/source_corpus_manifest.yaml \
  --output data/source/processed/quran_verses.jsonl \
  --lock-file data/source/processed/source_corpus_manifest.lock.json
```

The lock file records manifest hash, local path, SHA-256 checksum, row or verse counts, provider, version, attribution, validation status, and warnings.

## Legacy CLI

```sh
python3 scripts/source_corpus/source_corpus.py \
  --tanzil raw/tanzil.txt \
  --quranenc raw/quranenc.csv \
  --output build/quran_verses.jsonl
```

Full-corpus validation expects 114 surahs and 6,236 ayahs by default. Fixture tests may pass smaller `expected_surahs` and `expected_ayahs`.

## Source Items

Use `export_source_items` from `source_corpus.py` or the helper CLI to create `source_items_quran.jsonl` for selected verse keys.

```sh
python3 scripts/source_corpus/export_source_items.py \
  --processed data/source/processed/quran_verses.jsonl \
  --output data/source/processed/source_items_quran.jsonl \
  --source-corpus-version-id quran_source_local_001 \
  --verse-key 13:28
```

Exports default to `status=draft` and `review_status=draft`; they never auto-approve or auto-publish and only include topics or ritual moments explicitly passed by metadata.

## CMS Payloads

Use `export_cms_payloads` or the helper CLI:

```sh
python3 scripts/source_corpus/export_cms_payloads.py \
  --processed data/source/processed/quran_verses.jsonl \
  --output-dir data/source/processed/cms \
  --source-corpus-version-id quran_source_local_001
```

The exporter writes JSONL payloads for:

- `source_corpus_providers`
- `source_corpus_versions`
- `quran_verses`
- `quran_verse_translations`
- `quran_verse_tafsirs`

It does not connect to Supabase, Directus, or any remote CMS.

## Tests

```sh
python3 -m unittest discover -s scripts/source_corpus -p 'test_*.py'
```

Tests use fixture files only. They must not download Tanzil, QuranEnc, Quran Foundation API data, or any live network source. Fixture text exists only to exercise parser behavior and must not be treated as production corpus data.
