# Quran Source Corpus Ingestion

The ingestion foundation parses local provider files and preserves provider metadata. It must never generate Quran text, rewrite source text, machine-translate meanings, or fetch live APIs during tests.

## Supported Inputs

- Tanzil-style Arabic lines: `surah|ayah|text`
- QuranEnc-style CSV rows with `surah`, `ayah`, `language`, `text`, `provider`, `version`, and `attribution`
- QuranEnc Arabic tafsir/explanation rows using `content_type: tafsir` in the manifest
- Optional QuranEnc Indonesian translation rows

## Local Raw Files

Place raw files under `data/source/raw/` and point `docs/content/source_corpus_manifest.yaml` at those local paths. These raw files are intentionally not committed.

Required metadata for every source:

- provider id and provider name
- content type and language
- version
- local path
- attribution
- terms summary
- expected format

## Ingestion

```sh
python3 scripts/source_corpus/source_corpus.py \
  --manifest docs/content/source_corpus_manifest.yaml \
  --output data/source/processed/quran_verses.jsonl \
  --lock-file data/source/processed/source_corpus_manifest.lock.json
```

The processed JSONL is sorted by surah and ayah. Each row contains `verse_key`, `surah`, `ayah`, `arabic_text`, `translations`, provider metadata, and an Arabic text SHA-256 checksum.

If a manifest local file is missing or invalid, ingestion fails clearly. It must not silently generate substitute content.

## Lock File

`source_corpus_manifest.lock.json` records:

- generation timestamp
- manifest SHA-256 hash
- provider/source entries
- local file path
- source file SHA-256 checksum
- row count or verse count
- content type, language, version, attribution
- validation status and warnings

## Exports

`export_source_items` and `scripts/source_corpus/export_source_items.py` create draft source item payloads for selected Quran verses. They do not invent topics, ritual moments, or religious copy, and they never mark rows approved or published.

`export_cms_payloads` creates import-ready JSONL payloads for source corpus providers, versions, verses, translations, and tafsirs. It does not connect to Supabase, Directus, or any remote CMS.

## Validation Rules

Production full-corpus validation defaults to 114 surahs and 6,236 ayahs. Fixture tests may use smaller configurable counts.

Validation also checks unique verse keys, non-empty Arabic text, translations attached only to existing Arabic verses, checksums, provider/version/attribution metadata, deterministic JSONL output, and absence of generated-source markers.

## Test Rules

Tests are fixture-only. They must not perform live network calls, live Tanzil downloads, live QuranEnc downloads, Quran Foundation API calls, AI content generation, Quran text generation, or translation generation.

## Do Not Commit

- full Quran corpus files
- production `quran_verses.jsonl` unless explicitly requested later
- licensed audio
- production CMS config
- secrets
