import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('id')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sakinah Daily'**
  String get appTitle;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Begin with calm worship'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language and preferences for a quiet daily companion.'**
  String get onboardingSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @genderMode.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get genderMode;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderPreferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get genderPreferNotToSay;

  /// No description provided for @audioPreference.
  ///
  /// In en, this message translates to:
  /// **'Audio preference'**
  String get audioPreference;

  /// No description provided for @audioRecitationOnly.
  ///
  /// In en, this message translates to:
  /// **'Recitation only'**
  String get audioRecitationOnly;

  /// No description provided for @audioQuietGuidance.
  ///
  /// In en, this message translates to:
  /// **'Quiet guidance'**
  String get audioQuietGuidance;

  /// No description provided for @audioTextFirst.
  ///
  /// In en, this message translates to:
  /// **'Text first'**
  String get audioTextFirst;

  /// No description provided for @prayerReminderConsent.
  ///
  /// In en, this message translates to:
  /// **'Prayer reminders ask permission only after this explanation.'**
  String get prayerReminderConsent;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Assalamu alaikum'**
  String get homeGreeting;

  /// No description provided for @homeFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get homeFriend;

  /// No description provided for @homeFemaleName.
  ///
  /// In en, this message translates to:
  /// **'Aisha'**
  String get homeFemaleName;

  /// No description provided for @homeDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Tuesday · 12 Ramadan'**
  String get homeDateLabel;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next prayer'**
  String get nextPrayer;

  /// No description provided for @todaySession.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sakinah Session'**
  String get todaySession;

  /// No description provided for @sessionSubtitleMeta.
  ///
  /// In en, this message translates to:
  /// **'7 min · Ayah · Reflection · Dua · Dhikr'**
  String get sessionSubtitleMeta;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get startSession;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @voiceOnly.
  ///
  /// In en, this message translates to:
  /// **'Voice only'**
  String get voiceOnly;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @quran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quran;

  /// No description provided for @qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// No description provided for @tonight.
  ///
  /// In en, this message translates to:
  /// **'Tonight'**
  String get tonight;

  /// No description provided for @sleepAyatKursi.
  ///
  /// In en, this message translates to:
  /// **'Sleep with Ayat al-Kursi'**
  String get sleepAyatKursi;

  /// No description provided for @sleepSessionDescription.
  ///
  /// In en, this message translates to:
  /// **'A quiet 5-minute session with pure Qur\'an recitation and soft guidance.'**
  String get sleepSessionDescription;

  /// No description provided for @saveTonight.
  ///
  /// In en, this message translates to:
  /// **'Save tonight'**
  String get saveTonight;

  /// No description provided for @dua.
  ///
  /// In en, this message translates to:
  /// **'Dua'**
  String get dua;

  /// No description provided for @dhikr.
  ///
  /// In en, this message translates to:
  /// **'Dhikr'**
  String get dhikr;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @prayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get prayer;

  /// No description provided for @prayerMethod.
  ///
  /// In en, this message translates to:
  /// **'Prayer method'**
  String get prayerMethod;

  /// No description provided for @prayerReminders.
  ///
  /// In en, this message translates to:
  /// **'Prayer reminders'**
  String get prayerReminders;

  /// No description provided for @prayerReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permission is requested after explanation.'**
  String get prayerReminderSubtitle;

  /// No description provided for @womenModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local-only by default. Sensitive reminder copy stays private.'**
  String get womenModeSubtitle;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Women\'s mode data is not sent remotely in MVP.'**
  String get privacySubtitle;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @reviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get reviewed;

  /// No description provided for @approvedContent.
  ///
  /// In en, this message translates to:
  /// **'approved content'**
  String get approvedContent;

  /// No description provided for @draftContent.
  ///
  /// In en, this message translates to:
  /// **'draft content'**
  String get draftContent;

  /// No description provided for @inReviewContent.
  ///
  /// In en, this message translates to:
  /// **'in review content'**
  String get inReviewContent;

  /// No description provided for @rejectedContent.
  ///
  /// In en, this message translates to:
  /// **'rejected content'**
  String get rejectedContent;

  /// No description provided for @womenMode.
  ///
  /// In en, this message translates to:
  /// **'Women\'s Ibadah Mode'**
  String get womenMode;

  /// No description provided for @womenModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust reminders with privacy and respect.'**
  String get womenModeDescription;

  /// No description provided for @todaysMode.
  ///
  /// In en, this message translates to:
  /// **'Today\'s mode'**
  String get todaysMode;

  /// No description provided for @modeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get modeNormal;

  /// No description provided for @modeMenstruating.
  ///
  /// In en, this message translates to:
  /// **'Menstruating'**
  String get modeMenstruating;

  /// No description provided for @modePostpartum.
  ///
  /// In en, this message translates to:
  /// **'Postpartum'**
  String get modePostpartum;

  /// No description provided for @modePregnancy.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy'**
  String get modePregnancy;

  /// No description provided for @modePreferNotToTrack.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to track'**
  String get modePreferNotToTrack;

  /// No description provided for @dataStaysLocal.
  ///
  /// In en, this message translates to:
  /// **'Data stays local by default'**
  String get dataStaysLocal;

  /// No description provided for @recommendedNow.
  ///
  /// In en, this message translates to:
  /// **'Recommended now'**
  String get recommendedNow;

  /// No description provided for @gentleWorshipMoment.
  ///
  /// In en, this message translates to:
  /// **'A gentle worship moment'**
  String get gentleWorshipMoment;

  /// No description provided for @womenRecommendedDescription.
  ///
  /// In en, this message translates to:
  /// **'Dua · Dhikr · Reflection reminders without direct prayer prompts.'**
  String get womenRecommendedDescription;

  /// No description provided for @reminderBehavior.
  ///
  /// In en, this message translates to:
  /// **'Reminder behavior'**
  String get reminderBehavior;

  /// No description provided for @reminderBehaviorDescription.
  ///
  /// In en, this message translates to:
  /// **'Prayer alerts can be paused or replaced with Dua and Dhikr moments.'**
  String get reminderBehaviorDescription;

  /// No description provided for @duaUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Dua unavailable.'**
  String get duaUnavailable;

  /// No description provided for @makeDua.
  ///
  /// In en, this message translates to:
  /// **'Make Dua'**
  String get makeDua;

  /// No description provided for @duaContext.
  ///
  /// In en, this message translates to:
  /// **'For focus · Before work or study'**
  String get duaContext;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @arabicLabel.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabicLabel;

  /// No description provided for @transliteration.
  ///
  /// In en, this message translates to:
  /// **'Transliteration'**
  String get transliteration;

  /// No description provided for @meaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get meaning;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @repeatSlowly.
  ///
  /// In en, this message translates to:
  /// **'Repeat slowly'**
  String get repeatSlowly;

  /// No description provided for @session.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// No description provided for @sessionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Session unavailable.'**
  String get sessionUnavailable;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @playRecitation.
  ///
  /// In en, this message translates to:
  /// **'Play recitation'**
  String get playRecitation;

  /// No description provided for @approvedReciter.
  ///
  /// In en, this message translates to:
  /// **'approved reciter'**
  String get approvedReciter;

  /// No description provided for @quranSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Qur\'an Safety'**
  String get quranSafetyTitle;

  /// No description provided for @quranSafetyDescription.
  ///
  /// In en, this message translates to:
  /// **'No background sound is played under Qur\'an recitation.'**
  String get quranSafetyDescription;

  /// No description provided for @completionFallback.
  ///
  /// In en, this message translates to:
  /// **'Pause, breathe, and keep this act for Allah alone.'**
  String get completionFallback;

  /// No description provided for @backgroundSoundAllowed.
  ///
  /// In en, this message translates to:
  /// **'Background sound allowed'**
  String get backgroundSoundAllowed;

  /// No description provided for @noBackgroundMusic.
  ///
  /// In en, this message translates to:
  /// **'No background music under Quran recitation'**
  String get noBackgroundMusic;

  /// No description provided for @timeIn.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get timeIn;

  /// No description provided for @hourShort.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hourShort;

  /// No description provided for @minuteShort.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get minuteShort;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
