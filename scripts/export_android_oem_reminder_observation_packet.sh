#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

out_dir="${SAKINAH_ANDROID_OEM_OBSERVATION_DIR:-build/android-oem-reminder-observation}"
require_strict="${SAKINAH_REQUIRE_ANDROID_OEM_REMINDER_OBSERVATION_READY:-false}"
package_name="com.sakinahdaily.app"

docs_index="docs/00_DOCS_INDEX.md"
product_progress="docs/client/10_PRODUCT_REQUIREMENTS_PROGRESS.md"
readiness="docs/release/01_RELEASE_READINESS_CHECKLIST.md"
android_checklist="docs/release/02_ANDROID_RELEASE_CHECKLIST.md"
acceptance="docs/testing/01_ACCEPTANCE_CHECKLIST.md"
version_notes="docs/release/08_VERSION_AND_RELEASE_NOTES.md"
permission_review="docs/release/06_PERMISSION_AND_DATA_SAFETY_REVIEW.md"
permission_copy="docs/privacy/05_PERMISSION_COPY.md"
android_manifest="android/app/src/main/AndroidManifest.xml"
notification_service="lib/core/services/notification_service.dart"
launch_smoke="scripts/verify_android_launch_smoke.sh"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Android OEM reminder observation packet failed: %s\n' "$message" >&2
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

copy_required_text_evidence() {
  local path="$1"
  local target="$out_dir/source-evidence/$path.txt"

  require_file "$path"
  mkdir -p "$(dirname "$target")"
  cp "$path" "$target"
}

for path in \
  "$docs_index" \
  "$product_progress" \
  "$readiness" \
  "$android_checklist" \
  "$acceptance" \
  "$version_notes" \
  "$permission_review" \
  "$permission_copy" \
  "$android_manifest" \
  "$notification_service" \
  "$launch_smoke"; do
  require_file "$path"
done

require_text "$docs_index" 'export_android_oem_reminder_observation_packet.sh'
require_text "$product_progress" 'Android OEM reminder observation packet'
require_text "$readiness" 'Android OEM reminder observation packet'
require_text "$android_checklist" 'Android OEM reminder observation packet'
require_text "$acceptance" 'Android OEM reminder observation packet'
require_text "$version_notes" 'Android OEM reminder observation packet'
require_text "$permission_review" 'RECEIVE_BOOT_COMPLETED'
require_text "$permission_copy" 'RECEIVE_BOOT_COMPLETED'
require_text "$android_manifest" 'RECEIVE_BOOT_COMPLETED'
require_text "$notification_service" 'zonedSchedule'
require_text "$launch_smoke" 'SAKINAH_ANDROID_SERIAL'

if [[ "$require_strict" == "true" ]]; then
  require_true_var \
    SAKINAH_ANDROID_OEM_TEST_DEVICE_CONFIRMED \
    "confirming the Android OEM test device and OS version"
  require_true_var \
    SAKINAH_8H_PRAYER_REMINDER_OBSERVED \
    "observing an 8-hour prayer reminder delivery and tap route"
  require_true_var \
    SAKINAH_24H_PRAYER_REMINDER_OBSERVED \
    "observing a 24-hour prayer reminder delivery and tap route"
  require_true_var \
    SAKINAH_REBOOT_REMINDER_RESTORE_OBSERVED \
    "observing scheduled reminder restore after device reboot"
  require_true_var \
    SAKINAH_BATTERY_POLICY_REVIEWED \
    "reviewing aggressive battery-management behavior on the target OEM"
  require_true_var \
    SAKINAH_OEM_OBSERVATION_OWNER_ASSIGNED \
    "assigning a human owner for the long-window reminder observation"
fi

rm -rf "$out_dir"
mkdir -p "$out_dir"

device_serial="${SAKINAH_ANDROID_SERIAL:-${ANDROID_SERIAL:-record_manually}}"
oem_model="${SAKINAH_ANDROID_OEM_MODEL:-record_manually}"

cat >"$out_dir/long_window_observation_log.csv" <<EOF
observation_window,device_serial,oem_or_model,scheduled_reminder_type,scheduled_local_time,expected_delivery_window,actual_delivery_result,tap_result,notes_without_personal_data
8h,$device_serial,$oem_model,prayer_reminder,record_manually,8-hour prayer reminder within configured local schedule,pending_manual_observation,pending_tap_route,No tester personal data
24h,$device_serial,$oem_model,prayer_reminder,record_manually,24-hour prayer reminder within configured local schedule,pending_manual_observation,pending_tap_route,No tester personal data
daily_session,$device_serial,$oem_model,daily_session_reminder,record_manually,next local reminder window,pending_manual_observation,pending_tap_route,No tester personal data
EOF

cat >"$out_dir/reboot_delivery_checklist.csv" <<EOF
scenario,device_serial,required_android_capability,pre_reboot_action,post_reboot_expected_result,observed_result,notes_without_personal_data
reboot_restore,$device_serial,RECEIVE_BOOT_COMPLETED,schedule prayer reminder then reboot device,local reminder remains scheduled or is restored by flutter_local_notifications,pending_manual_observation,No tester personal data
package_replace,$device_serial,ScheduledNotificationBootReceiver,install updated debug or release candidate,local reminder behavior is rechecked after package replacement,pending_manual_observation,No tester personal data
EOF

cat >"$out_dir/battery_policy_review.csv" <<EOF
device_serial,oem_or_model,battery_policy_state,aggressive battery-management risk,review_action,observed_result
$device_serial,$oem_model,record_manually,unknown,record OEM battery/background policy and whether reminders are delayed,pending_manual_observation
$device_serial,$oem_model,optimized_or_restricted,aggressive battery-management may delay local notifications,record user-facing guidance decision if delay is observed,pending_manual_observation
EOF

cat >"$out_dir/oem_observation_checklist.md" <<'EOF'
# Android OEM Reminder Observation Checklist

Status: template evidence only until long-window device observations are recorded.

## Scope

- 8-hour prayer reminder delivery and tap route.
- 24-hour prayer reminder delivery and tap route.
- Daily session reminder delivery after the app is idle.
- Reminder restore after device reboot.
- OEM battery or background policy review for aggressive battery-management behavior.

## Privacy And Copy Rules

- do not record tester personal data, phone numbers, emails, exact locations, or free-text worship notes.
- Keep notes aggregate and operational, for example delivered, delayed, missed, or tapped.
- Verify lock-screen copy remains gentle and privacy-safe.
- Do not include Women's Ibadah Mode state in notification text or observation notes.

## Strict Mode Gate

Run only after real observation evidence is complete:

```sh
SAKINAH_REQUIRE_ANDROID_OEM_REMINDER_OBSERVATION_READY=true \
SAKINAH_ANDROID_OEM_TEST_DEVICE_CONFIRMED=true \
SAKINAH_8H_PRAYER_REMINDER_OBSERVED=true \
SAKINAH_24H_PRAYER_REMINDER_OBSERVED=true \
SAKINAH_REBOOT_REMINDER_RESTORE_OBSERVED=true \
SAKINAH_BATTERY_POLICY_REVIEWED=true \
SAKINAH_OEM_OBSERVATION_OWNER_ASSIGNED=true \
scripts/export_android_oem_reminder_observation_packet.sh
```
EOF

for path in \
  "$docs_index" \
  "$product_progress" \
  "$readiness" \
  "$android_checklist" \
  "$acceptance" \
  "$version_notes" \
  "$permission_review" \
  "$permission_copy" \
  "$android_manifest" \
  "$launch_smoke" \
  scripts/export_android_oem_reminder_observation_packet.sh; do
  copy_required_file "$path"
done

copy_required_text_evidence "$notification_service"

cat >"$out_dir/manifest.txt" <<EOF
Android OEM reminder observation packet
Generated UTC: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Package: $package_name
Strict mode requested: $require_strict
Privacy rule: No tester personal data.

Generated observation files:
- long_window_observation_log.csv
- reboot_delivery_checklist.csv
- battery_policy_review.csv
- oem_observation_checklist.md

Copied evidence:
- $docs_index
- $product_progress
- $readiness
- $android_checklist
- $acceptance
- $version_notes
- $permission_review
- $permission_copy
- $android_manifest
- source-evidence/$notification_service.txt
- $launch_smoke
- scripts/export_android_oem_reminder_observation_packet.sh

Strict mode requires:
- SAKINAH_ANDROID_OEM_TEST_DEVICE_CONFIRMED=true
- SAKINAH_8H_PRAYER_REMINDER_OBSERVED=true
- SAKINAH_24H_PRAYER_REMINDER_OBSERVED=true
- SAKINAH_REBOOT_REMINDER_RESTORE_OBSERVED=true
- SAKINAH_BATTERY_POLICY_REVIEWED=true
- SAKINAH_OEM_OBSERVATION_OWNER_ASSIGNED=true
EOF

printf 'Android OEM reminder observation packet exported.\n'
printf 'Packet: %s\n' "$out_dir"
printf 'Manifest: %s/manifest.txt\n' "$out_dir"
