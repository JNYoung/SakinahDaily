#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

out_dir="${SAKINAH_PUBLIC_LINKS_PACKET_DIR:-build/play-public-links}"
require_strict="${SAKINAH_REQUIRE_PUBLIC_LINKS_HOSTING_READY:-false}"

privacy_policy_url="${SAKINAH_PRIVACY_POLICY_URL:-https://privacy.sakinahdaily.app/privacy}"
testing_feedback="${SAKINAH_PLAY_TESTING_FEEDBACK:-support@sakinahdaily.app}"
host_base="${SAKINAH_PUBLIC_LINKS_HOST_BASE:-https://privacy.sakinahdaily.app}"
effective_date="${SAKINAH_PRIVACY_EFFECTIVE_DATE:-$(date -u +"%Y-%m-%d")}"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Google Play public links hosting packet failed: %s\n' "$message" >&2
  exit "$code"
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "required file is missing: $path"
}

require_executable() {
  local path="$1"
  [[ -x "$path" ]] || fail "required script is not executable: $path"
}

copy_required_file() {
  local path="$1"
  local target="$out_dir/$path"

  require_file "$path"
  mkdir -p "$(dirname "$target")"
  cp "$path" "$target"
}

require_file docs/privacy/02_PRIVACY_POLICY_DRAFT.md
require_file docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md
require_file docs/privacy/06_SDK_AND_API_INVENTORY.md
require_file docs/release/11_PLAY_PUBLIC_LINKS_AND_FEEDBACK.md
require_file docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md
require_executable scripts/verify_google_play_public_links.sh

if [[ "$require_strict" == "true" ]]; then
  scripts/verify_google_play_public_links.sh
fi

rm -rf "$out_dir"
mkdir -p "$out_dir/privacy" "$out_dir/feedback"

for path in \
  docs/privacy/02_PRIVACY_POLICY_DRAFT.md \
  docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md \
  docs/privacy/06_SDK_AND_API_INVENTORY.md \
  docs/release/11_PLAY_PUBLIC_LINKS_AND_FEEDBACK.md \
  docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md \
  scripts/verify_google_play_public_links.sh \
  scripts/verify_google_play_public_links_packet.sh; do
  copy_required_file "$path"
done

cat >"$out_dir/privacy/index.html" <<EOF
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sakinah Daily Privacy Policy</title>
    <style>
      body { font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; line-height: 1.6; margin: 0; color: #17201c; background: #fbfbf8; }
      main { max-width: 820px; margin: 0 auto; padding: 40px 20px 56px; }
      h1, h2 { line-height: 1.25; }
      h1 { font-size: 2rem; }
      h2 { margin-top: 2rem; }
      .notice { border-left: 4px solid #547c64; padding: 12px 16px; background: #eef5ef; }
      li { margin: 0.35rem 0; }
    </style>
  </head>
  <body>
    <main>
      <h1>Sakinah Daily Privacy Policy</h1>
      <p class="notice">Status: prepared from the local legal/store review draft. Publish only after final human review.</p>
      <p><strong>Effective date:</strong> ${effective_date}</p>
      <p><strong>Contact:</strong> ${testing_feedback}</p>

      <h2>Summary</h2>
      <p>Sakinah Daily is a privacy-first daily prayer companion. The v0.1 app is designed around local preferences, local prayer reminders, approved content, and clear user controls.</p>
      <p>No ads, tracking SDK, crash SDK, or default-on analytics collection are included in the v0.1 release. Firebase Analytics is present for reviewed retention measurement, but collection is disabled unless a build explicitly enables <code>SAKINAH_ANALYTICS_ENABLED=true</code> with Firebase configuration and the user turns on usage analytics in Privacy Center.</p>

      <h2>Data Stored On Device</h2>
      <ul>
        <li>Language, prayer settings, notification choices, manual or preset prayer location, saved items, and local session progress.</li>
        <li>Women's Ibadah Mode state is local-first and is not sent for remote personalization in the MVP.</li>
        <li>Closed-testing feedback status stores only local sent markers for Day 1, Day 3, Day 7, and Day 14 prompts.</li>
      </ul>

      <h2>Data That May Leave The Device</h2>
      <p>If remote content delivery is enabled later, requests may include language, market, app version, schema version, and bundle hints. Exact Women's Ibadah Mode status is not included in remote content requests.</p>

      <h2>How To Delete Local Data</h2>
      <p>Users can clear local preferences, saved items, session progress, cached content bundles, and scheduled reminders through Settings &gt; Privacy &gt; Delete local data.</p>

      <h2>Not Implemented In MVP</h2>
      <ul>
        <li>No account login, payments, subscriptions, ads, tracking SDK, crash-reporting SDK, exact GPS permission, social features, remote progress sync, or default-on analytics collection.</li>
        <li>No AI fatwa, religious Q&amp;A, community, or user-generated religious content.</li>
      </ul>

      <h2>Source Drafts</h2>
      <p>This hosted page should be reviewed against <code>docs/privacy/02_PRIVACY_POLICY_DRAFT.md</code>, <code>docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md</code>, and final store/legal decisions before publishing.</p>
    </main>
  </body>
</html>
EOF

cat >"$out_dir/feedback/index.html" <<EOF
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sakinah Daily Closed Testing Feedback</title>
    <style>
      body { font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; line-height: 1.6; margin: 0; color: #17201c; background: #fbfbf8; }
      main { max-width: 820px; margin: 0 auto; padding: 40px 20px 56px; }
      h1, h2 { line-height: 1.25; }
      .notice { border-left: 4px solid #547c64; padding: 12px 16px; background: #eef5ef; }
      code { white-space: normal; }
    </style>
  </head>
  <body>
    <main>
      <h1>Sakinah Daily Closed Testing Feedback</h1>
      <p class="notice">Please avoid personal or sensitive health details. Do not send Women's Ibadah Mode exact status, private messages, account data, or screenshots with personal information.</p>
      <p><strong>Feedback channel:</strong> ${testing_feedback}</p>

      <h2>Day 1</h2>
      <p>Did onboarding explain language, prayer location, reminders, and privacy clearly enough?</p>

      <h2>Day 3</h2>
      <p>Were prayer times, location, and reminder controls easy to trust?</p>

      <h2>Day 7</h2>
      <p>What made you want to reopen the app, and what made daily use harder?</p>

      <h2>Day 14</h2>
      <p>What one change would most improve daily prayer use before wider release?</p>

      <h2>Core Areas To Check</h2>
      <ul>
        <li>Home next-prayer context and today's session.</li>
        <li>Prayer times, local reminders, and reminder settings.</li>
        <li>Daily Session completion and privacy-safe reminder copy.</li>
        <li>Privacy Center, Delete local data, English, Bahasa Indonesia, and Arabic RTL.</li>
      </ul>

      <h2>Tester Links</h2>
      <p>Join the tester group first, then use the Play testing opt-in link when the release is approved.</p>
      <p><code>https://groups.google.com/g/sakinah-daily-testers</code></p>
      <p><code>https://play.google.com/apps/testing/com.sakinahdaily.app</code></p>
    </main>
  </body>
</html>
EOF

cat >"$out_dir/manifest.txt" <<EOF
Google Play public links hosting packet
Generated UTC: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Package: com.sakinahdaily.app
Strict mode requested: $require_strict
Privacy rule: No tester personal data.

Recommended hosting base:
- $host_base

Files to host:
- privacy/index.html -> SAKINAH_PRIVACY_POLICY_URL
- feedback/index.html -> SAKINAH_PLAY_TESTING_FEEDBACK if using an HTTPS feedback page

Configured public fields:
- SAKINAH_PRIVACY_POLICY_URL: ${SAKINAH_PRIVACY_POLICY_URL:-missing; template default is $privacy_policy_url}
- SAKINAH_PLAY_TESTING_FEEDBACK: ${SAKINAH_PLAY_TESTING_FEEDBACK:-missing; template default is $testing_feedback}

Validation:
- scripts/verify_google_play_public_links.sh
- scripts/verify_google_play_public_links_packet.sh
- SAKINAH_REQUIRE_PUBLIC_LINKS_HOSTING_READY=true scripts/export_google_play_public_links_packet.sh

Required copied evidence:
- docs/privacy/02_PRIVACY_POLICY_DRAFT.md
- docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md
- docs/privacy/06_SDK_AND_API_INVENTORY.md
- docs/release/11_PLAY_PUBLIC_LINKS_AND_FEEDBACK.md
- docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md
- scripts/verify_google_play_public_links.sh
- scripts/verify_google_play_public_links_packet.sh
- scripts/verify_google_play_public_links_packet.sh

Publish notes:
- Review the generated privacy page with legal/store owner before publishing.
- Host over HTTPS with no login, no geoblock, and no private network access.
- Use the final URL in Play Console App content, Data safety, the production
  Dart define, and scripts/verify_google_play_upload_preflight.sh.
- If feedback uses email instead of this hosted page, keep
  SAKINAH_PLAY_TESTING_FEEDBACK as the final support email and host only the
  privacy page.
EOF

printf 'Google Play public links hosting packet exported.\n'
printf 'Packet: %s\n' "$out_dir"
printf 'Privacy page: %s/privacy/index.html\n' "$out_dir"
printf 'Feedback page: %s/feedback/index.html\n' "$out_dir"
printf 'Manifest: %s/manifest.txt\n' "$out_dir"
