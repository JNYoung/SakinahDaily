import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/app/theme/sakinah_theme.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('home session card keeps text and CTA contrast high',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    _expectHeroTextContrast(tester, "Today's Sakinah Session");
    _expectHeroTextContrast(tester, 'Morning Ease');
    _expectHeroTextContrast(tester, '7 min · Ayah · Reflection · Dua · Dhikr');

    _expectButtonContrast(tester, SakinahKeys.homeSessionStartButton);
    _expectButtonContrast(tester, SakinahKeys.homeVoiceOnlyButton);
    expectNoFlutterErrors(tester);
  });
}

void _expectHeroTextContrast(WidgetTester tester, String text) {
  final textWidget = tester.widget<Text>(find.text(text));
  final textColor = textWidget.style?.color;
  expect(textColor, isNotNull);
  expect(
    _contrastRatio(SakinahColors.deepEmerald, textColor!),
    greaterThanOrEqualTo(7),
  );
}

void _expectButtonContrast(WidgetTester tester, Key key) {
  final button = tester.widget<FilledButton>(find.byKey(key));
  final buttonStyle = button.style;
  expect(buttonStyle?.backgroundColor, isNotNull);
  expect(buttonStyle?.foregroundColor, isNotNull);

  final background = buttonStyle!.backgroundColor!.resolve(<WidgetState>{})!;
  final foreground = buttonStyle.foregroundColor!.resolve(<WidgetState>{})!;

  expect(_contrastRatio(background, foreground), greaterThanOrEqualTo(7));
}

double _contrastRatio(Color background, Color foreground) {
  final foregroundOnBackground = Color.alphaBlend(foreground, background);
  final backgroundLuminance = background.computeLuminance();
  final foregroundLuminance = foregroundOnBackground.computeLuminance();
  final lighter = math.max(backgroundLuminance, foregroundLuminance);
  final darker = math.min(backgroundLuminance, foregroundLuminance);
  return (lighter + 0.05) / (darker + 0.05);
}
