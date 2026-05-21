"""CLI helper for exporting draft Quran source item JSONL payloads."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from source_corpus import DEFAULT_SELECTED_VERSE_KEYS, export_source_items


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--processed", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--source-corpus-version-id", required=True)
    parser.add_argument("--verse-key", action="append", dest="verse_keys")
    parser.add_argument("--metadata-json", type=Path)
    args = parser.parse_args()

    metadata_by_verse = None
    if args.metadata_json:
        metadata_by_verse = json.loads(args.metadata_json.read_text(encoding="utf-8"))

    export_source_items(
        args.processed,
        args.output,
        selected_verse_keys=args.verse_keys or DEFAULT_SELECTED_VERSE_KEYS,
        source_corpus_version_id=args.source_corpus_version_id,
        metadata_by_verse=metadata_by_verse,
    )


if __name__ == "__main__":
    main()
