#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

e2e_profile="${SAKINAH_E2E_PROFILE:-full}"

default_skip_flutter_test=false
default_skip_dart_analyze=false
default_skip_submission_pack=false
default_skip_public_links_packet=false
default_skip_closed_test_setup_packet=false
default_skip_analytics_debugview_packet=false
default_skip_push_module_audit=false
default_skip_day0_day1_operator_packet=false
default_skip_reviewed_content_pack=false
default_skip_android_oem_observation_packet=false
default_skip_android_launch=false
default_run_release_gate=false

case "$e2e_profile" in
  full)
    ;;
  ci)
    default_skip_android_launch=true
    ;;
  fast)
    default_skip_flutter_test=true
    default_skip_dart_analyze=true
    default_skip_submission_pack=true
    default_skip_public_links_packet=true
    default_skip_closed_test_setup_packet=true
    default_skip_analytics_debugview_packet=true
    default_skip_push_module_audit=true
    default_skip_day0_day1_operator_packet=true
    default_skip_reviewed_content_pack=true
    default_skip_android_oem_observation_packet=true
    ;;
  release)
    default_run_release_gate=true
    ;;
  *)
    printf 'Unknown SAKINAH_E2E_PROFILE=%s. Expected full|ci|fast|release.\n' "$e2e_profile" >&2
    exit 2
    ;;
esac

skip_flutter_test="${SAKINAH_E2E_SKIP_FLUTTER_TEST:-$default_skip_flutter_test}"
skip_dart_analyze="${SAKINAH_E2E_SKIP_DART_ANALYZE:-$default_skip_dart_analyze}"
skip_submission_pack="${SAKINAH_E2E_SKIP_SUBMISSION_PACK:-$default_skip_submission_pack}"
skip_public_links_packet="${SAKINAH_E2E_SKIP_PUBLIC_LINKS_PACKET:-$default_skip_public_links_packet}"
skip_closed_test_setup_packet="${SAKINAH_E2E_SKIP_CLOSED_TEST_SETUP_PACKET:-$default_skip_closed_test_setup_packet}"
skip_analytics_debugview_packet="${SAKINAH_E2E_SKIP_ANALYTICS_DEBUGVIEW_PACKET:-$default_skip_analytics_debugview_packet}"
skip_push_module_audit="${SAKINAH_E2E_SKIP_PUSH_MODULE_AUDIT:-$default_skip_push_module_audit}"
skip_day0_day1_operator_packet="${SAKINAH_E2E_SKIP_DAY0_DAY1_OPERATOR_PACKET:-$default_skip_day0_day1_operator_packet}"
skip_reviewed_content_pack="${SAKINAH_E2E_SKIP_REVIEWED_CONTENT_PACK:-$default_skip_reviewed_content_pack}"
skip_android_oem_observation_packet="${SAKINAH_E2E_SKIP_ANDROID_OEM_OBSERVATION_PACKET:-$default_skip_android_oem_observation_packet}"
skip_android_launch="${SAKINAH_E2E_SKIP_ANDROID_LAUNCH:-$default_skip_android_launch}"
run_release_gate="${SAKINAH_E2E_RUN_RELEASE_GATE:-$default_run_release_gate}"
flutter_test_args=()
timed_steps=()

if [[ -n "${SAKINAH_E2E_FLUTTER_TEST_ARGS:-}" ]]; then
  # shellcheck disable=SC2206
  flutter_test_args=(${SAKINAH_E2E_FLUTTER_TEST_ARGS})
else
  flutter_test_args=(--concurrency=1)
fi

has_android_device() {
  local devices
  devices="$(flutter --no-version-check devices 2>/dev/null || true)"
  grep -q 'android-arm64' <<<"$devices" ||
    grep -Eq 'Android [0-9]+|android-' <<<"$devices"
}

run_step() {
  local title="$1"
  shift
  local started=$SECONDS
  local duration
  printf '\n==> %s\n' "$title"
  "$@"
  duration=$((SECONDS - started))
  timed_steps+=("${title}: ${duration}s")
  printf '<== %s finished in %ss\n' "$title" "$duration"
}

printf 'Local e2e profile: %s (full|ci|fast|release).\n' "$e2e_profile"
if [[ "$e2e_profile" == "fast" ]]; then
  printf 'Fast profile assumes flutter test and dart analyze already ran; it skips release evidence packet exports and keeps Android launch smoke when a device is available.\n'
elif [[ "$e2e_profile" == "ci" ]]; then
  printf 'CI profile keeps tests and release-readiness packet gates, but skips Android launch smoke by default.\n'
elif [[ "$e2e_profile" == "release" ]]; then
  printf 'Release profile includes the internal release gate in addition to the full local checks.\n'
fi

if [[ "$skip_flutter_test" != "true" ]]; then
  run_step "Flutter widget/unit tests" \
    flutter --no-version-check test "${flutter_test_args[@]}"
else
  printf 'Skipping flutter test because SAKINAH_E2E_SKIP_FLUTTER_TEST=true.\n'
fi

if [[ "$skip_dart_analyze" != "true" ]]; then
  run_step "Dart analyzer" dart analyze
else
  printf 'Skipping dart analyze because SAKINAH_E2E_SKIP_DART_ANALYZE=true.\n'
fi

if [[ "$skip_submission_pack" != "true" ]]; then
  run_step "Google Play submission pack template gate" \
    scripts/verify_google_play_submission_pack.sh
else
  printf 'Skipping submission pack because SAKINAH_E2E_SKIP_SUBMISSION_PACK=true.\n'
fi

if [[ "$skip_public_links_packet" != "true" ]]; then
  run_step "Google Play public links packet QA" \
    scripts/verify_google_play_public_links_packet.sh
else
  printf 'Skipping public links packet QA because SAKINAH_E2E_SKIP_PUBLIC_LINKS_PACKET=true.\n'
fi

if [[ "$skip_closed_test_setup_packet" != "true" ]]; then
  run_step "Google Play closed-test setup packet" \
    scripts/export_google_play_closed_test_setup_packet.sh
else
  printf 'Skipping closed-test setup packet because SAKINAH_E2E_SKIP_CLOSED_TEST_SETUP_PACKET=true.\n'
fi

if [[ "$skip_analytics_debugview_packet" != "true" ]]; then
  run_step "Google Analytics DebugView QA packet" \
    scripts/export_google_analytics_debugview_packet.sh
else
  printf 'Skipping analytics DebugView QA packet because SAKINAH_E2E_SKIP_ANALYTICS_DEBUGVIEW_PACKET=true.\n'
fi

if [[ "$skip_push_module_audit" != "true" ]]; then
  run_step "Push module completion audit packet" \
    scripts/export_push_module_completion_audit.sh
else
  printf 'Skipping push module completion audit because SAKINAH_E2E_SKIP_PUSH_MODULE_AUDIT=true.\n'
fi

if [[ "$skip_day0_day1_operator_packet" != "true" ]]; then
  run_step "Google Play Day 0 / Day 1 operator packet" \
    scripts/export_google_play_day0_day1_operator_packet.sh
else
  printf 'Skipping Day 0 / Day 1 operator packet because SAKINAH_E2E_SKIP_DAY0_DAY1_OPERATOR_PACKET=true.\n'
fi

if [[ "$skip_reviewed_content_pack" != "true" ]]; then
  run_step "Reviewed content pack readiness packet" \
    scripts/export_reviewed_content_pack_readiness.sh
else
  printf 'Skipping reviewed content pack readiness packet because SAKINAH_E2E_SKIP_REVIEWED_CONTENT_PACK=true.\n'
fi

if [[ "$skip_android_oem_observation_packet" != "true" ]]; then
  run_step "Android OEM reminder observation packet" \
    scripts/export_android_oem_reminder_observation_packet.sh
else
  printf 'Skipping Android OEM reminder observation packet because SAKINAH_E2E_SKIP_ANDROID_OEM_OBSERVATION_PACKET=true.\n'
fi

if [[ "$run_release_gate" == "true" ]]; then
  run_step "Google Play internal release gate" \
    scripts/verify_google_play_internal_release.sh
else
  printf 'Skipping release gate by default. Set SAKINAH_E2E_RUN_RELEASE_GATE=true for signed or explicitly configured release builds.\n'
fi

if [[ "$skip_android_launch" == "true" ]]; then
  printf 'Skipping Android launch smoke because SAKINAH_E2E_SKIP_ANDROID_LAUNCH=true.\n'
elif has_android_device; then
  run_step "Android launch smoke" scripts/verify_android_launch_smoke.sh
else
  printf 'No Android device detected; skipping Android launch smoke. Set SAKINAH_ANDROID_EMULATOR_ID to request an emulator.\n'
fi

if ((${#timed_steps[@]} > 0)); then
  printf '\nStep timings:\n'
  for item in "${timed_steps[@]}"; do
    printf '%s\n' "- $item"
  done
fi

printf '\nLocal e2e gate passed.\n'
