# Push Module Completion Audit

Status: v0.1 local reminder audit packet for Google Play closed-test readiness.

This document defines how Sakinah Daily verifies whether the push/reminder
module is complete for the current release scope and how push/reminder
analytics are monitored without weakening privacy.

Push module completion audit packet is the release handoff artifact exported by
`scripts/export_push_module_completion_audit.sh`.

## Scope Decision

The v0.1 local reminder loop is complete for the client-side MVP. Completion
means:

- local prayer reminders can be enabled, tuned, scheduled, canceled, tested,
  and opened from notification taps;
- local daily session reminders can be enabled, scheduled, canceled, and opened
  from notification taps;
- permission explanation, Android notification permission handling, denied
  recovery, Settings management, Home/Prayer direct opt-in, dev-only smoke
  controls, cold-start payload handling, and automated regression tests exist;
- lock-screen copy remains privacy-safe for Women's Ibadah Mode;
- analytics are default-off, opt-in gated, and event-specific sanitized.

Remote FCM/APNs is outside v0.1 scope. It must not be marked complete until a
separate push backend, CMS payload review, consent/data-safety review, and
server-triggered delivery QA are designed and tested.

## Audit Packet

Run:

```sh
scripts/export_push_module_completion_audit.sh
```

Template mode writes `build/push-module-completion-audit` with:

- `manifest.txt`
- `push_module_completion_matrix.csv`
- `push_analytics_coverage_matrix.csv`
- `push_privacy_blocklist.csv`
- `push_module_qa_handoff.md`
- `push_permission_qa_evidence.csv`
- `push_real_device_smoke_evidence.csv`
- `push_debugview_event_review.csv`
- `push_oem_owner_assignment.csv`
- copied source evidence for notification, analytics, and tests

The packet is safe to attach to a local release review. It does not collect
tester names, emails, personal identifiers, location, health data, Women's
Ibadah Mode exact status, feedback text, or religious text.

The four evidence CSVs are templates in normal export mode. They intentionally
contain placeholder values such as `pending_manual_observation` so operators
cannot confuse template output with completed QA evidence.

Strict mode:

```sh
SAKINAH_REQUIRE_PUSH_MODULE_AUDIT_READY=true \
SAKINAH_PUSH_ANDROID_PERMISSION_QA_READY=true \
SAKINAH_PUSH_REAL_DEVICE_SMOKE_READY=true \
SAKINAH_PUSH_ANALYTICS_DEBUGVIEW_REVIEWED=true \
SAKINAH_PUSH_OEM_OBSERVATION_OWNER_ASSIGNED=true \
SAKINAH_PUSH_ANDROID_PERMISSION_EVIDENCE=/path/to/push_permission_qa_evidence.csv \
SAKINAH_PUSH_REAL_DEVICE_SMOKE_EVIDENCE=/path/to/push_real_device_smoke_evidence.csv \
SAKINAH_PUSH_ANALYTICS_DEBUGVIEW_EVIDENCE=/path/to/push_debugview_event_review.csv \
SAKINAH_PUSH_OEM_OWNER_EVIDENCE=/path/to/push_oem_owner_assignment.csv \
scripts/export_push_module_completion_audit.sh
```

Strict mode is for final pre-upload review after Android permission QA, real
device smoke delivery/tap-route QA, DebugView review, and OEM observation
ownership are confirmed. It validates that the completed evidence files contain
the expected scenarios/events, contain no template placeholders, and then writes
`Strict push evidence inputs: validated` into the manifest.

The completed DebugView evidence must cover the full local push/reminder event
set: `notification_settings_viewed`, `notification_permission_prompt_viewed`,
`prayer_reminder_permission_result`, `prayer_reminder_changed`,
`notification_schedule_result`, `notification_smoke_test_result`,
`notification_permission_recovery_opened`,
`daily_session_reminder_permission_result`,
`daily_session_reminder_changed`, `notification_tap_result`, and
`notification_tap_opened`.

## Push/Reminder Analytics Coverage

The completed local loop uses the existing privacy-safe events:

- `notification_settings_viewed`
- `notification_permission_prompt_viewed`
- `prayer_reminder_permission_result`
- `prayer_reminder_changed`
- `notification_schedule_result`
- `notification_smoke_test_result`
- `notification_permission_recovery_opened`
- `daily_session_reminder_permission_result`
- `daily_session_reminder_changed`
- `notification_tap_result`
- `notification_tap_opened`

Allowed parameters are intentionally coarse: reminder type, enabled state,
controlled source, coarse outcome, scheduled count, lead-time offset where
relevant, session ID for the local daily session reminder loop, coarse
notification content type for opens, and coarse tap outcome for handled or
unhandled local notification taps.

The analytics contract blocks raw notification payloads, routes, exact
scheduled local times, exact reminder times, lock-screen body copy, coordinates,
manual place labels, timezone IDs, device model, tester identity, Women's
Ibadah Mode exact status, feedback text, Quran/Dua/Dhikr/reflection text, and
other free text.

## QA Handoff

- Use the Google Analytics DebugView QA packet to confirm event names and
  allowed parameters before any analytics-enabled closed-test QA.
- Use the Android OEM reminder observation packet for 8-hour, 24-hour, reboot,
  battery-policy, and notification-permission-state evidence.
- Use the dev-only Notification Settings smoke controls only in dev builds with
  `SAKINAH_NOTIFICATION_QA_ENABLED=true`.
- Keep No tester personal data as the audit rule for all exported packets.

## Future Work

- Add a separate Remote FCM/APNs PRD and event matrix only after the backend,
  CMS payload moderation, user-facing consent/data-safety updates, and delivery
  QA plan are ready.
- Add quiet hours after the long-window Android OEM reminder observation is
  stable.
