"""CLI helper for exporting CMS import JSONL payloads."""

from __future__ import annotations

import argparse
from pathlib import Path

from source_corpus import export_cms_payloads


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--processed", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--source-corpus-version-id", required=True)
    args = parser.parse_args()

    export_cms_payloads(
        args.processed,
        args.output_dir,
        source_corpus_version_id=args.source_corpus_version_id,
    )


if __name__ == "__main__":
    main()
