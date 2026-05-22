import '../models/sakinah_models.dart';

class WomenModeContentDecision {
  const WomenModeContentDecision({
    required this.allowPrayerSession,
    required this.preferDuaDhikrReflection,
    required this.lockScreenSensitiveHidden,
    required this.flags,
  });

  final bool allowPrayerSession;
  final bool preferDuaDhikrReflection;
  final bool lockScreenSensitiveHidden;
  final List<String> flags;
}

class WomenModeContentPolicy {
  const WomenModeContentPolicy();

  WomenModeContentDecision evaluate(WomenIbadahMode mode) {
    if (!mode.enabled || mode.status == WomenIbadahStatus.normal) {
      return const WomenModeContentDecision(
        allowPrayerSession: true,
        preferDuaDhikrReflection: false,
        lockScreenSensitiveHidden: false,
        flags: ['standard_content'],
      );
    }

    final lockScreenSensitiveHidden =
        mode.enabled && mode.hideCycleSensitiveLockScreenCopy;
    final flags = <String>[
      'local_only',
      'no_exact_status_exposed',
      if (lockScreenSensitiveHidden) 'lock_screen_sensitive_hidden',
    ];

    return switch (mode.status) {
      WomenIbadahStatus.menstruating ||
      WomenIbadahStatus.postpartum =>
        WomenModeContentDecision(
          allowPrayerSession: false,
          preferDuaDhikrReflection: true,
          lockScreenSensitiveHidden: lockScreenSensitiveHidden,
          flags: [
            ...flags,
            'prefer_dua_dhikr_reflection',
            'privacy_safe_copy',
          ],
        ),
      WomenIbadahStatus.pregnancy => WomenModeContentDecision(
          allowPrayerSession: true,
          preferDuaDhikrReflection: false,
          lockScreenSensitiveHidden: lockScreenSensitiveHidden,
          flags: [...flags, 'gentle_support'],
        ),
      WomenIbadahStatus.preferNotToTrack => WomenModeContentDecision(
          allowPrayerSession: true,
          preferDuaDhikrReflection: false,
          lockScreenSensitiveHidden: lockScreenSensitiveHidden,
          flags: [...flags, 'privacy_safe_copy'],
        ),
      WomenIbadahStatus.normal => const WomenModeContentDecision(
          allowPrayerSession: true,
          preferDuaDhikrReflection: false,
          lockScreenSensitiveHidden: false,
          flags: ['standard_content'],
        ),
    };
  }
}
