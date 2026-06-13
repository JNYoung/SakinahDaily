import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/config/app_environment.dart';
import 'package:sakinah_daily/core/localization/sakinah_localizations.dart';
import 'package:sakinah_daily/core/models/saved_item.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/saved_items_repository.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
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
    expect(
      find.text('Waktu shalat dan Kiblat memakai lokasi shalat lokal ini.'),
      findsOneWidget,
    );
    expect(find.text('Izin GPS tidak diminta di v0.1.'), findsOneWidget);
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
    expect(
      find.text('تستخدم أوقات الصلاة والقبلة موقع الصلاة المحلي هذا.'),
      findsOneWidget,
    );
    expect(find.text('لا يتم طلب إذن GPS في v0.1.'), findsOneWidget);
    expect(find.text('متابعة'), findsOneWidget);

    await continueToHome(tester);

    expect(find.text('السلام عليكم,'), findsOneWidget);
    expect(find.text('جلسة السكينة اليوم'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('home prayer status chips use localized labels', (tester) async {
    await pumpSakinahApp(
      tester,
      languageCode: 'id',
      initialLocation: '/home',
      settleSplash: false,
      preferencesStore: await _preferencesStoreWithLanguage('id'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lokasi shalat · Makkah'), findsOneWidget);
    expect(find.text('Metode shalat · Umm al-Qura'), findsOneWidget);
    expect(find.text('Pengingat shalat · Nonaktif'), findsOneWidget);
    expect(find.text('Prayer location · Makkah'), findsNothing);

    await pumpSakinahApp(
      tester,
      languageCode: 'ar',
      initialLocation: '/home',
      settleSplash: false,
      preferencesStore: await _preferencesStoreWithLanguage('ar'),
    );
    await tester.pumpAndSettle();

    expect(find.text('موقع الصلاة · Makkah'), findsOneWidget);
    expect(find.text('طريقة الصلاة · Umm al-Qura'), findsOneWidget);
    expect(find.text('تذكيرات الصلاة · متوقف'), findsOneWidget);
    expect(find.text('Prayer location · Makkah'), findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets('closed testing Home guide entry is localized', (tester) async {
    final config = AppEnvironmentConfig.fromMap(
      const {
        'SAKINAH_APP_ENV': 'prod',
        'SAKINAH_PLAY_TESTING_FEEDBACK': 'support@sakinahdaily.app',
      },
    );

    await pumpSakinahApp(
      tester,
      languageCode: 'id',
      initialLocation: '/home',
      settleSplash: false,
      preferencesStore: await _preferencesStoreWithLanguage('id'),
      appEnvironmentConfig: config,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.homeClosedTestingGuideCard), findsOneWidget);
    expect(find.text('Panduan closed testing'), findsOneWidget);
    expect(
      find.textContaining('Hari 1 / Hari 3 / Hari 7 / Hari 14'),
      findsOneWidget,
    );
    expect(find.text('Closed testing guide'), findsNothing);

    await pumpSakinahApp(
      tester,
      languageCode: 'ar',
      initialLocation: '/home',
      settleSplash: false,
      preferencesStore: await _preferencesStoreWithLanguage('ar'),
      appEnvironmentConfig: config,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.homeClosedTestingGuideCard), findsOneWidget);
    expect(find.text('دليل الاختبار المغلق'), findsOneWidget);
    expect(
      find.textContaining('اليوم 1 / اليوم 3 / اليوم 7 / اليوم 14'),
      findsOneWidget,
    );
    expect(find.text('Closed testing guide'), findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets('prayer all-day section heading is localized', (tester) async {
    await pumpSakinahApp(
      tester,
      languageCode: 'id',
      initialLocation: '/prayer',
      settleSplash: false,
      preferencesStore: await _preferencesStoreWithLanguage('id'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Waktu shalat hari ini'), findsOneWidget);
    expect(find.text("Today's prayer times"), findsNothing);

    await pumpSakinahApp(
      tester,
      languageCode: 'ar',
      initialLocation: '/prayer',
      settleSplash: false,
      preferencesStore: await _preferencesStoreWithLanguage('ar'),
    );
    await tester.pumpAndSettle();

    expect(find.text('أوقات الصلاة اليوم'), findsOneWidget);
    expect(find.text("Today's prayer times"), findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets(
      'release-critical prayer path is localized across English Indonesian and Arabic',
      (tester) async {
    final cases = const [
      _ReleasePathExpectations(
        languageCode: 'en',
        homeTitle: 'Daily prayer at the center',
        prayerTimesButton: 'View prayer times',
        homeReminderButton: 'Enable reminders',
        prayerReminderButton: 'Enable reminders',
        sessionTitle: "Today's Sakinah Session",
        sessionMeta: '7 min · Ayah · Reflection · Dua · Dhikr',
        startButton: 'Start',
        homeNav: 'Home',
        prayerNav: 'Prayer',
        sessionNav: 'Session',
        settingsNav: 'Settings',
        prayerTitle: 'Prayer',
        nextPrayer: 'Next prayer',
        changeLocationButton: 'Change location',
        todaysPrayerTimes: "Today's prayer times",
        settingsTitle: 'Settings',
        language: 'Language',
        prayerLocation: 'Prayer location',
        prayerMethod: 'Prayer method',
        prayerReminders: 'Prayer reminders',
        notificationSettings: 'Notification settings',
      ),
      _ReleasePathExpectations(
        languageCode: 'id',
        homeTitle: 'Shalat harian sebagai pusat',
        prayerTimesButton: 'Lihat waktu shalat',
        homeReminderButton: 'Aktifkan pengingat',
        prayerReminderButton: 'Aktifkan pengingat',
        sessionTitle: 'Sesi Sakinah Hari Ini',
        sessionMeta: '7 menit · Ayat · Refleksi · Doa · Dzikir',
        startButton: 'Mulai',
        homeNav: 'Beranda',
        prayerNav: 'Shalat',
        sessionNav: 'Sesi',
        settingsNav: 'Pengaturan',
        prayerTitle: 'Shalat',
        nextPrayer: 'Shalat berikutnya',
        changeLocationButton: 'Ubah lokasi',
        todaysPrayerTimes: 'Waktu shalat hari ini',
        settingsTitle: 'Pengaturan',
        language: 'Bahasa',
        prayerLocation: 'Lokasi shalat',
        prayerMethod: 'Metode shalat',
        prayerReminders: 'Pengingat shalat',
        notificationSettings: 'Pengaturan notifikasi',
        forbiddenButtonLabels: [
          'View prayer times',
          'Manage reminders',
          'Enable reminders',
          'Change location',
          'Start',
        ],
      ),
      _ReleasePathExpectations(
        languageCode: 'ar',
        homeTitle: 'الصلاة اليومية في المركز',
        prayerTimesButton: 'عرض أوقات الصلاة',
        homeReminderButton: 'تفعيل التذكيرات',
        prayerReminderButton: 'تفعيل التذكيرات',
        sessionTitle: 'جلسة السكينة اليوم',
        sessionMeta: '7 دقائق · آية · تأمل · دعاء · ذكر',
        startButton: 'ابدأ',
        homeNav: 'الرئيسية',
        prayerNav: 'الصلاة',
        sessionNav: 'الجلسة',
        settingsNav: 'الإعدادات',
        prayerTitle: 'الصلاة',
        nextPrayer: 'الصلاة التالية',
        changeLocationButton: 'تغيير الموقع',
        todaysPrayerTimes: 'أوقات الصلاة اليوم',
        settingsTitle: 'الإعدادات',
        language: 'اللغة',
        prayerLocation: 'موقع الصلاة',
        prayerMethod: 'طريقة الصلاة',
        prayerReminders: 'تذكيرات الصلاة',
        notificationSettings: 'إعدادات الإشعارات',
        textDirection: TextDirection.rtl,
        forbiddenButtonLabels: [
          'View prayer times',
          'Manage reminders',
          'Enable reminders',
          'Change location',
          'Start',
        ],
      ),
    ];

    for (final localeCase in cases) {
      await _expectLocalizedReleasePath(tester, localeCase);
    }

    const idL10n = SakinahLocalizations(Locale('id'));
    expect(idL10n.t('dua'), 'Doa');
    expect(idL10n.t('dhikr'), 'Dzikir');
    expect(idL10n.t('prayer'), 'Shalat');
    expect(idL10n.t('qibla'), 'Kiblat');
    expect(idL10n.t('onboardingPrayerLocationBody'), contains('shalat'));
    expect(idL10n.t('onboardingPrayerLocationBody'), contains('Kiblat'));
    expectNoFlutterErrors(tester);
  });

  testWidgets('reflection no-fatwa safety note is localized', (tester) async {
    await pumpSakinahApp(
      tester,
      languageCode: 'id',
      initialLocation: '/session/session_morning_ease',
      settleSplash: false,
      preferencesStore: await _preferencesStoreWithLanguage('id'),
    );
    await tester.pumpAndSettle();
    await tapByKey(tester, SakinahKeys.sessionNextButton);
    await tapByKey(tester, SakinahKeys.sessionNextButton);

    expect(find.text('Catatan renungan'), findsOneWidget);
    expect(
      find.text(
        'Renungan adalah pengingat lembut, bukan fatwa atau putusan agama.',
      ),
      findsOneWidget,
    );
    expect(find.text('Reflection note'), findsNothing);

    await pumpSakinahApp(
      tester,
      languageCode: 'ar',
      initialLocation: '/session/session_morning_ease',
      settleSplash: false,
      preferencesStore: await _preferencesStoreWithLanguage('ar'),
    );
    await tester.pumpAndSettle();
    await tapByKey(tester, SakinahKeys.sessionNextButton);
    await tapByKey(tester, SakinahKeys.sessionNextButton);

    expect(find.text('ملاحظة التأمل'), findsOneWidget);
    expect(
      find.text('التأمل تذكير لطيف وليس فتوى أو حكما دينيا.'),
      findsOneWidget,
    );
    expect(find.text('Reflection note'), findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets('home saved rail uses localized labels', (tester) async {
    final idSavedStore = InMemorySavedItemsStore();
    await SavedItemsRepository(idSavedStore).save(
      _savedDua(languageCode: 'id', title: 'Ketenangan'),
    );

    await pumpSakinahApp(
      tester,
      languageCode: 'id',
      initialLocation: '/home',
      settleSplash: false,
      preferencesStore: await _preferencesStoreWithLanguage('id'),
      savedItemsStore: idSavedStore,
    );
    await tester.pumpAndSettle();
    await scrollUntilFound(tester, find.byKey(SakinahKeys.homeSavedRail));

    expect(find.text('Lanjutkan dari tersimpan'), findsOneWidget);
    expect(find.text('Disimpan lokal di perangkat ini.'), findsOneWidget);
    expect(find.text('Continue from saved'), findsNothing);

    final arSavedStore = InMemorySavedItemsStore();
    await SavedItemsRepository(arSavedStore).save(
      _savedDua(languageCode: 'ar', title: 'طمأنينة'),
    );

    await pumpSakinahApp(
      tester,
      languageCode: 'ar',
      initialLocation: '/home',
      settleSplash: false,
      preferencesStore: await _preferencesStoreWithLanguage('ar'),
      savedItemsStore: arSavedStore,
    );
    await tester.pumpAndSettle();
    await scrollUntilFound(tester, find.byKey(SakinahKeys.homeSavedRail));

    expect(find.text('تابع من المحفوظ'), findsOneWidget);
    expect(find.text('محفوظ محليا على هذا الجهاز.'), findsOneWidget);
    expect(find.text('Continue from saved'), findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Indonesian settings and women mode do not show English UI copy',
      (tester) async {
    await pumpSakinahApp(tester, languageCode: 'id');
    await continueToHome(tester);

    expect(find.text('Shalat harian sebagai pusat'), findsOneWidget);
    expect(find.text('Quick Actions'), findsNothing);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);

    expect(find.text('Metode shalat'), findsOneWidget);
    expect(find.text('Pengingat shalat'), findsOneWidget);
    expect(find.text('Mode Ibadah Perempuan'), findsNothing);
    expect(find.text('Prayer method'), findsNothing);
    expect(find.text('Prayer reminders'), findsNothing);

    await pumpSakinahApp(
      tester,
      languageCode: 'id',
      initialLocation: '/settings/women',
      settleSplash: false,
      preferencesStore: await _preferencesStoreWithLanguage('id'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mode Ibadah Perempuan'), findsWidgets);
    expect(find.text('Data tetap lokal secara default'), findsOneWidget);
    await scrollUntilFound(
        tester, find.byKey(SakinahKeys.womenModeRecommendedCard));
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

    expect(find.text('الصلاة اليومية في المركز'), findsOneWidget);
    expect(find.text('Quick Actions'), findsNothing);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);

    expect(find.text('طريقة الصلاة'), findsOneWidget);
    expect(find.text('تذكيرات الصلاة'), findsOneWidget);
    expect(find.text('وضع عبادة النساء'), findsNothing);
    expect(find.text('Prayer method'), findsNothing);
    expect(find.text('Prayer reminders'), findsNothing);

    await pumpSakinahApp(
      tester,
      languageCode: 'ar',
      initialLocation: '/settings/women',
      settleSplash: false,
      preferencesStore: await _preferencesStoreWithLanguage('ar'),
    );
    await tester.pumpAndSettle();

    expect(find.text('وضع عبادة النساء'), findsWidgets);
    expect(find.text('تبقى البيانات محلية افتراضيا'), findsOneWidget);
    await scrollUntilFound(
        tester, find.byKey(SakinahKeys.womenModeRecommendedCard));
    expect(find.text('موصى به الآن'), findsOneWidget);
    expect(find.text("Women's Ibadah Mode"), findsNothing);
    expect(find.text('Data stays local by default'), findsNothing);
    expect(find.text('Recommended now'), findsNothing);
    expectNoFlutterErrors(tester);
  });
}

Future<InMemoryUserPreferencesStore> _preferencesStoreWithLanguage(
  String languageCode,
) async {
  final store = InMemoryUserPreferencesStore();
  await UserPreferencesRepository(store).save(
    UserPreferences.defaults().copyWith(languageCode: languageCode),
  );
  return store;
}

Future<void> _expectLocalizedReleasePath(
  WidgetTester tester,
  _ReleasePathExpectations expected,
) async {
  await pumpSakinahApp(
    tester,
    languageCode: expected.languageCode,
    initialLocation: '/home',
    settleSplash: false,
    preferencesStore: await _preferencesStoreWithLanguage(
      expected.languageCode,
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text(expected.homeTitle), findsOneWidget);
  expect(find.text(expected.prayerTimesButton), findsOneWidget);
  expect(find.text(expected.homeReminderButton), findsOneWidget);
  expect(find.text(expected.sessionTitle), findsOneWidget);
  expect(find.text(expected.sessionMeta), findsOneWidget);
  expect(find.text(expected.startButton), findsOneWidget);
  expect(find.text(expected.homeNav), findsWidgets);
  expect(find.text(expected.prayerNav), findsWidgets);
  expect(find.text(expected.sessionNav), findsWidgets);
  expect(find.text(expected.settingsNav), findsWidgets);

  if (expected.textDirection != null) {
    final directionality = tester.widget<Directionality>(
      find
          .ancestor(
            of: find.text(expected.homeTitle),
            matching: find.byType(Directionality),
          )
          .first,
    );
    expect(directionality.textDirection, expected.textDirection);
  }

  for (final forbiddenLabel in expected.forbiddenButtonLabels) {
    expect(find.text(forbiddenLabel), findsNothing);
  }

  await pumpSakinahApp(
    tester,
    languageCode: expected.languageCode,
    initialLocation: '/prayer',
    settleSplash: false,
    preferencesStore: await _preferencesStoreWithLanguage(
      expected.languageCode,
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text(expected.prayerTitle), findsWidgets);
  expect(find.text(expected.nextPrayer), findsOneWidget);
  expect(find.text(expected.prayerReminderButton), findsOneWidget);
  expect(find.text(expected.changeLocationButton), findsOneWidget);
  expect(find.text(expected.todaysPrayerTimes), findsOneWidget);

  for (final forbiddenLabel in expected.forbiddenButtonLabels) {
    expect(find.text(forbiddenLabel), findsNothing);
  }

  await pumpSakinahApp(
    tester,
    languageCode: expected.languageCode,
    initialLocation: '/settings',
    settleSplash: false,
    preferencesStore: await _preferencesStoreWithLanguage(
      expected.languageCode,
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text(expected.settingsTitle), findsWidgets);
  expect(find.text(expected.language), findsOneWidget);
  expect(find.text(expected.prayerLocation), findsOneWidget);
  expect(find.text(expected.prayerMethod), findsOneWidget);
  expect(find.text(expected.prayerReminders), findsOneWidget);
  expect(find.text(expected.notificationSettings), findsOneWidget);
}

class _ReleasePathExpectations {
  const _ReleasePathExpectations({
    required this.languageCode,
    required this.homeTitle,
    required this.prayerTimesButton,
    required this.homeReminderButton,
    required this.prayerReminderButton,
    required this.sessionTitle,
    required this.sessionMeta,
    required this.startButton,
    required this.homeNav,
    required this.prayerNav,
    required this.sessionNav,
    required this.settingsNav,
    required this.prayerTitle,
    required this.nextPrayer,
    required this.changeLocationButton,
    required this.todaysPrayerTimes,
    required this.settingsTitle,
    required this.language,
    required this.prayerLocation,
    required this.prayerMethod,
    required this.prayerReminders,
    required this.notificationSettings,
    this.textDirection,
    this.forbiddenButtonLabels = const [],
  });

  final String languageCode;
  final String homeTitle;
  final String prayerTimesButton;
  final String homeReminderButton;
  final String prayerReminderButton;
  final String sessionTitle;
  final String sessionMeta;
  final String startButton;
  final String homeNav;
  final String prayerNav;
  final String sessionNav;
  final String settingsNav;
  final String prayerTitle;
  final String nextPrayer;
  final String changeLocationButton;
  final String todaysPrayerTimes;
  final String settingsTitle;
  final String language;
  final String prayerLocation;
  final String prayerMethod;
  final String prayerReminders;
  final String notificationSettings;
  final TextDirection? textDirection;
  final List<String> forbiddenButtonLabels;
}

SavedItem _savedDua({
  required String languageCode,
  required String title,
}) {
  return SavedItem(
    id: SavedItem.stableId(SavedItemType.dua, 'dua_ease'),
    itemType: SavedItemType.dua,
    itemId: 'dua_ease',
    titleSnapshot: title,
    subtitleSnapshot: 'Dua',
    sourceLabel: 'Ibn Hibban',
    createdAt: DateTime.utc(2026, 6, 10),
    languageCode: languageCode,
  );
}

Set<String> _arbKeys(String locale) {
  final raw = File('lib/l10n/app_$locale.arb').readAsStringSync();
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return json.keys
      .where((key) => !key.startsWith('@') && key != '@@locale')
      .toSet();
}
