import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/localization/sakinah_localizations.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  test('ARB files and runtime localizations expose the same keys', () {
    final keySets = {
      for (final locale in ['en', 'id', 'ar']) locale: _arbKeys(locale),
    };

    expect(keySets['id'], keySets['en']);
    expect(keySets['ar'], keySets['en']);

    for (final locale in SakinahLocalizations.supportedLocales) {
      final l10n = SakinahLocalizations(locale);
      for (final key in keySets['en']!) {
        expect(
          l10n.t(key),
          isNot(key),
          reason: '${locale.languageCode} is missing $key',
        );
      }
    }
  });

  testWidgets('Indonesian copy is consistent across onboarding, home, settings',
      (tester) async {
    await pumpSakinahApp(tester, languageCode: 'id');

    expect(find.text('Mulai dengan ibadah yang tenang'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);

    await continueToHome(tester);

    expect(find.text('Sesi Sakinah Hari Ini'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);

    expect(find.text('Pengaturan'), findsWidgets);
    expect(find.text('Bahasa'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Arabic copy uses RTL and remains Arabic after navigation',
      (tester) async {
    await pumpSakinahApp(tester, languageCode: 'ar');

    final directionality = tester.widget<Directionality>(
      find
          .ancestor(
            of: find.text('ابدأ بعبادة هادئة'),
            matching: find.byType(Directionality),
          )
          .first,
    );
    expect(directionality.textDirection, TextDirection.rtl);
    expect(find.text('متابعة'), findsOneWidget);

    await continueToHome(tester);

    expect(find.text('السلام عليكم,'), findsOneWidget);
    expect(find.text('جلسة السكينة اليوم'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Indonesian settings and women mode do not show English UI copy',
      (tester) async {
    await pumpSakinahApp(tester, languageCode: 'id');
    await continueToHome(tester);

    expect(find.text('Aksi Cepat'), findsOneWidget);
    expect(find.text('Quick Actions'), findsNothing);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);

    expect(find.text('Metode shalat'), findsOneWidget);
    expect(find.text('Pengingat shalat'), findsOneWidget);
    expect(find.text('Prayer method'), findsNothing);
    expect(find.text('Prayer reminders'), findsNothing);

    await tapByKey(tester, SakinahKeys.settingsWomenModeTile);

    expect(find.text('Mode Ibadah Perempuan'), findsWidgets);
    expect(find.text('Data tetap lokal secara default'), findsOneWidget);
    expect(find.text('Direkomendasikan sekarang'), findsOneWidget);
    expect(find.text("Women's Ibadah Mode"), findsNothing);
    expect(find.text('Data stays local by default'), findsNothing);
    expect(find.text('Recommended now'), findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Arabic settings and women mode do not show English UI copy',
      (tester) async {
    await pumpSakinahApp(tester, languageCode: 'ar');
    await continueToHome(tester);

    expect(find.text('إجراءات سريعة'), findsOneWidget);
    expect(find.text('Quick Actions'), findsNothing);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);

    expect(find.text('طريقة الصلاة'), findsOneWidget);
    expect(find.text('تذكيرات الصلاة'), findsOneWidget);
    expect(find.text('Prayer method'), findsNothing);
    expect(find.text('Prayer reminders'), findsNothing);

    await tapByKey(tester, SakinahKeys.settingsWomenModeTile);

    expect(find.text('وضع عبادة النساء'), findsWidgets);
    expect(find.text('تبقى البيانات محلية افتراضيا'), findsOneWidget);
    expect(find.text('موصى به الآن'), findsOneWidget);
    expect(find.text("Women's Ibadah Mode"), findsNothing);
    expect(find.text('Data stays local by default'), findsNothing);
    expect(find.text('Recommended now'), findsNothing);
    expectNoFlutterErrors(tester);
  });
}

Set<String> _arbKeys(String locale) {
  final raw = File('lib/l10n/app_$locale.arb').readAsStringSync();
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return json.keys
      .where((key) => !key.startsWith('@') && key != '@@locale')
      .toSet();
}
