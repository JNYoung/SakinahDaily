import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/services/women_mode_content_policy.dart';

void main() {
  const policy = WomenModeContentPolicy();

  test('disabled mode allows standard content', () {
    final decision = policy.evaluate(const WomenIbadahMode(enabled: false));

    expect(decision.allowPrayerSession, isTrue);
    expect(decision.preferDuaDhikrReflection, isFalse);
    expect(decision.lockScreenSensitiveHidden, isFalse);
    expect(decision.flags, contains('standard_content'));
  });

  test('menstruating and postpartum prefer dua dhikr reflection', () {
    for (final status in [
      WomenIbadahStatus.menstruating,
      WomenIbadahStatus.postpartum,
    ]) {
      final decision = policy.evaluate(
        WomenIbadahMode(enabled: true, status: status),
      );

      expect(decision.allowPrayerSession, isFalse);
      expect(decision.preferDuaDhikrReflection, isTrue);
      expect(decision.lockScreenSensitiveHidden, isTrue);
      expect(decision.flags, contains('prefer_dua_dhikr_reflection'));
      expect(decision.flags, contains('no_exact_status_exposed'));
    }
  });

  test('pregnancy keeps standard content with gentle support', () {
    final decision = policy.evaluate(
      const WomenIbadahMode(
        enabled: true,
        status: WomenIbadahStatus.pregnancy,
      ),
    );

    expect(decision.allowPrayerSession, isTrue);
    expect(decision.preferDuaDhikrReflection, isFalse);
    expect(decision.flags, contains('gentle_support'));
    expect(decision.flags, contains('no_exact_status_exposed'));
  });

  test('prefer not to track exposes no exact state', () {
    final decision = policy.evaluate(
      const WomenIbadahMode(
        enabled: true,
        status: WomenIbadahStatus.preferNotToTrack,
      ),
    );

    expect(decision.allowPrayerSession, isTrue);
    expect(decision.preferDuaDhikrReflection, isFalse);
    expect(decision.flags, contains('privacy_safe_copy'));
    expect(decision.flags, contains('no_exact_status_exposed'));
  });
}
