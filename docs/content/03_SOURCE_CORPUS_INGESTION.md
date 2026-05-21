# Quran Source Corpus Ingestion

The ingestion foundation parses downloaded source files and preserves provider metadata. It must never generate Quran text, rewrite source text, or fetch live APIs during tests.

Supported MVP inputs:

- Tanzil-style Arabic lines: `surah|ayah|text`
- QuranEnc-style translation CSV rows

Output:

- `quran_verses.jsonl`, generated locally after raw source files are provided.
- Lock metadata with provider, version, attribution, and checksum.
