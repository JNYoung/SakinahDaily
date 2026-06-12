#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

skip_flutter_test="${SAKINAH_E2E_SKIP_FLUTTER_TEST:-false}"
skip_dart_analyze="${SAKINAH_E2E_SKIP_DART_ANALYZE:-false}"
skip_submission_pack="${SAKINAH_E2E_SKIP_SUBMISSION_PACK:-false}"
skip_public_links_packet="${SAKINAH_E2E_SKIP_PUBLIC_LINKS_PACKET:-false}"
skip_reviewed_content_pack="${SAKINAH_E2E_SKIP_REVIEWED_CONTENT_PACK:-false}"
skip_android_launch="${SAKINAH_E2E_SKIP_ANDROID_LAUNCH:-false}"
run_release_gate="${SAKINAH_E2E_RUN_RELEASE_GATE:-false}"
flutter_test_args=()

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
  printf '\n==> %s\n' "$title"
  "$@"
}

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

if [[ "$skip_reviewed_content_pack" != "true" ]]; then
  run_step "Reviewed content pack readiness packet" \
    scripts/export_reviewed_content_pack_readiness.sh
else
  printf 'Skipping reviewed content pack readiness packet because SAKINAH_E2E_SKIP_REVIEWED_CONTENT_PACK=true.\n'
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

printf '\nLocal e2e gate passed.\n'
