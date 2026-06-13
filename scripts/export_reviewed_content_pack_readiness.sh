#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

out_dir="${SAKINAH_REVIEWED_CONTENT_PACK_DIR:-build/reviewed-content-pack-readiness}"
require_strict="${SAKINAH_REQUIRE_REVIEWED_CONTENT_PACK_READY:-false}"
package_name="com.sakinahdaily.app"
placeholder_source="Seed metadata; replace with approved Quran source before production"

seed_content="assets/content/seed_content.json"
content_guidelines="docs/content/01_CONTENT_GUIDELINES.md"
product_progress="docs/client/10_PRODUCT_REQUIREMENTS_PROGRESS.md"
research_gaps="docs/research/01_COMPETITOR_FEATURE_GAP_PRIORITY.md"
readiness="docs/release/01_RELEASE_READINESS_CHECKLIST.md"
version_notes="docs/release/08_VERSION_AND_RELEASE_NOTES.md"
docs_index="docs/00_DOCS_INDEX.md"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'reviewed content pack readiness failed: %s\n' "$message" >&2
  exit "$code"
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "required file is missing: $path"
}

require_text() {
  local path="$1"
  local needle="$2"
  grep -Fq "$needle" "$path" ||
    fail "$path is missing required text: $needle"
}

reject_text() {
  local path="$1"
  local needle="$2"
  if grep -Fq "$needle" "$path"; then
    fail "$path still contains blocked text: $needle"
  fi
}

require_true_var() {
  local name="$1"
  local description="$2"
  [[ "${!name:-}" == "true" ]] ||
    fail "$name=true is required after $description."
}

copy_required_file() {
  local path="$1"
  local target="$out_dir/$path"

  require_file "$path"
  mkdir -p "$(dirname "$target")"
  cp "$path" "$target"
}

command -v python3 >/dev/null ||
  fail "python3 is required to export the reviewed content pack readiness packet."

for path in \
  "$seed_content" \
  "$content_guidelines" \
  "$product_progress" \
  "$research_gaps" \
  "$readiness" \
  "$version_notes" \
  "$docs_index"; do
  require_file "$path"
done

require_text "$seed_content" '"reviewStatus": "approved"'
require_text "$content_guidelines" 'reviewed content pack readiness packet'
require_text "$product_progress" 'reviewed content pack readiness packet'
require_text "$research_gaps" 'SAKINAH_REQUIRE_REVIEWED_CONTENT_PACK_READY'
require_text "$readiness" 'Reviewed content pack readiness packet'
require_text "$version_notes" 'Reviewed content pack readiness packet'
require_text "$docs_index" 'export_reviewed_content_pack_readiness.sh'

if [[ "$require_strict" == "true" ]]; then
  require_true_var \
    SAKINAH_QURAN_SOURCE_PLACEHOLDERS_REPLACED \
    "replacing seed Quran source placeholders with approved Quran source labels"
  require_true_var \
    SAKINAH_BETA_SESSION_PACK_REVIEWED \
    "reviewing the 5-7 session beta pack with source labels, version, and reviewed date"
  require_true_var \
    SAKINAH_DUA_DHIKR_PACK_REVIEWED \
    "reviewing the 30-50 dua and 20-30 dhikr beta pack coverage"
  require_true_var \
    SAKINAH_QURAN_AUDIO_RIGHTS_CONFIRMED \
    "confirming licensed Quran reciter audio URLs, hashes, and rights evidence"
  require_true_var \
    SAKINAH_REVIEWED_CONTENT_PACK_OWNER_ASSIGNED \
    "assigning a human reviewer owner for the content pack before beta/store use"
  reject_text "$seed_content" "$placeholder_source"
fi

rm -rf "$out_dir"
mkdir -p "$out_dir"

cat >"$out_dir/pack_targets.csv" <<'EOF'
metric,value
session_target_min,5
session_target_max,7
dua_target_min,30
dua_target_max,50
dhikr_target_min,20
dhikr_target_max,30
quran_ayah_target_min,10
quran_ayah_target_max,20
EOF

python3 - "$seed_content" "$out_dir" "$placeholder_source" <<'PY'
import csv
import json
import sys
from pathlib import Path

seed_path = Path(sys.argv[1])
out_dir = Path(sys.argv[2])
placeholder = sys.argv[3]

data = json.loads(seed_path.read_text(encoding="utf-8"))

def approved(items):
    return [
        item
        for item in items
        if item.get("status") == "published"
        and item.get("reviewStatus") == "approved"
    ]

sessions = approved(data.get("sessions", []))
quran_ayahs = approved(data.get("quranAyahs", []))
duas = approved(data.get("duas", []))
dhikrs = approved(data.get("dhikrs", []))
reflections = approved(data.get("reflections", []))
audio_assets = [
    asset for asset in data.get("audioAssets", []) if asset.get("approved") is True
]

placeholder_ayahs = [
    ayah for ayah in quran_ayahs if placeholder in ayah.get("source", "")
]
missing_audio_url = [
    asset for asset in audio_assets if not str(asset.get("url", "")).strip()
]
missing_audio_sha = [
    asset for asset in audio_assets if not str(asset.get("sha256", "")).strip()
]

with (out_dir / "content_inventory.csv").open("w", newline="", encoding="utf-8") as fh:
    writer = csv.writer(fh)
    writer.writerow(["content_type", "metric", "value"])
    writer.writerow(["daily_session", "current_count", len(sessions)])
    writer.writerow(["daily_session", "reviewed_beta_target_min", 5])
    writer.writerow(["daily_session", "reviewed_beta_target_max", 7])
    writer.writerow(["quran_ayah", "current_count", len(quran_ayahs)])
    writer.writerow(["quran_ayah", "reviewed_beta_target_min", 10])
    writer.writerow(["quran_ayah", "reviewed_beta_target_max", 20])
    writer.writerow(["quran_ayah", "source_placeholder_count", len(placeholder_ayahs)])
    writer.writerow(["dua", "current_count", len(duas)])
    writer.writerow(["dua", "reviewed_beta_target_min", 30])
    writer.writerow(["dua", "reviewed_beta_target_max", 50])
    writer.writerow(["dhikr", "current_count", len(dhikrs)])
    writer.writerow(["dhikr", "reviewed_beta_target_min", 20])
    writer.writerow(["dhikr", "reviewed_beta_target_max", 30])
    writer.writerow(["reflection", "current_count", len(reflections)])
    writer.writerow(["audio_asset", "current_count", len(audio_assets)])
    writer.writerow(["audio_asset", "missing_url_count", len(missing_audio_url)])
    writer.writerow(["audio_asset", "missing_sha256_count", len(missing_audio_sha)])

with (out_dir / "source_placeholder_review.csv").open("w", newline="", encoding="utf-8") as fh:
    writer = csv.writer(fh)
    writer.writerow(["content_type", "content_id", "current_source", "required_action"])
    for ayah in placeholder_ayahs:
        writer.writerow([
            "quran_ayah",
            ayah.get("verseKey", "unknown"),
            ayah.get("source", ""),
            "replace with approved Quran source before beta/store production",
        ])

with (out_dir / "audio_asset_rights_review.csv").open("w", newline="", encoding="utf-8") as fh:
    writer = csv.writer(fh)
    writer.writerow([
        "audio_asset_id",
        "asset_type",
        "approved",
        "url_present",
        "sha256_present",
        "rights_status",
        "required_action",
    ])
    for asset in audio_assets:
        url_present = bool(str(asset.get("url", "")).strip())
        sha_present = bool(str(asset.get("sha256", "")).strip())
        rights_status = (
            "ready_for_rights_review"
            if url_present and sha_present
            else "licensed_reciter_rights_missing"
        )
        writer.writerow([
            asset.get("id", "unknown"),
            "quran_recitation",
            str(bool(asset.get("approved"))).lower(),
            str(url_present).lower(),
            str(sha_present).lower(),
            rights_status,
            "replace with licensed reciter URL/hash and rights evidence",
        ])

checklist = f"""# Reviewed Content Pack Gap Checklist

Status: Seed-only v0.1 baseline; not production content approval.

## Current Approved Seed Inventory

- Daily sessions: {len(sessions)} current; target 5-7 reviewed sessions.
- Quran ayahs: {len(quran_ayahs)} current; target 10-20 reviewed Quran ayah references.
- Duas: {len(duas)} current; target 30-50 reviewed duas.
- Dhikrs: {len(dhikrs)} current; target 20-30 reviewed dhikrs.
- Quran source placeholders: {len(placeholder_ayahs)} current; target 0.
- Approved Quran audio assets with missing URL: {len(missing_audio_url)}.
- Approved Quran audio assets with missing SHA-256: {len(missing_audio_sha)}.

## Required Before Broad Beta Or Store Production

- [ ] 5-7 reviewed sessions with source labels, version, and reviewed date.
- [ ] 30-50 reviewed duas with source labels, version, and reviewed date.
- [ ] 20-30 reviewed dhikrs with source labels, version, and reviewed date.
- [ ] 10-20 reviewed Quran ayah references used by sessions.
- [ ] No Quran source placeholder remains in production-facing seed content.
- [ ] Licensed Quran reciter audio rights, URLs, and SHA-256 hashes are confirmed.
- [ ] Women's Ibadah content copy is reviewed for privacy-safe wording.
- [ ] No generated religious content is introduced by this packet.

## Strict Mode Gate

Run only after external review is complete:

```sh
SAKINAH_REQUIRE_REVIEWED_CONTENT_PACK_READY=true \\
SAKINAH_QURAN_SOURCE_PLACEHOLDERS_REPLACED=true \\
SAKINAH_BETA_SESSION_PACK_REVIEWED=true \\
SAKINAH_DUA_DHIKR_PACK_REVIEWED=true \\
SAKINAH_QURAN_AUDIO_RIGHTS_CONFIRMED=true \\
SAKINAH_REVIEWED_CONTENT_PACK_OWNER_ASSIGNED=true \\
scripts/export_reviewed_content_pack_readiness.sh
```
"""

(out_dir / "beta_pack_gap_checklist.md").write_text(checklist, encoding="utf-8")
PY

for path in \
  "$seed_content" \
  "$content_guidelines" \
  "$product_progress" \
  "$research_gaps" \
  "$readiness" \
  "$version_notes" \
  "$docs_index" \
  scripts/export_reviewed_content_pack_readiness.sh; do
  copy_required_file "$path"
done

cat >"$out_dir/manifest.txt" <<EOF
Reviewed content pack readiness packet
Generated UTC: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Package: $package_name
Strict mode requested: $require_strict
Baseline: Seed-only v0.1 baseline
Privacy/religious safety rule: No generated religious content.

Generated readiness files:
- content_inventory.csv
- source_placeholder_review.csv
- audio_asset_rights_review.csv
- beta_pack_gap_checklist.md
- pack_targets.csv

Copied evidence:
- $seed_content
- $content_guidelines
- $product_progress
- $research_gaps
- $readiness
- $version_notes
- $docs_index
- scripts/export_reviewed_content_pack_readiness.sh

Strict mode requires:
- SAKINAH_QURAN_SOURCE_PLACEHOLDERS_REPLACED=true
- SAKINAH_BETA_SESSION_PACK_REVIEWED=true
- SAKINAH_DUA_DHIKR_PACK_REVIEWED=true
- SAKINAH_QURAN_AUDIO_RIGHTS_CONFIRMED=true
- SAKINAH_REVIEWED_CONTENT_PACK_OWNER_ASSIGNED=true
EOF

printf 'Reviewed content pack readiness packet exported.\n'
printf 'Packet: %s\n' "$out_dir"
printf 'Manifest: %s/manifest.txt\n' "$out_dir"
