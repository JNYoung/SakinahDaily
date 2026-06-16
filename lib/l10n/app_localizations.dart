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

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Calm for the heart,\nremembrance for the day'**
  String get splashTagline;

  /// No description provided for @splashFeatureLine.
  ///
  /// In en, this message translates to:
  /// **'QURAN   ·   DUA   ·   DHIKR   ·   PRAYER'**
  String get splashFeatureLine;

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

  /// No description provided for @onboardingPrayerLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Prayer times and Qibla use this local prayer location.'**
  String get onboardingPrayerLocationBody;

  /// No description provided for @onboardingPrayerNoGps.
  ///
  /// In en, this message translates to:
  /// **'No GPS permission is requested in v0.1.'**
  String get onboardingPrayerNoGps;

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

  /// No description provided for @dailyPrayerHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily prayer at the center'**
  String get dailyPrayerHomeTitle;

  /// No description provided for @viewPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'View prayer times'**
  String get viewPrayerTimes;

  /// No description provided for @manageReminders.
  ///
  /// In en, this message translates to:
  /// **'Manage reminders'**
  String get manageReminders;

  /// No description provided for @changeLocation.
  ///
  /// In en, this message translates to:
  /// **'Change location'**
  String get changeLocation;

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

  /// No description provided for @quranPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quranPageTitle;

  /// No description provided for @featuredAyah.
  ///
  /// In en, this message translates to:
  /// **'Featured ayah'**
  String get featuredAyah;

  /// No description provided for @openAyah.
  ///
  /// In en, this message translates to:
  /// **'Open ayah'**
  String get openAyah;

  /// No description provided for @quranAvailableVerses.
  ///
  /// In en, this message translates to:
  /// **'Available verses'**
  String get quranAvailableVerses;

  /// No description provided for @quranLocalOnlyBrowserBody.
  ///
  /// In en, this message translates to:
  /// **'Browse reviewed local seed ayahs only. More Quran content requires approved sources.'**
  String get quranLocalOnlyBrowserBody;

  /// No description provided for @quranVerseSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by verse reference or meaning'**
  String get quranVerseSearchHint;

  /// No description provided for @quranVerseNoResults.
  ///
  /// In en, this message translates to:
  /// **'No reviewed local verse matches this search.'**
  String get quranVerseNoResults;

  /// No description provided for @quranVerseUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Quran verse unavailable'**
  String get quranVerseUnavailable;

  /// No description provided for @quranPreviousVerse.
  ///
  /// In en, this message translates to:
  /// **'Previous verse'**
  String get quranPreviousVerse;

  /// No description provided for @quranNextVerse.
  ///
  /// In en, this message translates to:
  /// **'Next verse'**
  String get quranNextVerse;

  /// No description provided for @saveAyah.
  ///
  /// In en, this message translates to:
  /// **'Save ayah'**
  String get saveAyah;

  /// No description provided for @savedAyah.
  ///
  /// In en, this message translates to:
  /// **'Saved ayah'**
  String get savedAyah;

  /// No description provided for @quranVoiceOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran recitation is voice-only'**
  String get quranVoiceOnlyTitle;

  /// No description provided for @quranVoiceOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'Quran recitation uses approved voice assets only and does not rely on synthetic Quran audio.'**
  String get quranVoiceOnlyBody;

  /// No description provided for @noQuranTts.
  ///
  /// In en, this message translates to:
  /// **'No Quran TTS'**
  String get noQuranTts;

  /// No description provided for @noQuranBgm.
  ///
  /// In en, this message translates to:
  /// **'No background music under Quran recitation'**
  String get noQuranBgm;

  /// No description provided for @qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// No description provided for @qiblaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla direction'**
  String get qiblaTitle;

  /// No description provided for @qiblaBearing.
  ///
  /// In en, this message translates to:
  /// **'Qibla bearing'**
  String get qiblaBearing;

  /// No description provided for @qiblaBasedOnSelectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Qibla uses your selected prayer location.'**
  String get qiblaBasedOnSelectedLocation;

  /// No description provided for @qiblaChangeLocation.
  ///
  /// In en, this message translates to:
  /// **'Change prayer location'**
  String get qiblaChangeLocation;

  /// No description provided for @qiblaNoGpsRequired.
  ///
  /// In en, this message translates to:
  /// **'Qibla uses your selected prayer location. Exact GPS is not required.'**
  String get qiblaNoGpsRequired;

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

  /// No description provided for @savedTonight.
  ///
  /// In en, this message translates to:
  /// **'Saved tonight'**
  String get savedTonight;

  /// No description provided for @sessionCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get sessionCompletedTitle;

  /// No description provided for @sessionCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'You completed this Sakinah session. Take a quiet moment before returning.'**
  String get sessionCompletedBody;

  /// No description provided for @completedToday.
  ///
  /// In en, this message translates to:
  /// **'Completed today'**
  String get completedToday;

  /// No description provided for @resumeSession.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeSession;

  /// No description provided for @reviewSession.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewSession;

  /// No description provided for @localProgress.
  ///
  /// In en, this message translates to:
  /// **'Local progress'**
  String get localProgress;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @completedThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Completed this week'**
  String get completedThisWeek;

  /// No description provided for @progressLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Progress stays on this device only.'**
  String get progressLocalOnly;

  /// No description provided for @prayersToday.
  ///
  /// In en, this message translates to:
  /// **'Prayers today'**
  String get prayersToday;

  /// No description provided for @prayerCheckInsLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Prayer check-ins stay on this device only.'**
  String get prayerCheckInsLocalOnly;

  /// No description provided for @continuePrayerCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Continue prayer check-in'**
  String get continuePrayerCheckIn;

  /// No description provided for @reviewPrayerCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Review prayer check-in'**
  String get reviewPrayerCheckIn;

  /// No description provided for @prayerWeekProgress.
  ///
  /// In en, this message translates to:
  /// **'Prayer week'**
  String get prayerWeekProgress;

  /// No description provided for @prayerWeekCheckInDays.
  ///
  /// In en, this message translates to:
  /// **'Check-in days'**
  String get prayerWeekCheckInDays;

  /// No description provided for @prayerWeekStreak.
  ///
  /// In en, this message translates to:
  /// **'Prayer streak'**
  String get prayerWeekStreak;

  /// No description provided for @saveSession.
  ///
  /// In en, this message translates to:
  /// **'Save session'**
  String get saveSession;

  /// No description provided for @sessionSaved.
  ///
  /// In en, this message translates to:
  /// **'Session saved'**
  String get sessionSaved;

  /// No description provided for @openSavedItems.
  ///
  /// In en, this message translates to:
  /// **'Open Saved Items'**
  String get openSavedItems;

  /// No description provided for @setDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Set daily reminder'**
  String get setDailyReminder;

  /// No description provided for @dailyReminderSet.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder set'**
  String get dailyReminderSet;

  /// No description provided for @manageDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Manage daily reminder'**
  String get manageDailyReminder;

  /// No description provided for @sessionReminderPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Set daily reminder?'**
  String get sessionReminderPermissionTitle;

  /// No description provided for @sessionReminderPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Sakinah can schedule a local daily session reminder. The reminder text stays privacy-safe on the lock screen.'**
  String get sessionReminderPermissionBody;

  /// No description provided for @sessionReminderPermissionAllow.
  ///
  /// In en, this message translates to:
  /// **'Set reminder'**
  String get sessionReminderPermissionAllow;

  /// No description provided for @sessionReminderPermissionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get sessionReminderPermissionNotNow;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get backHome;

  /// No description provided for @sessionProgressHistory.
  ///
  /// In en, this message translates to:
  /// **'Session progress history'**
  String get sessionProgressHistory;

  /// No description provided for @sessionProgressHistoryNotes.
  ///
  /// In en, this message translates to:
  /// **'Session progress and completion history are stored locally only.'**
  String get sessionProgressHistoryNotes;

  /// No description provided for @noGuaranteedOutcome.
  ///
  /// In en, this message translates to:
  /// **'No guaranteed spiritual outcome is claimed.'**
  String get noGuaranteedOutcome;

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

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @searchDuaHint.
  ///
  /// In en, this message translates to:
  /// **'Search duas'**
  String get searchDuaHint;

  /// No description provided for @searchDhikrHint.
  ///
  /// In en, this message translates to:
  /// **'Search dhikr'**
  String get searchDhikrHint;

  /// No description provided for @noDuaResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No duas found'**
  String get noDuaResultsTitle;

  /// No description provided for @noDuaResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try another category or search term.'**
  String get noDuaResultsBody;

  /// No description provided for @noDhikrResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No dhikr found'**
  String get noDhikrResultsTitle;

  /// No description provided for @noDhikrResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try another category or search term.'**
  String get noDhikrResultsBody;

  /// No description provided for @categoryQuranic.
  ///
  /// In en, this message translates to:
  /// **'Quranic'**
  String get categoryQuranic;

  /// No description provided for @categoryMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get categoryMorning;

  /// No description provided for @categoryEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get categoryEvening;

  /// No description provided for @categoryReflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get categoryReflection;

  /// No description provided for @categoryDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get categoryDifficulty;

  /// No description provided for @categoryGratitude.
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get categoryGratitude;

  /// No description provided for @categoryForgiveness.
  ///
  /// In en, this message translates to:
  /// **'Forgiveness'**
  String get categoryForgiveness;

  /// No description provided for @categoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get categoryGeneral;

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

  /// No description provided for @prayerLocation.
  ///
  /// In en, this message translates to:
  /// **'Prayer location'**
  String get prayerLocation;

  /// No description provided for @manualPrayerLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual prayer location'**
  String get manualPrayerLocationTitle;

  /// No description provided for @manualPrayerLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Enter a prayer location manually. It is stored locally and used for prayer times and Qibla.'**
  String get manualPrayerLocationBody;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location label'**
  String get locationLabel;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @timezoneId.
  ///
  /// In en, this message translates to:
  /// **'Timezone ID'**
  String get timezoneId;

  /// No description provided for @saveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save location'**
  String get saveLocation;

  /// No description provided for @invalidLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude must be between -90 and 90.'**
  String get invalidLatitude;

  /// No description provided for @invalidLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude must be between -180 and 180.'**
  String get invalidLongitude;

  /// No description provided for @locationSaved.
  ///
  /// In en, this message translates to:
  /// **'Location saved'**
  String get locationSaved;

  /// No description provided for @locationLocalOnlyNoGps.
  ///
  /// In en, this message translates to:
  /// **'Stored locally. No GPS permission is required.'**
  String get locationLocalOnlyNoGps;

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

  /// No description provided for @todaysPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Today\'s prayer times'**
  String get todaysPrayerTimes;

  /// No description provided for @currentPrayerStatus.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentPrayerStatus;

  /// No description provided for @nextPrayerStatus.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextPrayerStatus;

  /// No description provided for @todaysPrayerCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Today\'s prayer check-in'**
  String get todaysPrayerCheckIn;

  /// No description provided for @prayerCheckInBody.
  ///
  /// In en, this message translates to:
  /// **'Mark prayers you have completed. Stored locally only.'**
  String get prayerCheckInBody;

  /// No description provided for @todaysPrayerCheckInComplete.
  ///
  /// In en, this message translates to:
  /// **'Today\'s prayers are checked in'**
  String get todaysPrayerCheckInComplete;

  /// No description provided for @prayerCheckInCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your five prayer check-ins are saved on this device only.'**
  String get prayerCheckInCompleteBody;

  /// No description provided for @prayerCompletedStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get prayerCompletedStatus;

  /// No description provided for @prayerReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permission is requested after explanation.'**
  String get prayerReminderSubtitle;

  /// No description provided for @prayerReminderChoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer reminder choices'**
  String get prayerReminderChoicesTitle;

  /// No description provided for @prayerReminderChoicesBody.
  ///
  /// In en, this message translates to:
  /// **'Choose which prayer times can send local reminders.'**
  String get prayerReminderChoicesBody;

  /// No description provided for @prayerReminderChoiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Selected for reminder schedule'**
  String get prayerReminderChoiceSubtitle;

  /// No description provided for @prayerReminderLeadTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder timing'**
  String get prayerReminderLeadTimeTitle;

  /// No description provided for @prayerReminderLeadTimeBody.
  ///
  /// In en, this message translates to:
  /// **'Send each selected prayer reminder at the prayer time or a few minutes before.'**
  String get prayerReminderLeadTimeBody;

  /// No description provided for @nextPrayerReminderPreview.
  ///
  /// In en, this message translates to:
  /// **'Next prayer reminder'**
  String get nextPrayerReminderPreview;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable prayer reminders?'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Sakinah schedules local prayer reminders only after permission. Women\'s mode reminders stay privacy-safe on the lock screen.'**
  String get notificationPermissionBody;

  /// No description provided for @notificationPermissionAllow.
  ///
  /// In en, this message translates to:
  /// **'Enable reminders'**
  String get notificationPermissionAllow;

  /// No description provided for @notificationPermissionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notificationPermissionNotNow;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off. You can enable them from system settings.'**
  String get notificationPermissionDenied;

  /// No description provided for @notificationPermissionRecoveryBody.
  ///
  /// In en, this message translates to:
  /// **'After enabling notifications in system settings, return here and try reminders again.'**
  String get notificationPermissionRecoveryBody;

  /// No description provided for @notificationPermissionRecoveryButton.
  ///
  /// In en, this message translates to:
  /// **'Open notification settings'**
  String get notificationPermissionRecoveryButton;

  /// No description provided for @notificationPermissionRecoveryOpened.
  ///
  /// In en, this message translates to:
  /// **'System notification settings opened.'**
  String get notificationPermissionRecoveryOpened;

  /// No description provided for @notificationPermissionRecoveryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'System notification settings could not be opened from Sakinah.'**
  String get notificationPermissionRecoveryUnavailable;

  /// No description provided for @notificationScheduled.
  ///
  /// In en, this message translates to:
  /// **'Local prayer reminders are scheduled.'**
  String get notificationScheduled;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationSettingsTitle;

  /// No description provided for @notificationSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage prayer and daily session reminders.'**
  String get notificationSettingsSubtitle;

  /// No description provided for @closedTestingHomeBody.
  ///
  /// In en, this message translates to:
  /// **'Use the Day 1 / Day 3 / Day 7 / Day 14 prompts to send feedback without personal details.'**
  String get closedTestingHomeBody;

  /// No description provided for @closedTestingNextFeedback.
  ///
  /// In en, this message translates to:
  /// **'Next feedback'**
  String get closedTestingNextFeedback;

  /// No description provided for @closedTestingAllFeedbackSent.
  ///
  /// In en, this message translates to:
  /// **'All feedback marked sent'**
  String get closedTestingAllFeedbackSent;

  /// No description provided for @closedTestingHomeButton.
  ///
  /// In en, this message translates to:
  /// **'Open guide'**
  String get closedTestingHomeButton;

  /// No description provided for @closedTestingPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback prompts'**
  String get closedTestingPromptTitle;

  /// No description provided for @closedTestingPromptBody.
  ///
  /// In en, this message translates to:
  /// **'Use these checkpoints to send feedback that helps the 14-day closed test improve daily return.'**
  String get closedTestingPromptBody;

  /// No description provided for @closedTestingPromptDay1Label.
  ///
  /// In en, this message translates to:
  /// **'Day 1'**
  String get closedTestingPromptDay1Label;

  /// No description provided for @closedTestingPromptDay1.
  ///
  /// In en, this message translates to:
  /// **'Did onboarding explain location and notification choices clearly?'**
  String get closedTestingPromptDay1;

  /// No description provided for @closedTestingPromptDay3Label.
  ///
  /// In en, this message translates to:
  /// **'Day 3'**
  String get closedTestingPromptDay3Label;

  /// No description provided for @closedTestingPromptDay3.
  ///
  /// In en, this message translates to:
  /// **'Were prayer times, location, and reminder controls easy to trust?'**
  String get closedTestingPromptDay3;

  /// No description provided for @closedTestingPromptDay7Label.
  ///
  /// In en, this message translates to:
  /// **'Day 7'**
  String get closedTestingPromptDay7Label;

  /// No description provided for @closedTestingPromptDay7.
  ///
  /// In en, this message translates to:
  /// **'What made you want to reopen or ignore the app this week?'**
  String get closedTestingPromptDay7;

  /// No description provided for @closedTestingPromptDay14Label.
  ///
  /// In en, this message translates to:
  /// **'Day 14'**
  String get closedTestingPromptDay14Label;

  /// No description provided for @closedTestingPromptDay14.
  ///
  /// In en, this message translates to:
  /// **'What one change would most improve daily use before wider release?'**
  String get closedTestingPromptDay14;

  /// No description provided for @copyTestingFeedbackPrompt.
  ///
  /// In en, this message translates to:
  /// **'Copy prompt'**
  String get copyTestingFeedbackPrompt;

  /// No description provided for @closedTestingPromptCopied.
  ///
  /// In en, this message translates to:
  /// **'Feedback prompt copied.'**
  String get closedTestingPromptCopied;

  /// No description provided for @closedTestingPromptCopyHeader.
  ///
  /// In en, this message translates to:
  /// **'Sakinah Daily closed test feedback'**
  String get closedTestingPromptCopyHeader;

  /// No description provided for @closedTestingPromptCopyPromptLabel.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get closedTestingPromptCopyPromptLabel;

  /// No description provided for @closedTestingPromptCopyThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggested theme'**
  String get closedTestingPromptCopyThemeLabel;

  /// No description provided for @closedTestingPromptCopyChannelLabel.
  ///
  /// In en, this message translates to:
  /// **'Feedback channel'**
  String get closedTestingPromptCopyChannelLabel;

  /// No description provided for @closedTestingPromptCopyPrivacyLine.
  ///
  /// In en, this message translates to:
  /// **'Please avoid personal or sensitive health details.'**
  String get closedTestingPromptCopyPrivacyLine;

  /// No description provided for @closedTestingPromptFeedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Feedback sent'**
  String get closedTestingPromptFeedbackSent;

  /// No description provided for @closedTestingPromptLocalOnlyStatus.
  ///
  /// In en, this message translates to:
  /// **'Stored only on this device.'**
  String get closedTestingPromptLocalOnlyStatus;

  /// No description provided for @dailySessionReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily session reminder'**
  String get dailySessionReminderTitle;

  /// No description provided for @dailySessionReminderPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Session reminders are scheduled locally and keep lock-screen text privacy-safe.'**
  String get dailySessionReminderPrivacyNote;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @reminderTimeSaved.
  ///
  /// In en, this message translates to:
  /// **'Reminder time saved'**
  String get reminderTimeSaved;

  /// No description provided for @saveReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Save time'**
  String get saveReminderTime;

  /// No description provided for @reminderStatusOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get reminderStatusOn;

  /// No description provided for @reminderStatusOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get reminderStatusOff;

  /// No description provided for @notificationTapMalformed.
  ///
  /// In en, this message translates to:
  /// **'This notification could not be opened safely.'**
  String get notificationTapMalformed;

  /// No description provided for @notificationTapFallbackPrayer.
  ///
  /// In en, this message translates to:
  /// **'Opening prayer times.'**
  String get notificationTapFallbackPrayer;

  /// No description provided for @notificationTapMissingContent.
  ///
  /// In en, this message translates to:
  /// **'This notification content is not available offline yet.'**
  String get notificationTapMissingContent;

  /// No description provided for @womenModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local-only by default. Sensitive reminder copy stays private.'**
  String get womenModeSubtitle;

  /// No description provided for @localOnlyMode.
  ///
  /// In en, this message translates to:
  /// **'Local-only mode'**
  String get localOnlyMode;

  /// No description provided for @womenModePrivatePath.
  ///
  /// In en, this message translates to:
  /// **'Private gentle path'**
  String get womenModePrivatePath;

  /// No description provided for @womenModeHomeSupportBody.
  ///
  /// In en, this message translates to:
  /// **'Dua, dhikr, and reflection stay easy to reach. Your mode stays on this device.'**
  String get womenModeHomeSupportBody;

  /// No description provided for @womenModeSessionNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Local-only mode'**
  String get womenModeSessionNoteTitle;

  /// No description provided for @womenModeSessionNoteBody.
  ///
  /// In en, this message translates to:
  /// **'Your mode stays on this device. This session keeps a gentle worship-friendly path.'**
  String get womenModeSessionNoteBody;

  /// No description provided for @continueFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Continue from saved'**
  String get continueFromSaved;

  /// No description provided for @savedRailLocalNote.
  ///
  /// In en, this message translates to:
  /// **'Saved locally on this device.'**
  String get savedRailLocalNote;

  /// No description provided for @savedItems.
  ///
  /// In en, this message translates to:
  /// **'Saved Items'**
  String get savedItems;

  /// No description provided for @savedItemsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get savedItemsEmptyTitle;

  /// No description provided for @savedItemsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Saved items stay on this device for quick return later.'**
  String get savedItemsEmptyBody;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @unsave.
  ///
  /// In en, this message translates to:
  /// **'Unsave'**
  String get unsave;

  /// No description provided for @removeSavedItem.
  ///
  /// In en, this message translates to:
  /// **'Remove saved item'**
  String get removeSavedItem;

  /// No description provided for @savedLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Saved items stay on this device only.'**
  String get savedLocalOnly;

  /// No description provided for @savedItemsPrivacyNotes.
  ///
  /// In en, this message translates to:
  /// **'Saved locally. No account or sync in MVP.'**
  String get savedItemsPrivacyNotes;

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

  /// No description provided for @privacyCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Center'**
  String get privacyCenterTitle;

  /// No description provided for @dataInventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Data inventory'**
  String get dataInventoryTitle;

  /// No description provided for @dataInventoryBody.
  ///
  /// In en, this message translates to:
  /// **'This inventory describes MVP client data and where it is stored.'**
  String get dataInventoryBody;

  /// No description provided for @dataOnDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Data we keep on this device'**
  String get dataOnDeviceTitle;

  /// No description provided for @dataCanLeaveDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Data that can leave this device'**
  String get dataCanLeaveDeviceTitle;

  /// No description provided for @localOnlyData.
  ///
  /// In en, this message translates to:
  /// **'Most preferences, prayer settings, women’s mode, and content cache stay on this device.'**
  String get localOnlyData;

  /// No description provided for @leavesDeviceData.
  ///
  /// In en, this message translates to:
  /// **'Remote content requests may include language, market, app version, and schema version.'**
  String get leavesDeviceData;

  /// No description provided for @womenModePrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Women\'s Ibadah Mode privacy'**
  String get womenModePrivacyTitle;

  /// No description provided for @womenModePrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Women’s Ibadah Mode is designed local-first. Exact status is not sent with remote content requests.'**
  String get womenModePrivacyBody;

  /// No description provided for @prayerLocationPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer location privacy'**
  String get prayerLocationPrivacyTitle;

  /// No description provided for @prayerLocationPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Prayer location uses manual or preset choices by default for prayer time calculation.'**
  String get prayerLocationPrivacyBody;

  /// No description provided for @notificationPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications privacy'**
  String get notificationPrivacyTitle;

  /// No description provided for @notificationPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Prayer reminders are scheduled locally where possible, and sensitive women’s mode copy stays off the lock screen.'**
  String get notificationPrivacyBody;

  /// No description provided for @remoteContentPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Remote content cache'**
  String get remoteContentPrivacyTitle;

  /// No description provided for @remoteContentPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Approved content bundles can be cached on this device. Remote content requests may include language, market, app version, and schema version.'**
  String get remoteContentPrivacyBody;

  /// No description provided for @analyticsPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage analytics privacy'**
  String get analyticsPrivacyTitle;

  /// No description provided for @analyticsPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Usage analytics is default-off. If enabled in a reviewed build, Sakinah sends only whitelisted app-flow events and never sends exact coordinates, Women’s Ibadah Mode exact status, feedback text, or religious text.'**
  String get analyticsPrivacyBody;

  /// No description provided for @analyticsOptInTitle.
  ///
  /// In en, this message translates to:
  /// **'Share usage analytics'**
  String get analyticsOptInTitle;

  /// No description provided for @analyticsOptInAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'Optional. Helps improve prayer reminders and session retention with privacy-safe event names only.'**
  String get analyticsOptInAvailableBody;

  /// No description provided for @analyticsOptInUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Analytics collection is off in this build.'**
  String get analyticsOptInUnavailableBody;

  /// No description provided for @deleteLocalDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete local data'**
  String get deleteLocalDataTitle;

  /// No description provided for @deleteLocalDataBody.
  ///
  /// In en, this message translates to:
  /// **'Reset app preferences, saved items, session progress, women’s mode state, local content cache, and scheduled reminders on this device.'**
  String get deleteLocalDataBody;

  /// No description provided for @deleteLocalDataKeepsSeed.
  ///
  /// In en, this message translates to:
  /// **'Bundled seed content and app files are kept. This does not contact a remote service.'**
  String get deleteLocalDataKeepsSeed;

  /// No description provided for @deleteLocalDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete local data'**
  String get deleteLocalDataConfirm;

  /// No description provided for @deleteLocalDataDeleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get deleteLocalDataDeleting;

  /// No description provided for @deleteLocalDataDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm local reset'**
  String get deleteLocalDataDialogTitle;

  /// No description provided for @deleteLocalDataDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This clears local preferences, saved items, session progress, cached bundles, and scheduled reminders on this device.'**
  String get deleteLocalDataDialogBody;

  /// No description provided for @deleteLocalDataCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteLocalDataCancel;

  /// No description provided for @deleteLocalDataSuccess.
  ///
  /// In en, this message translates to:
  /// **'Local data has been reset on this device.'**
  String get deleteLocalDataSuccess;

  /// No description provided for @storePrivacyDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Store data safety summary'**
  String get storePrivacyDraftTitle;

  /// No description provided for @storePrivacyDraftBody.
  ///
  /// In en, this message translates to:
  /// **'Draft store declarations are documented for review before submission.'**
  String get storePrivacyDraftBody;

  /// No description provided for @privacyPolicyDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy draft'**
  String get privacyPolicyDraftTitle;

  /// No description provided for @privacyPolicyDraftBody.
  ///
  /// In en, this message translates to:
  /// **'A draft privacy policy exists for legal and store review.'**
  String get privacyPolicyDraftBody;

  /// No description provided for @contentSourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Content Sources'**
  String get contentSourcesTitle;

  /// No description provided for @contentSourcesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Source labels, review status, and AI limits.'**
  String get contentSourcesSubtitle;

  /// No description provided for @contentSourcesIntro.
  ///
  /// In en, this message translates to:
  /// **'Sakinah shows worship content with source and review guardrails so users can understand what they are reading or hearing.'**
  String get contentSourcesIntro;

  /// No description provided for @contentSourcesSeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviewed seed and approved bundles'**
  String get contentSourcesSeedTitle;

  /// No description provided for @contentSourcesSeedBody.
  ///
  /// In en, this message translates to:
  /// **'Quran, Dua, Dhikr, and session content shown in the app must come from reviewed seed content or approved CMS bundles.'**
  String get contentSourcesSeedBody;

  /// No description provided for @contentSourcesApprovalTitle.
  ///
  /// In en, this message translates to:
  /// **'Published + approved only'**
  String get contentSourcesApprovalTitle;

  /// No description provided for @contentSourcesApprovalBody.
  ///
  /// In en, this message translates to:
  /// **'Remote CMS content is hidden unless it is both published and approved. Draft, in-review, rejected, or revoked content is filtered out.'**
  String get contentSourcesApprovalBody;

  /// No description provided for @contentSourcesGeneratedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not generated'**
  String get contentSourcesGeneratedTitle;

  /// No description provided for @contentSourcesGeneratedBody.
  ///
  /// In en, this message translates to:
  /// **'The client does not generate Quran text, translations, Dua, Dhikr, reflection, or religious answers.'**
  String get contentSourcesGeneratedBody;

  /// No description provided for @contentSourcesAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran audio safety'**
  String get contentSourcesAudioTitle;

  /// No description provided for @contentSourcesAudioBody.
  ///
  /// In en, this message translates to:
  /// **'Quran recitation uses approved voice assets only. There is no generic Quran TTS and no background music under Quran recitation.'**
  String get contentSourcesAudioBody;

  /// No description provided for @contentSourcesFatwaTitle.
  ///
  /// In en, this message translates to:
  /// **'No AI fatwa or religious Q&A'**
  String get contentSourcesFatwaTitle;

  /// No description provided for @contentSourcesFatwaBody.
  ///
  /// In en, this message translates to:
  /// **'When a topic has school or regional differences, Sakinah uses neutral wording and source labels rather than fatwa-style claims.'**
  String get contentSourcesFatwaBody;

  /// No description provided for @storageLocalDevice.
  ///
  /// In en, this message translates to:
  /// **'Local device'**
  String get storageLocalDevice;

  /// No description provided for @storageRemoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Remote request'**
  String get storageRemoteOptional;

  /// No description provided for @storageNotCollected.
  ///
  /// In en, this message translates to:
  /// **'Not collected'**
  String get storageNotCollected;

  /// No description provided for @sensitivityLow.
  ///
  /// In en, this message translates to:
  /// **'Low sensitivity'**
  String get sensitivityLow;

  /// No description provided for @sensitivityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium sensitivity'**
  String get sensitivityMedium;

  /// No description provided for @sensitivityHigh.
  ///
  /// In en, this message translates to:
  /// **'High sensitivity'**
  String get sensitivityHigh;

  /// No description provided for @localOnlyShort.
  ///
  /// In en, this message translates to:
  /// **'Local only'**
  String get localOnlyShort;

  /// No description provided for @leavesDeviceShort.
  ///
  /// In en, this message translates to:
  /// **'Leaves device'**
  String get leavesDeviceShort;

  /// No description provided for @userCanDeleteShort.
  ///
  /// In en, this message translates to:
  /// **'User can delete'**
  String get userCanDeleteShort;

  /// No description provided for @privacyDataLanguagePreference.
  ///
  /// In en, this message translates to:
  /// **'Language preference'**
  String get privacyDataLanguagePreference;

  /// No description provided for @privacyDataLanguagePreferenceNotes.
  ///
  /// In en, this message translates to:
  /// **'Stored locally and used to choose app language and content language.'**
  String get privacyDataLanguagePreferenceNotes;

  /// No description provided for @privacyDataGenderModePreference.
  ///
  /// In en, this message translates to:
  /// **'Gender mode preference'**
  String get privacyDataGenderModePreference;

  /// No description provided for @privacyDataGenderModePreferenceNotes.
  ///
  /// In en, this message translates to:
  /// **'Stored locally for client personalization in MVP.'**
  String get privacyDataGenderModePreferenceNotes;

  /// No description provided for @privacyDataAudioPreference.
  ///
  /// In en, this message translates to:
  /// **'Audio preference'**
  String get privacyDataAudioPreference;

  /// No description provided for @privacyDataAudioPreferenceNotes.
  ///
  /// In en, this message translates to:
  /// **'Stored locally to choose recitation-only, guidance, or text-first behavior.'**
  String get privacyDataAudioPreferenceNotes;

  /// No description provided for @privacyDataPrayerSettings.
  ///
  /// In en, this message translates to:
  /// **'Prayer settings'**
  String get privacyDataPrayerSettings;

  /// No description provided for @privacyDataPrayerSettingsNotes.
  ///
  /// In en, this message translates to:
  /// **'Stored locally for prayer time method and calculation settings.'**
  String get privacyDataPrayerSettingsNotes;

  /// No description provided for @privacyDataPrayerLocationPreset.
  ///
  /// In en, this message translates to:
  /// **'Prayer location preset'**
  String get privacyDataPrayerLocationPreset;

  /// No description provided for @privacyDataPrayerLocationPresetNotes.
  ///
  /// In en, this message translates to:
  /// **'Stored locally by default as a manual or preset location choice.'**
  String get privacyDataPrayerLocationPresetNotes;

  /// No description provided for @privacyDataNotificationEnabledState.
  ///
  /// In en, this message translates to:
  /// **'Notification enabled state'**
  String get privacyDataNotificationEnabledState;

  /// No description provided for @privacyDataNotificationEnabledStateNotes.
  ///
  /// In en, this message translates to:
  /// **'Stored locally to remember prayer reminder status, per-prayer choices, prayer reminder lead-time offset, daily session reminder status, and the selected daily session reminder time.'**
  String get privacyDataNotificationEnabledStateNotes;

  /// No description provided for @privacyDataClosedTestingFeedbackStatus.
  ///
  /// In en, this message translates to:
  /// **'Closed testing feedback status'**
  String get privacyDataClosedTestingFeedbackStatus;

  /// No description provided for @privacyDataClosedTestingFeedbackStatusNotes.
  ///
  /// In en, this message translates to:
  /// **'Stores only whether Day 1, Day 3, Day 7, or Day 14 feedback was marked sent. Feedback text and personal details are not stored.'**
  String get privacyDataClosedTestingFeedbackStatusNotes;

  /// No description provided for @privacyDataWomenModeState.
  ///
  /// In en, this message translates to:
  /// **'Women\'s Ibadah Mode state'**
  String get privacyDataWomenModeState;

  /// No description provided for @privacyDataWomenModeStateNotes.
  ///
  /// In en, this message translates to:
  /// **'High sensitivity. Designed local-first, may adjust local UI recommendations, and is not sent to remote content APIs.'**
  String get privacyDataWomenModeStateNotes;

  /// No description provided for @privacyDataLocalContentManifest.
  ///
  /// In en, this message translates to:
  /// **'Local content manifest'**
  String get privacyDataLocalContentManifest;

  /// No description provided for @privacyDataLocalContentManifestNotes.
  ///
  /// In en, this message translates to:
  /// **'Stored locally to know which approved bundles are active.'**
  String get privacyDataLocalContentManifestNotes;

  /// No description provided for @privacyDataLocalContentBundles.
  ///
  /// In en, this message translates to:
  /// **'Local content bundles'**
  String get privacyDataLocalContentBundles;

  /// No description provided for @privacyDataLocalContentBundlesNotes.
  ///
  /// In en, this message translates to:
  /// **'Stored locally after hash, schema, published, and approved checks.'**
  String get privacyDataLocalContentBundlesNotes;

  /// No description provided for @privacyDataLocalRevokedContentIds.
  ///
  /// In en, this message translates to:
  /// **'Local revoked content IDs'**
  String get privacyDataLocalRevokedContentIds;

  /// No description provided for @privacyDataLocalRevokedContentIdsNotes.
  ///
  /// In en, this message translates to:
  /// **'Stored locally so revoked content is hidden from the client.'**
  String get privacyDataLocalRevokedContentIdsNotes;

  /// No description provided for @privacyDataSavedItems.
  ///
  /// In en, this message translates to:
  /// **'Saved items'**
  String get privacyDataSavedItems;

  /// No description provided for @privacyDataSavedItemsNotes.
  ///
  /// In en, this message translates to:
  /// **'Saved sessions, duas, dhikr, and verse references are stored locally only.'**
  String get privacyDataSavedItemsNotes;

  /// No description provided for @privacyDataSessionProgressHistory.
  ///
  /// In en, this message translates to:
  /// **'Session progress history'**
  String get privacyDataSessionProgressHistory;

  /// No description provided for @privacyDataSessionProgressHistoryNotes.
  ///
  /// In en, this message translates to:
  /// **'Session progress and completion records store session IDs and timestamps locally only.'**
  String get privacyDataSessionProgressHistoryNotes;

  /// No description provided for @privacyDataPrayerCompletionHistory.
  ///
  /// In en, this message translates to:
  /// **'Prayer completion history'**
  String get privacyDataPrayerCompletionHistory;

  /// No description provided for @privacyDataPrayerCompletionHistoryNotes.
  ///
  /// In en, this message translates to:
  /// **'Prayer check-ins store prayer names and local completion timestamps on this device only.'**
  String get privacyDataPrayerCompletionHistoryNotes;

  /// No description provided for @privacyDataLocalPushDebug.
  ///
  /// In en, this message translates to:
  /// **'Local push payload debug data'**
  String get privacyDataLocalPushDebug;

  /// No description provided for @privacyDataLocalPushDebugNotes.
  ///
  /// In en, this message translates to:
  /// **'No persistent client-side debug queue is collected in MVP.'**
  String get privacyDataLocalPushDebugNotes;

  /// No description provided for @privacyDataAudioPlaybackState.
  ///
  /// In en, this message translates to:
  /// **'Audio playback state'**
  String get privacyDataAudioPlaybackState;

  /// No description provided for @privacyDataAudioPlaybackStateNotes.
  ///
  /// In en, this message translates to:
  /// **'No persistent playback history is collected in MVP.'**
  String get privacyDataAudioPlaybackStateNotes;

  /// No description provided for @privacyDataRemoteContentApiConfig.
  ///
  /// In en, this message translates to:
  /// **'Remote content API config state'**
  String get privacyDataRemoteContentApiConfig;

  /// No description provided for @privacyDataRemoteContentApiConfigNotes.
  ///
  /// In en, this message translates to:
  /// **'Provider and endpoint configuration may exist locally; tokens are never displayed in Privacy Center.'**
  String get privacyDataRemoteContentApiConfigNotes;

  /// No description provided for @privacyDataRemoteContentRequestMetadata.
  ///
  /// In en, this message translates to:
  /// **'Remote content request metadata'**
  String get privacyDataRemoteContentRequestMetadata;

  /// No description provided for @remoteContentRequestMetadataNotes.
  ///
  /// In en, this message translates to:
  /// **'Requests may include language, market, app version, and schema version only.'**
  String get remoteContentRequestMetadataNotes;

  /// No description provided for @privacyDataAnalyticsConsent.
  ///
  /// In en, this message translates to:
  /// **'Analytics consent preference'**
  String get privacyDataAnalyticsConsent;

  /// No description provided for @privacyDataAnalyticsConsentNotes.
  ///
  /// In en, this message translates to:
  /// **'Stored locally. Turning it off disables Firebase Analytics collection when analytics builds are configured.'**
  String get privacyDataAnalyticsConsentNotes;

  /// No description provided for @privacyDataAnalyticsEvents.
  ///
  /// In en, this message translates to:
  /// **'Default-off analytics events'**
  String get privacyDataAnalyticsEvents;

  /// No description provided for @privacyDataAnalyticsEventsNotes.
  ///
  /// In en, this message translates to:
  /// **'Only sent when analytics is enabled for the build and the user opts in. Events are whitelisted and exclude coordinates, feedback, religious text, and Women’s Ibadah Mode exact status.'**
  String get privacyDataAnalyticsEventsNotes;

  /// No description provided for @privacyDataFutureAnalyticsCrash.
  ///
  /// In en, this message translates to:
  /// **'Crash reporting'**
  String get privacyDataFutureAnalyticsCrash;

  /// No description provided for @privacyDataFutureAnalyticsCrashNotes.
  ///
  /// In en, this message translates to:
  /// **'Crash-reporting SDK is not implemented in MVP.'**
  String get privacyDataFutureAnalyticsCrashNotes;

  /// No description provided for @privacyDataAccountData.
  ///
  /// In en, this message translates to:
  /// **'Account data'**
  String get privacyDataAccountData;

  /// No description provided for @privacyDataAccountDataNotes.
  ///
  /// In en, this message translates to:
  /// **'Account login is not implemented in MVP.'**
  String get privacyDataAccountDataNotes;

  /// No description provided for @privacyDataPaymentsSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Payments and subscriptions'**
  String get privacyDataPaymentsSubscriptions;

  /// No description provided for @privacyDataPaymentsSubscriptionsNotes.
  ///
  /// In en, this message translates to:
  /// **'Payments and subscriptions are not implemented in MVP.'**
  String get privacyDataPaymentsSubscriptionsNotes;

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

  /// No description provided for @womenModeWhatChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'What changes locally'**
  String get womenModeWhatChangesTitle;

  /// No description provided for @womenModeWhatChangesBody.
  ///
  /// In en, this message translates to:
  /// **'Home recommendations may become quieter and highlight dua, dhikr, and reflection. Daily sessions may show a private local-only note.'**
  String get womenModeWhatChangesBody;

  /// No description provided for @womenModeWhatStaysPrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'What does not leave this device'**
  String get womenModeWhatStaysPrivateTitle;

  /// No description provided for @womenModeWhatStaysPrivateBody.
  ///
  /// In en, this message translates to:
  /// **'Your exact mode is stored locally and is not sent with remote content requests.'**
  String get womenModeWhatStaysPrivateBody;

  /// No description provided for @womenModeReminderPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Reminder text stays generic so lock-screen copy does not reveal private details.'**
  String get womenModeReminderPrivacyBody;

  /// No description provided for @womenModeTurnOffBody.
  ///
  /// In en, this message translates to:
  /// **'Turn this mode off by choosing Normal, or clear it from Privacy Center > Delete local data.'**
  String get womenModeTurnOffBody;

  /// No description provided for @openPrivacyCenter.
  ///
  /// In en, this message translates to:
  /// **'Open Privacy Center'**
  String get openPrivacyCenter;

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

  /// No description provided for @womenModeDiscreetToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Discreet privacy mode'**
  String get womenModeDiscreetToggleTitle;

  /// No description provided for @womenModeDiscreetToggleBody.
  ///
  /// In en, this message translates to:
  /// **'Hide women’s mode support copy on Home and Daily Session. Your status still stays on this device.'**
  String get womenModeDiscreetToggleBody;

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

  /// No description provided for @pauseRecitation.
  ///
  /// In en, this message translates to:
  /// **'Pause recitation'**
  String get pauseRecitation;

  /// No description provided for @textOnlyFallback.
  ///
  /// In en, this message translates to:
  /// **'Text-only fallback'**
  String get textOnlyFallback;

  /// No description provided for @audioUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Audio unavailable'**
  String get audioUnavailable;

  /// No description provided for @approvedReciter.
  ///
  /// In en, this message translates to:
  /// **'approved reciter'**
  String get approvedReciter;

  /// No description provided for @approvedReciterLabel.
  ///
  /// In en, this message translates to:
  /// **'Approved reciter'**
  String get approvedReciterLabel;

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

  /// No description provided for @reflectionSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Reflection note'**
  String get reflectionSafetyTitle;

  /// No description provided for @reflectionSafetyDescription.
  ///
  /// In en, this message translates to:
  /// **'Reflection is a gentle reminder, not a fatwa or religious ruling.'**
  String get reflectionSafetyDescription;

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
