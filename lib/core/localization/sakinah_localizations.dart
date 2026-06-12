import 'package:flutter/material.dart';

class SakinahLocalizations {
  const SakinahLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('id'),
    Locale('ar'),
  ];

  static const delegate = _SakinahLocalizationsDelegate();

  static SakinahLocalizations of(BuildContext context) {
    return Localizations.of<SakinahLocalizations>(
      context,
      SakinahLocalizations,
    )!;
  }

  static const _values = {
    'en': {
      'appTitle': 'Sakinah Daily',
      'splashTagline': 'Calm for the heart,\nremembrance for the day',
      'splashFeatureLine': 'QURAN   ·   DUA   ·   DHIKR   ·   PRAYER',
      'onboardingTitle': 'Begin with calm worship',
      'onboardingSubtitle':
          'Choose your language and preferences for a quiet daily companion.',
      'language': 'Language',
      'genderMode': 'Personalization',
      'genderMale': 'Male',
      'genderFemale': 'Female',
      'genderPreferNotToSay': 'Prefer not to say',
      'audioPreference': 'Audio preference',
      'audioRecitationOnly': 'Recitation only',
      'audioQuietGuidance': 'Quiet guidance',
      'audioTextFirst': 'Text first',
      'prayerReminderConsent':
          'Prayer reminders ask permission only after this explanation.',
      'onboardingPrayerLocationBody':
          'Prayer times and Qibla use this local prayer location.',
      'onboardingPrayerNoGps': 'No GPS permission is requested in v0.1.',
      'continueLabel': 'Continue',
      'homeGreeting': 'Assalamu alaikum',
      'homeFriend': 'Friend',
      'homeFemaleName': 'Aisha',
      'homeDateLabel': 'Tuesday · 12 Ramadan',
      'nextPrayer': 'Next prayer',
      'dailyPrayerHomeTitle': 'Daily prayer at the center',
      'viewPrayerTimes': 'View prayer times',
      'manageReminders': 'Manage reminders',
      'changeLocation': 'Change location',
      'todaySession': "Today's Sakinah Session",
      'sessionSubtitleMeta': '7 min · Ayah · Reflection · Dua · Dhikr',
      'quickActions': 'Quick Actions',
      'startSession': 'Start session',
      'start': 'Start',
      'voiceOnly': 'Voice only',
      'home': 'Home',
      'quran': 'Quran',
      'quranPageTitle': 'Quran',
      'featuredAyah': 'Featured ayah',
      'openAyah': 'Open ayah',
      'quranAvailableVerses': 'Available verses',
      'quranLocalOnlyBrowserBody':
          'Browse reviewed local seed ayahs only. More Quran content requires approved sources.',
      'quranVerseSearchHint': 'Search by verse reference or meaning',
      'quranVerseNoResults': 'No reviewed local verse matches this search.',
      'quranVerseUnavailable': 'Quran verse unavailable',
      'quranPreviousVerse': 'Previous verse',
      'quranNextVerse': 'Next verse',
      'saveAyah': 'Save ayah',
      'savedAyah': 'Saved ayah',
      'quranVoiceOnlyTitle': 'Quran recitation is voice-only',
      'quranVoiceOnlyBody':
          'Quran recitation uses approved voice assets only and does not rely on synthetic Quran audio.',
      'noQuranTts': 'No Quran TTS',
      'noQuranBgm': 'No background music under Quran recitation',
      'qibla': 'Qibla',
      'qiblaTitle': 'Qibla direction',
      'qiblaBearing': 'Qibla bearing',
      'qiblaBasedOnSelectedLocation':
          'Qibla uses your selected prayer location.',
      'qiblaChangeLocation': 'Change prayer location',
      'qiblaNoGpsRequired':
          'Qibla uses your selected prayer location. Exact GPS is not required.',
      'tonight': 'Tonight',
      'sleepAyatKursi': 'Sleep with Ayat al-Kursi',
      'sleepSessionDescription':
          "A quiet 5-minute session with pure Qur'an recitation and soft guidance.",
      'saveTonight': 'Save tonight',
      'savedTonight': 'Saved tonight',
      'sessionCompletedTitle': 'Session complete',
      'sessionCompletedBody':
          'You completed this Sakinah session. Take a quiet moment before returning.',
      'completedToday': 'Completed today',
      'resumeSession': 'Resume',
      'reviewSession': 'Review',
      'localProgress': 'Local progress',
      'currentStreak': 'Current streak',
      'completedThisWeek': 'Completed this week',
      'progressLocalOnly': 'Progress stays on this device only.',
      'prayersToday': 'Prayers today',
      'prayerCheckInsLocalOnly': 'Prayer check-ins stay on this device only.',
      'prayerWeekProgress': 'Prayer week',
      'prayerWeekCheckInDays': 'Check-in days',
      'prayerWeekStreak': 'Prayer streak',
      'saveSession': 'Save session',
      'sessionSaved': 'Session saved',
      'openSavedItems': 'Open Saved Items',
      'setDailyReminder': 'Set daily reminder',
      'dailyReminderSet': 'Daily reminder set',
      'manageDailyReminder': 'Manage daily reminder',
      'sessionReminderPermissionTitle': 'Set daily reminder?',
      'sessionReminderPermissionBody':
          'Sakinah can schedule a local daily session reminder. The reminder text stays privacy-safe on the lock screen.',
      'sessionReminderPermissionAllow': 'Set reminder',
      'sessionReminderPermissionNotNow': 'Not now',
      'backHome': 'Back Home',
      'sessionProgressHistory': 'Session progress history',
      'sessionProgressHistoryNotes':
          'Session progress and completion history are stored locally only.',
      'noGuaranteedOutcome': 'No guaranteed spiritual outcome is claimed.',
      'dua': 'Dua',
      'dhikr': 'Dhikr',
      'allCategories': 'All',
      'searchDuaHint': 'Search duas',
      'searchDhikrHint': 'Search dhikr',
      'noDuaResultsTitle': 'No duas found',
      'noDuaResultsBody': 'Try another category or search term.',
      'noDhikrResultsTitle': 'No dhikr found',
      'noDhikrResultsBody': 'Try another category or search term.',
      'categoryQuranic': 'Quranic',
      'categoryMorning': 'Morning',
      'categoryEvening': 'Evening',
      'categoryReflection': 'Reflection',
      'categoryDifficulty': 'Difficulty',
      'categoryGratitude': 'Gratitude',
      'categoryForgiveness': 'Forgiveness',
      'categoryGeneral': 'General',
      'settings': 'Settings',
      'prayer': 'Prayer',
      'prayerLocation': 'Prayer location',
      'manualPrayerLocationTitle': 'Manual prayer location',
      'manualPrayerLocationBody':
          'Enter a prayer location manually. It is stored locally and used for prayer times and Qibla.',
      'locationLabel': 'Location label',
      'latitude': 'Latitude',
      'longitude': 'Longitude',
      'timezoneId': 'Timezone ID',
      'saveLocation': 'Save location',
      'invalidLatitude': 'Latitude must be between -90 and 90.',
      'invalidLongitude': 'Longitude must be between -180 and 180.',
      'locationSaved': 'Location saved',
      'locationLocalOnlyNoGps':
          'Stored locally. No GPS permission is required.',
      'prayerMethod': 'Prayer method',
      'prayerReminders': 'Prayer reminders',
      'todaysPrayerTimes': "Today's prayer times",
      'currentPrayerStatus': 'Current',
      'nextPrayerStatus': 'Next',
      'todaysPrayerCheckIn': "Today's prayer check-in",
      'prayerCheckInBody':
          'Mark prayers you have completed. Stored locally only.',
      'todaysPrayerCheckInComplete': "Today's prayers are checked in",
      'prayerCheckInCompleteBody':
          'Your five prayer check-ins are saved on this device only.',
      'prayerCompletedStatus': 'Completed',
      'prayerReminderSubtitle': 'Permission is requested after explanation.',
      'prayerReminderChoicesTitle': 'Prayer reminder choices',
      'prayerReminderChoicesBody':
          'Choose which prayer times can send local reminders.',
      'prayerReminderChoiceSubtitle': 'Selected for reminder schedule',
      'prayerReminderLeadTimeTitle': 'Reminder timing',
      'prayerReminderLeadTimeBody':
          'Send each selected prayer reminder at the prayer time or a few minutes before.',
      'nextPrayerReminderPreview': 'Next prayer reminder',
      'notificationSettingsTitle': 'Notification settings',
      'notificationSettingsSubtitle':
          'Manage prayer and daily session reminders.',
      'closedTestingGuideTitle': 'Closed testing guide',
      'closedTestingGuideSubtitle':
          'Daily checks for prayer, reminders, session, and privacy.',
      'closedTestingHomeBody':
          'Use the Day 1 / Day 3 / Day 7 / Day 14 prompts to send feedback without personal details.',
      'closedTestingNextFeedback': 'Next feedback',
      'closedTestingAllFeedbackSent': 'All feedback marked sent',
      'closedTestingHomeButton': 'Open guide',
      'closedTestingGuideIntroTitle': 'Help test the daily prayer flow',
      'closedTestingGuideIntroBody':
          'Use this checklist during closed testing so feedback covers the parts that matter for launch quality and daily return.',
      'closedTestingGuideChecklistTitle': 'Daily tester checklist',
      'closedTestingChecklistDailyOpen':
          'Open the app once each day and notice whether Home feels useful enough to return.',
      'closedTestingChecklistPrayer':
          'Check the next prayer time, prayer location, method, and all-day prayer list.',
      'closedTestingChecklistReminder':
          'Review reminder settings and only enable reminders if you are comfortable.',
      'closedTestingChecklistSession':
          'Start Today’s Sakinah Session and finish or resume it later.',
      'closedTestingChecklistPrivacy':
          'Review Privacy Center, Content Sources, and Delete local data.',
      'closedTestingChecklistFeedback':
          'Send feedback about confusing copy, timing issues, layout problems, or anything that made you ignore the app.',
      'closedTestingPromptTitle': 'Feedback prompts',
      'closedTestingPromptBody':
          'Use these checkpoints to send feedback that helps the 14-day closed test improve daily return.',
      'closedTestingPromptDay1Label': 'Day 1',
      'closedTestingPromptDay1':
          'Did onboarding explain location and notification choices clearly?',
      'closedTestingPromptDay3Label': 'Day 3',
      'closedTestingPromptDay3':
          'Were prayer times, location, and reminder controls easy to trust?',
      'closedTestingPromptDay7Label': 'Day 7',
      'closedTestingPromptDay7':
          'What made you want to reopen or ignore the app this week?',
      'closedTestingPromptDay14Label': 'Day 14',
      'closedTestingPromptDay14':
          'What one change would most improve daily use before wider release?',
      'copyTestingFeedbackPrompt': 'Copy prompt',
      'closedTestingPromptCopied': 'Feedback prompt copied.',
      'closedTestingPromptCopyHeader': 'Sakinah Daily closed test feedback',
      'closedTestingPromptCopyPromptLabel': 'Prompt',
      'closedTestingPromptCopyThemeLabel': 'Suggested theme',
      'closedTestingPromptCopyChannelLabel': 'Feedback channel',
      'closedTestingPromptCopyPrivacyLine':
          'Please avoid personal or sensitive health details.',
      'closedTestingPromptFeedbackSent': 'Feedback sent',
      'closedTestingPromptLocalOnlyStatus': 'Stored only on this device.',
      'closedTestingFeedbackTitle': 'Feedback channel',
      'closedTestingFeedbackBody':
          'Copy this channel when reporting closed-test feedback.',
      'closedTestingFeedbackMissing': 'Testing feedback is not configured yet.',
      'copyTestingFeedback': 'Copy feedback channel',
      'testingFeedbackTitle': 'Testing feedback',
      'testingFeedbackCopied': 'Testing feedback copied.',
      'dailySessionReminderTitle': 'Daily session reminder',
      'dailySessionReminderPrivacyNote':
          'Session reminders are scheduled locally and keep lock-screen text privacy-safe.',
      'reminderTime': 'Reminder time',
      'reminderTimeSaved': 'Reminder time saved',
      'saveReminderTime': 'Save time',
      'reminderStatusOn': 'On',
      'reminderStatusOff': 'Off',
      'notificationPermissionTitle': 'Enable prayer reminders?',
      'notificationPermissionBody':
          "Sakinah schedules local prayer reminders only after permission. Women's mode reminders stay privacy-safe on the lock screen.",
      'notificationPermissionAllow': 'Enable reminders',
      'notificationPermissionNotNow': 'Not now',
      'notificationPermissionDenied':
          'Notifications are off. You can enable them from system settings.',
      'notificationScheduled': 'Local prayer reminders are scheduled.',
      'notificationTapMalformed':
          'This notification could not be opened safely.',
      'notificationTapFallbackPrayer': 'Opening prayer times.',
      'notificationTapMissingContent':
          'This notification content is not available offline yet.',
      'womenModeSubtitle':
          'Local-only by default. Sensitive reminder copy stays private.',
      'localOnlyMode': 'Local-only mode',
      'womenModePrivatePath': 'Private gentle path',
      'womenModeHomeSupportBody':
          'Dua, dhikr, and reflection stay easy to reach. Your mode stays on this device.',
      'womenModeSessionNoteTitle': 'Local-only mode',
      'womenModeSessionNoteBody':
          'Your mode stays on this device. This session keeps a gentle worship-friendly path.',
      'continueFromSaved': 'Continue from saved',
      'savedRailLocalNote': 'Saved locally on this device.',
      'savedItems': 'Saved Items',
      'savedItemsEmptyTitle': 'Nothing saved yet',
      'savedItemsEmptyBody':
          'Saved items stay on this device for quick return later.',
      'save': 'Save',
      'unsave': 'Unsave',
      'removeSavedItem': 'Remove saved item',
      'savedLocalOnly': 'Saved items stay on this device only.',
      'savedItemsPrivacyNotes': 'Saved locally. No account or sync in MVP.',
      'privacy': 'Privacy',
      'privacySubtitle': "Women's mode data is not sent remotely in MVP.",
      'privacyCenterTitle': 'Privacy Center',
      'dataInventoryTitle': 'Data inventory',
      'dataInventoryBody':
          'This inventory describes MVP client data and where it is stored.',
      'dataOnDeviceTitle': 'Data we keep on this device',
      'dataCanLeaveDeviceTitle': 'Data that can leave this device',
      'localOnlyData':
          'Most preferences, prayer settings, women’s mode, and content cache stay on this device.',
      'leavesDeviceData':
          'Remote content requests may include language, market, app version, and schema version.',
      'womenModePrivacyTitle': "Women's Ibadah Mode privacy",
      'womenModePrivacyBody':
          'Women’s Ibadah Mode is designed local-first. Exact status is not sent with remote content requests.',
      'prayerLocationPrivacyTitle': 'Prayer location privacy',
      'prayerLocationPrivacyBody':
          'Prayer location uses manual or preset choices by default for prayer time calculation.',
      'notificationPrivacyTitle': 'Notifications privacy',
      'notificationPrivacyBody':
          'Prayer reminders are scheduled locally where possible, and sensitive women’s mode copy stays off the lock screen.',
      'remoteContentPrivacyTitle': 'Remote content cache',
      'remoteContentPrivacyBody':
          'Approved content bundles can be cached on this device. Remote content requests may include language, market, app version, and schema version.',
      'analyticsPrivacyTitle': 'Usage analytics privacy',
      'analyticsPrivacyBody':
          'Usage analytics is default-off. If enabled in a reviewed build, Sakinah sends only whitelisted app-flow events and never sends exact coordinates, Women’s Ibadah Mode exact status, feedback text, or religious text.',
      'analyticsOptInTitle': 'Share usage analytics',
      'analyticsOptInAvailableBody':
          'Optional. Helps improve prayer reminders and session retention with privacy-safe event names only.',
      'analyticsOptInUnavailableBody':
          'Analytics collection is off in this build.',
      'deleteLocalDataTitle': 'Delete local data',
      'deleteLocalDataBody':
          'Reset app preferences, saved items, session progress, women’s mode state, local content cache, and scheduled reminders on this device.',
      'deleteLocalDataKeepsSeed':
          'Bundled seed content and app files are kept. This does not contact a remote service.',
      'deleteLocalDataConfirm': 'Delete local data',
      'deleteLocalDataDeleting': 'Deleting...',
      'deleteLocalDataDialogTitle': 'Confirm local reset',
      'deleteLocalDataDialogBody':
          'This clears local preferences, saved items, session progress, cached bundles, and scheduled reminders on this device.',
      'deleteLocalDataCancel': 'Cancel',
      'deleteLocalDataSuccess': 'Local data has been reset on this device.',
      'storePrivacyDraftTitle': 'Store data safety summary',
      'storePrivacyDraftBody':
          'Draft store declarations are documented for review before submission.',
      'privacyPolicyDraftTitle': 'Privacy policy draft',
      'privacyPolicyDraftBody':
          'A draft privacy policy exists for legal and store review.',
      'privacyPolicyPublishedTitle': 'Published privacy policy',
      'privacyPolicyLinkCopied': 'Privacy policy link copied.',
      'contentSourcesTitle': 'Content Sources',
      'contentSourcesSubtitle': 'Source labels, review status, and AI limits.',
      'contentSourcesIntro':
          'Sakinah shows worship content with source and review guardrails so users can understand what they are reading or hearing.',
      'contentSourcesSeedTitle': 'Reviewed seed and approved bundles',
      'contentSourcesSeedBody':
          'Quran, Dua, Dhikr, and session content shown in the app must come from reviewed seed content or approved CMS bundles.',
      'contentSourcesApprovalTitle': 'Published + approved only',
      'contentSourcesApprovalBody':
          'Remote CMS content is hidden unless it is both published and approved. Draft, in-review, rejected, or revoked content is filtered out.',
      'contentSourcesGeneratedTitle': 'Not generated',
      'contentSourcesGeneratedBody':
          'The client does not generate Quran text, translations, Dua, Dhikr, reflection, or religious answers.',
      'contentSourcesAudioTitle': 'Quran audio safety',
      'contentSourcesAudioBody':
          'Quran recitation uses approved voice assets only. There is no generic Quran TTS and no background music under Quran recitation.',
      'contentSourcesFatwaTitle': 'No AI fatwa or religious Q&A',
      'contentSourcesFatwaBody':
          'When a topic has school or regional differences, Sakinah uses neutral wording and source labels rather than fatwa-style claims.',
      'storageLocalDevice': 'Local device',
      'storageRemoteOptional': 'Remote request',
      'storageNotCollected': 'Not collected',
      'sensitivityLow': 'Low sensitivity',
      'sensitivityMedium': 'Medium sensitivity',
      'sensitivityHigh': 'High sensitivity',
      'localOnlyShort': 'Local only',
      'leavesDeviceShort': 'Leaves device',
      'userCanDeleteShort': 'User can delete',
      'privacyDataLanguagePreference': 'Language preference',
      'privacyDataLanguagePreferenceNotes':
          'Stored locally and used to choose app language and content language.',
      'privacyDataGenderModePreference': 'Gender mode preference',
      'privacyDataGenderModePreferenceNotes':
          'Stored locally for client personalization in MVP.',
      'privacyDataAudioPreference': 'Audio preference',
      'privacyDataAudioPreferenceNotes':
          'Stored locally to choose recitation-only, guidance, or text-first behavior.',
      'privacyDataPrayerSettings': 'Prayer settings',
      'privacyDataPrayerSettingsNotes':
          'Stored locally for prayer time method and calculation settings.',
      'privacyDataPrayerLocationPreset': 'Prayer location preset',
      'privacyDataPrayerLocationPresetNotes':
          'Stored locally by default as a manual or preset location choice.',
      'privacyDataNotificationEnabledState': 'Notification enabled state',
      'privacyDataNotificationEnabledStateNotes':
          'Stored locally to remember prayer reminder status, per-prayer choices, prayer reminder lead-time offset, daily session reminder status, and the selected daily session reminder time.',
      'privacyDataClosedTestingFeedbackStatus':
          'Closed testing feedback status',
      'privacyDataClosedTestingFeedbackStatusNotes':
          'Stores only whether Day 1, Day 3, Day 7, or Day 14 feedback was marked sent. Feedback text and personal details are not stored.',
      'privacyDataWomenModeState': "Women's Ibadah Mode state",
      'privacyDataWomenModeStateNotes':
          'High sensitivity. Designed local-first, may adjust local UI recommendations, and is not sent to remote content APIs.',
      'privacyDataLocalContentManifest': 'Local content manifest',
      'privacyDataLocalContentManifestNotes':
          'Stored locally to know which approved bundles are active.',
      'privacyDataLocalContentBundles': 'Local content bundles',
      'privacyDataLocalContentBundlesNotes':
          'Stored locally after hash, schema, published, and approved checks.',
      'privacyDataLocalRevokedContentIds': 'Local revoked content IDs',
      'privacyDataLocalRevokedContentIdsNotes':
          'Stored locally so revoked content is hidden from the client.',
      'privacyDataSavedItems': 'Saved items',
      'privacyDataSavedItemsNotes':
          'Saved sessions, duas, dhikr, and verse references are stored locally only.',
      'privacyDataSessionProgressHistory': 'Session progress history',
      'privacyDataSessionProgressHistoryNotes':
          'Session progress and completion records store session IDs and timestamps locally only.',
      'privacyDataPrayerCompletionHistory': 'Prayer completion history',
      'privacyDataPrayerCompletionHistoryNotes':
          'Prayer check-ins store prayer names and local completion timestamps on this device only.',
      'privacyDataLocalPushDebug': 'Local push payload debug data',
      'privacyDataLocalPushDebugNotes':
          'No persistent client-side debug queue is collected in MVP.',
      'privacyDataAudioPlaybackState': 'Audio playback state',
      'privacyDataAudioPlaybackStateNotes':
          'No persistent playback history is collected in MVP.',
      'privacyDataRemoteContentApiConfig': 'Remote content API config state',
      'privacyDataRemoteContentApiConfigNotes':
          'Provider and endpoint configuration may exist locally; tokens are never displayed in Privacy Center.',
      'privacyDataRemoteContentRequestMetadata':
          'Remote content request metadata',
      'remoteContentRequestMetadataNotes':
          'Requests may include language, market, app version, and schema version only.',
      'privacyDataAnalyticsConsent': 'Analytics consent preference',
      'privacyDataAnalyticsConsentNotes':
          'Stored locally. Turning it off disables Firebase Analytics collection when analytics builds are configured.',
      'privacyDataAnalyticsEvents': 'Default-off analytics events',
      'privacyDataAnalyticsEventsNotes':
          'Only sent when analytics is enabled for the build and the user opts in. Events are whitelisted and exclude coordinates, feedback, religious text, and Women’s Ibadah Mode exact status.',
      'privacyDataFutureAnalyticsCrash': 'Crash reporting',
      'privacyDataFutureAnalyticsCrashNotes':
          'Crash-reporting SDK is not implemented in MVP.',
      'privacyDataAccountData': 'Account data',
      'privacyDataAccountDataNotes': 'Account login is not implemented in MVP.',
      'privacyDataPaymentsSubscriptions': 'Payments and subscriptions',
      'privacyDataPaymentsSubscriptionsNotes':
          'Payments and subscriptions are not implemented in MVP.',
      'privacyDataAdsTracking': 'Ads or tracking',
      'privacyDataAdsTrackingNotes':
          'Ads, tracking, and ATT prompts are not implemented in MVP.',
      'source': 'Source',
      'reviewed': 'Reviewed',
      'approvedContent': 'approved content',
      'draftContent': 'draft content',
      'inReviewContent': 'in review content',
      'rejectedContent': 'rejected content',
      'womenMode': "Women's Ibadah Mode",
      'womenModeDescription': 'Adjust reminders with privacy and respect.',
      'womenModeWhatChangesTitle': 'What changes locally',
      'womenModeWhatChangesBody':
          'Home recommendations may become quieter and highlight dua, dhikr, and reflection. Daily sessions may show a private local-only note.',
      'womenModeWhatStaysPrivateTitle': 'What does not leave this device',
      'womenModeWhatStaysPrivateBody':
          'Your exact mode is stored locally and is not sent with remote content requests.',
      'womenModeReminderPrivacyBody':
          'Reminder text stays generic so lock-screen copy does not reveal private details.',
      'womenModeTurnOffBody':
          'Turn this mode off by choosing Normal, or clear it from Privacy Center > Delete local data.',
      'openPrivacyCenter': 'Open Privacy Center',
      'todaysMode': "Today's mode",
      'modeNormal': 'Normal',
      'modeMenstruating': 'Menstruating',
      'modePostpartum': 'Postpartum',
      'modePregnancy': 'Pregnancy',
      'modePreferNotToTrack': 'Prefer not to track',
      'dataStaysLocal': 'Data stays local by default',
      'recommendedNow': 'Recommended now',
      'gentleWorshipMoment': 'A gentle worship moment',
      'womenRecommendedDescription':
          'Dua · Dhikr · Reflection reminders without direct prayer prompts.',
      'reminderBehavior': 'Reminder behavior',
      'reminderBehaviorDescription':
          'Prayer alerts can be paused or replaced with Dua and Dhikr moments.',
      'duaUnavailable': 'Dua unavailable.',
      'makeDua': 'Make Dua',
      'duaContext': 'For focus · Before work or study',
      'saved': 'Saved',
      'arabicLabel': 'Arabic',
      'transliteration': 'Transliteration',
      'meaning': 'Meaning',
      'listen': 'Listen',
      'repeatSlowly': 'Repeat slowly',
      'session': 'Session',
      'sessionUnavailable': 'Session unavailable.',
      'next': 'Next',
      'finish': 'Finish',
      'playRecitation': 'Play recitation',
      'pauseRecitation': 'Pause recitation',
      'textOnlyFallback': 'Text-only fallback',
      'audioUnavailable': 'Audio unavailable',
      'approvedReciter': 'approved reciter',
      'approvedReciterLabel': 'Approved reciter',
      'quranSafetyTitle': "Qur'an Safety",
      'quranSafetyDescription':
          "No background sound is played under Qur'an recitation.",
      'reflectionSafetyTitle': 'Reflection note',
      'reflectionSafetyDescription':
          'Reflection is a gentle reminder, not a fatwa or religious ruling.',
      'completionFallback':
          'Pause, breathe, and keep this act for Allah alone.',
      'backgroundSoundAllowed': 'Background sound allowed',
      'noBackgroundMusic': 'No background music under Quran recitation',
      'timeIn': 'in',
      'hourShort': 'h',
      'minuteShort': 'm',
      'prayerFajr': 'Fajr',
      'prayerDhuhr': 'Dhuhr',
      'prayerAsr': 'Asr',
      'prayerMaghrib': 'Maghrib',
      'prayerIsha': 'Isha',
    },
    'id': {
      'appTitle': 'Sakinah Daily',
      'splashTagline': 'Tenang untuk hati,\nzikir untuk hari ini',
      'splashFeatureLine': 'QURAN   ·   DOA   ·   DZIKIR   ·   SHALAT',
      'onboardingTitle': 'Mulai dengan ibadah yang tenang',
      'onboardingSubtitle':
          'Pilih bahasa dan preferensi untuk pendamping harian yang lembut.',
      'language': 'Bahasa',
      'genderMode': 'Personalisasi',
      'genderMale': 'Laki-laki',
      'genderFemale': 'Perempuan',
      'genderPreferNotToSay': 'Tidak ingin menjawab',
      'audioPreference': 'Preferensi audio',
      'audioRecitationOnly': 'Tilawah saja',
      'audioQuietGuidance': 'Panduan lembut',
      'audioTextFirst': 'Utamakan teks',
      'prayerReminderConsent':
          'Pengingat shalat meminta izin hanya setelah penjelasan ini.',
      'onboardingPrayerLocationBody':
          'Waktu shalat dan Kiblat memakai lokasi shalat lokal ini.',
      'onboardingPrayerNoGps': 'Izin GPS tidak diminta di v0.1.',
      'continueLabel': 'Lanjut',
      'homeGreeting': 'Assalamu alaikum',
      'homeFriend': 'Sahabat',
      'homeFemaleName': 'Aisyah',
      'homeDateLabel': 'Selasa · 12 Ramadan',
      'nextPrayer': 'Shalat berikutnya',
      'dailyPrayerHomeTitle': 'Shalat harian sebagai pusat',
      'viewPrayerTimes': 'Lihat waktu shalat',
      'manageReminders': 'Kelola pengingat',
      'changeLocation': 'Ubah lokasi',
      'todaySession': 'Sesi Sakinah Hari Ini',
      'sessionSubtitleMeta': '7 menit · Ayat · Refleksi · Doa · Dzikir',
      'quickActions': 'Aksi Cepat',
      'startSession': 'Mulai sesi',
      'start': 'Mulai',
      'voiceOnly': 'Suara saja',
      'home': 'Beranda',
      'quran': 'Quran',
      'quranPageTitle': 'Quran',
      'featuredAyah': 'Ayat pilihan',
      'openAyah': 'Buka ayat',
      'quranAvailableVerses': 'Ayat tersedia',
      'quranLocalOnlyBrowserBody':
          'Jelajahi hanya ayat seed lokal yang sudah ditinjau. Konten Quran tambahan memerlukan sumber yang disetujui.',
      'quranVerseSearchHint': 'Cari dengan referensi ayat atau makna',
      'quranVerseNoResults':
          'Tidak ada ayat lokal yang ditinjau cocok dengan pencarian ini.',
      'quranVerseUnavailable': 'Ayat Quran tidak tersedia',
      'quranPreviousVerse': 'Ayat sebelumnya',
      'quranNextVerse': 'Ayat berikutnya',
      'saveAyah': 'Simpan ayat',
      'savedAyah': 'Ayat tersimpan',
      'quranVoiceOnlyTitle': 'Tilawah Quran hanya suara',
      'quranVoiceOnlyBody':
          'Tilawah Quran memakai aset suara yang disetujui saja dan tidak memakai audio Quran sintetis.',
      'noQuranTts': 'Tanpa TTS Quran',
      'noQuranBgm': 'Tidak ada musik latar di bawah tilawah Quran',
      'qibla': 'Kiblat',
      'qiblaTitle': 'Arah kiblat',
      'qiblaBearing': 'Arah kiblat',
      'qiblaBasedOnSelectedLocation':
          'Kiblat memakai lokasi shalat yang dipilih.',
      'qiblaChangeLocation': 'Ubah lokasi shalat',
      'qiblaNoGpsRequired':
          'Kiblat memakai lokasi shalat yang dipilih. GPS presisi tidak diperlukan.',
      'tonight': 'Malam ini',
      'sleepAyatKursi': 'Tidur dengan Ayat Kursi',
      'sleepSessionDescription':
          "Sesi tenang 5 menit dengan tilawah Qur'an murni dan panduan lembut.",
      'saveTonight': 'Simpan malam ini',
      'savedTonight': 'Tersimpan malam ini',
      'sessionCompletedTitle': 'Sesi selesai',
      'sessionCompletedBody':
          'Anda menyelesaikan sesi Sakinah ini. Ambil jeda hening sebelum kembali.',
      'completedToday': 'Selesai hari ini',
      'resumeSession': 'Lanjutkan',
      'reviewSession': 'Tinjau',
      'localProgress': 'Progres lokal',
      'currentStreak': 'Rangkaian hari',
      'completedThisWeek': 'Selesai pekan ini',
      'progressLocalOnly': 'Progres tetap hanya di perangkat ini.',
      'prayersToday': 'Shalat hari ini',
      'prayerCheckInsLocalOnly': 'Catatan shalat tetap hanya di perangkat ini.',
      'prayerWeekProgress': 'Pekan shalat',
      'prayerWeekCheckInDays': 'Hari check-in',
      'prayerWeekStreak': 'Rangkaian shalat',
      'saveSession': 'Simpan sesi',
      'sessionSaved': 'Sesi tersimpan',
      'openSavedItems': 'Buka Item Tersimpan',
      'setDailyReminder': 'Atur pengingat harian',
      'dailyReminderSet': 'Pengingat harian aktif',
      'manageDailyReminder': 'Kelola pengingat harian',
      'sessionReminderPermissionTitle': 'Atur pengingat harian?',
      'sessionReminderPermissionBody':
          'Sakinah dapat menjadwalkan pengingat sesi harian lokal. Teks pengingat tetap aman untuk layar terkunci.',
      'sessionReminderPermissionAllow': 'Atur pengingat',
      'sessionReminderPermissionNotNow': 'Nanti saja',
      'backHome': 'Kembali ke Beranda',
      'sessionProgressHistory': 'Riwayat progres sesi',
      'sessionProgressHistoryNotes':
          'Progres sesi dan riwayat penyelesaian disimpan lokal saja.',
      'noGuaranteedOutcome': 'Tidak ada klaim hasil spiritual yang dijamin.',
      'dua': 'Doa',
      'dhikr': 'Dzikir',
      'allCategories': 'Semua',
      'searchDuaHint': 'Cari doa',
      'searchDhikrHint': 'Cari dzikir',
      'noDuaResultsTitle': 'Doa tidak ditemukan',
      'noDuaResultsBody': 'Coba kategori atau kata pencarian lain.',
      'noDhikrResultsTitle': 'Dzikir tidak ditemukan',
      'noDhikrResultsBody': 'Coba kategori atau kata pencarian lain.',
      'categoryQuranic': 'Quranic',
      'categoryMorning': 'Pagi',
      'categoryEvening': 'Malam',
      'categoryReflection': 'Renungan',
      'categoryDifficulty': 'Kesulitan',
      'categoryGratitude': 'Syukur',
      'categoryForgiveness': 'Ampunan',
      'categoryGeneral': 'Umum',
      'settings': 'Pengaturan',
      'prayer': 'Shalat',
      'prayerLocation': 'Lokasi shalat',
      'manualPrayerLocationTitle': 'Lokasi shalat manual',
      'manualPrayerLocationBody':
          'Masukkan lokasi shalat secara manual. Data ini disimpan lokal dan dipakai untuk waktu shalat serta kiblat.',
      'locationLabel': 'Label lokasi',
      'latitude': 'Lintang',
      'longitude': 'Bujur',
      'timezoneId': 'ID zona waktu',
      'saveLocation': 'Simpan lokasi',
      'invalidLatitude': 'Lintang harus antara -90 dan 90.',
      'invalidLongitude': 'Bujur harus antara -180 dan 180.',
      'locationSaved': 'Lokasi tersimpan',
      'locationLocalOnlyNoGps': 'Disimpan lokal. Izin GPS tidak diperlukan.',
      'prayerMethod': 'Metode shalat',
      'prayerReminders': 'Pengingat shalat',
      'todaysPrayerTimes': 'Waktu shalat hari ini',
      'currentPrayerStatus': 'Saat ini',
      'nextPrayerStatus': 'Berikutnya',
      'todaysPrayerCheckIn': 'Catatan shalat hari ini',
      'prayerCheckInBody':
          'Tandai shalat yang sudah kamu selesaikan. Disimpan hanya di perangkat ini.',
      'todaysPrayerCheckInComplete': 'Shalat hari ini sudah ditandai',
      'prayerCheckInCompleteBody':
          'Lima catatan shalat Anda tersimpan hanya di perangkat ini.',
      'prayerCompletedStatus': 'Selesai',
      'prayerReminderSubtitle': 'Izin diminta setelah penjelasan.',
      'prayerReminderChoicesTitle': 'Pilihan pengingat shalat',
      'prayerReminderChoicesBody':
          'Pilih waktu shalat yang dapat mengirim pengingat lokal.',
      'prayerReminderChoiceSubtitle': 'Dipilih untuk jadwal pengingat',
      'prayerReminderLeadTimeTitle': 'Waktu pengingat',
      'prayerReminderLeadTimeBody':
          'Kirim setiap pengingat shalat terpilih saat waktu shalat atau beberapa menit sebelumnya.',
      'nextPrayerReminderPreview': 'Pengingat shalat berikutnya',
      'notificationSettingsTitle': 'Pengaturan notifikasi',
      'notificationSettingsSubtitle':
          'Kelola pengingat shalat dan sesi harian.',
      'closedTestingGuideTitle': 'Panduan closed testing',
      'closedTestingGuideSubtitle':
          'Cek harian untuk shalat, pengingat, sesi, dan privasi.',
      'closedTestingHomeBody':
          'Gunakan prompt Hari 1 / Hari 3 / Hari 7 / Hari 14 untuk mengirim masukan tanpa detail pribadi.',
      'closedTestingNextFeedback': 'Masukan berikutnya',
      'closedTestingAllFeedbackSent': 'Semua masukan ditandai terkirim',
      'closedTestingHomeButton': 'Buka panduan',
      'closedTestingGuideIntroTitle': 'Bantu uji alur shalat harian',
      'closedTestingGuideIntroBody':
          'Gunakan daftar ini selama closed testing agar masukan mencakup bagian penting untuk kualitas rilis dan kebiasaan kembali harian.',
      'closedTestingGuideChecklistTitle': 'Daftar cek tester harian',
      'closedTestingChecklistDailyOpen':
          'Buka app sekali setiap hari dan perhatikan apakah Home cukup berguna untuk dibuka lagi.',
      'closedTestingChecklistPrayer':
          'Cek waktu shalat berikutnya, lokasi shalat, metode, dan daftar waktu shalat harian.',
      'closedTestingChecklistReminder':
          'Tinjau pengaturan pengingat dan aktifkan hanya jika Anda nyaman.',
      'closedTestingChecklistSession':
          'Mulai Sesi Sakinah hari ini dan selesaikan atau lanjutkan nanti.',
      'closedTestingChecklistPrivacy':
          'Tinjau Pusat Privasi, Sumber Konten, dan Hapus data lokal.',
      'closedTestingChecklistFeedback':
          'Kirim masukan tentang teks yang membingungkan, masalah waktu, layout, atau hal yang membuat app diabaikan.',
      'closedTestingPromptTitle': 'Prompt masukan',
      'closedTestingPromptBody':
          'Gunakan titik cek ini untuk mengirim masukan yang membantu closed test 14 hari memperbaiki kebiasaan kembali harian.',
      'closedTestingPromptDay1Label': 'Hari 1',
      'closedTestingPromptDay1':
          'Apakah onboarding menjelaskan pilihan lokasi dan notifikasi dengan jelas?',
      'closedTestingPromptDay3Label': 'Hari 3',
      'closedTestingPromptDay3':
          'Apakah waktu shalat, lokasi, dan kontrol pengingat mudah dipercaya?',
      'closedTestingPromptDay7Label': 'Hari 7',
      'closedTestingPromptDay7':
          'Apa yang membuat Anda ingin membuka app lagi atau mengabaikannya minggu ini?',
      'closedTestingPromptDay14Label': 'Hari 14',
      'closedTestingPromptDay14':
          'Satu perubahan apa yang paling membantu penggunaan harian sebelum rilis lebih luas?',
      'copyTestingFeedbackPrompt': 'Salin prompt',
      'closedTestingPromptCopied': 'Prompt masukan disalin.',
      'closedTestingPromptCopyHeader': 'Masukan closed test Sakinah Daily',
      'closedTestingPromptCopyPromptLabel': 'Prompt',
      'closedTestingPromptCopyThemeLabel': 'Tema yang disarankan',
      'closedTestingPromptCopyChannelLabel': 'Kanal masukan',
      'closedTestingPromptCopyPrivacyLine':
          'Hindari detail pribadi atau kesehatan yang sensitif.',
      'closedTestingPromptFeedbackSent': 'Masukan terkirim',
      'closedTestingPromptLocalOnlyStatus': 'Disimpan hanya di perangkat ini.',
      'closedTestingFeedbackTitle': 'Kanal masukan',
      'closedTestingFeedbackBody':
          'Salin kanal ini saat mengirim masukan closed-test.',
      'closedTestingFeedbackMissing': 'Masukan pengujian belum dikonfigurasi.',
      'copyTestingFeedback': 'Salin kanal masukan',
      'testingFeedbackTitle': 'Masukan pengujian',
      'testingFeedbackCopied': 'Kontak masukan pengujian disalin.',
      'dailySessionReminderTitle': 'Pengingat sesi harian',
      'dailySessionReminderPrivacyNote':
          'Pengingat sesi dijadwalkan lokal dan teks layar terkunci tetap aman untuk privasi.',
      'reminderTime': 'Waktu pengingat',
      'reminderTimeSaved': 'Waktu pengingat tersimpan',
      'saveReminderTime': 'Simpan waktu',
      'reminderStatusOn': 'Aktif',
      'reminderStatusOff': 'Nonaktif',
      'notificationPermissionTitle': 'Aktifkan pengingat shalat?',
      'notificationPermissionBody':
          'Sakinah menjadwalkan pengingat shalat lokal hanya setelah izin. Pengingat mode perempuan tetap aman untuk layar terkunci.',
      'notificationPermissionAllow': 'Aktifkan pengingat',
      'notificationPermissionNotNow': 'Nanti saja',
      'notificationPermissionDenied':
          'Notifikasi mati. Anda dapat mengaktifkannya dari pengaturan sistem.',
      'notificationScheduled': 'Pengingat shalat lokal telah dijadwalkan.',
      'notificationTapMalformed':
          'Notifikasi ini tidak dapat dibuka dengan aman.',
      'notificationTapFallbackPrayer': 'Membuka waktu shalat.',
      'notificationTapMissingContent':
          'Konten notifikasi ini belum tersedia offline.',
      'womenModeSubtitle':
          'Lokal secara default. Salinan pengingat sensitif tetap privat.',
      'localOnlyMode': 'Mode lokal saja',
      'womenModePrivatePath': 'Jalur lembut privat',
      'womenModeHomeSupportBody':
          'Doa, dzikir, dan refleksi tetap mudah dijangkau. Mode Anda tetap di perangkat ini.',
      'womenModeSessionNoteTitle': 'Mode lokal saja',
      'womenModeSessionNoteBody':
          'Mode Anda tetap di perangkat ini. Sesi ini menjaga jalur ibadah yang lembut.',
      'continueFromSaved': 'Lanjutkan dari tersimpan',
      'savedRailLocalNote': 'Disimpan lokal di perangkat ini.',
      'savedItems': 'Item Tersimpan',
      'savedItemsEmptyTitle': 'Belum ada yang tersimpan',
      'savedItemsEmptyBody':
          'Item tersimpan tetap di perangkat ini untuk dibuka kembali.',
      'save': 'Simpan',
      'unsave': 'Batal simpan',
      'removeSavedItem': 'Hapus item tersimpan',
      'savedLocalOnly': 'Item tersimpan tetap hanya di perangkat ini.',
      'savedItemsPrivacyNotes':
          'Disimpan lokal. Tanpa akun atau sinkronisasi di MVP.',
      'privacy': 'Privasi',
      'privacySubtitle': 'Data mode perempuan tidak dikirim jarak jauh di MVP.',
      'privacyCenterTitle': 'Pusat Privasi',
      'dataInventoryTitle': 'Inventaris data',
      'dataInventoryBody':
          'Inventaris ini menjelaskan data klien MVP dan lokasi penyimpanannya.',
      'dataOnDeviceTitle': 'Data yang disimpan di perangkat ini',
      'dataCanLeaveDeviceTitle': 'Data yang dapat keluar dari perangkat ini',
      'localOnlyData':
          'Sebagian besar preferensi, pengaturan shalat, mode perempuan, dan cache konten tetap di perangkat ini.',
      'leavesDeviceData':
          'Permintaan konten jarak jauh dapat menyertakan bahasa, pasar, versi aplikasi, dan versi skema.',
      'womenModePrivacyTitle': 'Privasi Mode Ibadah Perempuan',
      'womenModePrivacyBody':
          'Mode Ibadah Perempuan dirancang lokal terlebih dahulu. Status persis tidak dikirim dengan permintaan konten jarak jauh.',
      'prayerLocationPrivacyTitle': 'Privasi lokasi shalat',
      'prayerLocationPrivacyBody':
          'Lokasi shalat memakai pilihan manual atau preset secara default untuk perhitungan waktu shalat.',
      'notificationPrivacyTitle': 'Privasi notifikasi',
      'notificationPrivacyBody':
          'Pengingat shalat dijadwalkan lokal bila memungkinkan, dan teks sensitif mode perempuan tidak tampil di layar terkunci.',
      'remoteContentPrivacyTitle': 'Cache konten jarak jauh',
      'remoteContentPrivacyBody':
          'Bundle konten yang disetujui dapat disimpan di perangkat ini. Permintaan konten jarak jauh dapat menyertakan bahasa, pasar, versi aplikasi, dan versi skema.',
      'analyticsPrivacyTitle': 'Privasi analitik penggunaan',
      'analyticsPrivacyBody':
          'Analitik penggunaan nonaktif secara default. Jika diaktifkan dalam build yang ditinjau, Sakinah hanya mengirim event alur aplikasi yang diizinkan dan tidak pernah mengirim koordinat persis, status persis Mode Ibadah Perempuan, teks masukan, atau teks keagamaan.',
      'analyticsOptInTitle': 'Bagikan analitik penggunaan',
      'analyticsOptInAvailableBody':
          'Opsional. Membantu meningkatkan pengingat shalat dan retensi sesi hanya dengan nama event yang aman untuk privasi.',
      'analyticsOptInUnavailableBody':
          'Pengumpulan analitik nonaktif dalam build ini.',
      'deleteLocalDataTitle': 'Hapus data lokal',
      'deleteLocalDataBody':
          'Reset preferensi aplikasi, item tersimpan, progres sesi, status mode perempuan, cache konten lokal, dan pengingat terjadwal di perangkat ini.',
      'deleteLocalDataKeepsSeed':
          'Konten seed bawaan dan file aplikasi tetap ada. Ini tidak menghubungi layanan jarak jauh.',
      'deleteLocalDataConfirm': 'Hapus data lokal',
      'deleteLocalDataDeleting': 'Menghapus...',
      'deleteLocalDataDialogTitle': 'Konfirmasi reset lokal',
      'deleteLocalDataDialogBody':
          'Ini menghapus preferensi lokal, item tersimpan, progres sesi, bundle cache, dan pengingat terjadwal di perangkat ini.',
      'deleteLocalDataCancel': 'Batal',
      'deleteLocalDataSuccess': 'Data lokal telah direset di perangkat ini.',
      'storePrivacyDraftTitle': 'Ringkasan keamanan data toko',
      'storePrivacyDraftBody':
          'Draf deklarasi toko didokumentasikan untuk ditinjau sebelum pengajuan.',
      'privacyPolicyDraftTitle': 'Draf kebijakan privasi',
      'privacyPolicyDraftBody':
          'Draf kebijakan privasi tersedia untuk peninjauan legal dan toko.',
      'privacyPolicyPublishedTitle': 'Kebijakan privasi terbit',
      'privacyPolicyLinkCopied': 'Tautan kebijakan privasi disalin.',
      'contentSourcesTitle': 'Sumber Konten',
      'contentSourcesSubtitle': 'Label sumber, status review, dan batas AI.',
      'contentSourcesIntro':
          'Sakinah menampilkan konten ibadah dengan batasan sumber dan review agar pengguna memahami yang dibaca atau didengar.',
      'contentSourcesSeedTitle': 'Seed yang ditinjau dan bundle yang disetujui',
      'contentSourcesSeedBody':
          'Konten Quran, Doa, Dzikir, dan sesi yang tampil di aplikasi harus berasal dari seed yang ditinjau atau bundle CMS yang disetujui.',
      'contentSourcesApprovalTitle': 'Hanya published + approved',
      'contentSourcesApprovalBody':
          'Konten CMS jarak jauh disembunyikan kecuali sudah published dan approved. Konten draf, sedang ditinjau, ditolak, atau dicabut disaring.',
      'contentSourcesGeneratedTitle': 'Tidak dibuat otomatis',
      'contentSourcesGeneratedBody':
          'Klien tidak membuat teks Quran, terjemahan, Doa, Dzikir, refleksi, atau jawaban agama secara otomatis.',
      'contentSourcesAudioTitle': 'Keamanan audio Quran',
      'contentSourcesAudioBody':
          'Tilawah Quran hanya memakai aset suara yang disetujui. Tidak ada TTS Quran generik dan tidak ada musik latar di bawah tilawah Quran.',
      'contentSourcesFatwaTitle': 'Tanpa fatwa AI atau tanya jawab agama AI',
      'contentSourcesFatwaBody':
          'Saat ada perbedaan mazhab atau wilayah, Sakinah memakai kata-kata netral dan label sumber, bukan klaim bergaya fatwa.',
      'storageLocalDevice': 'Perangkat lokal',
      'storageRemoteOptional': 'Permintaan jarak jauh',
      'storageNotCollected': 'Tidak dikumpulkan',
      'sensitivityLow': 'Sensitivitas rendah',
      'sensitivityMedium': 'Sensitivitas sedang',
      'sensitivityHigh': 'Sensitivitas tinggi',
      'localOnlyShort': 'Lokal saja',
      'leavesDeviceShort': 'Keluar perangkat',
      'userCanDeleteShort': 'Dapat dihapus pengguna',
      'privacyDataLanguagePreference': 'Preferensi bahasa',
      'privacyDataLanguagePreferenceNotes':
          'Disimpan lokal dan dipakai untuk memilih bahasa aplikasi dan konten.',
      'privacyDataGenderModePreference': 'Preferensi mode gender',
      'privacyDataGenderModePreferenceNotes':
          'Disimpan lokal untuk personalisasi klien di MVP.',
      'privacyDataAudioPreference': 'Preferensi audio',
      'privacyDataAudioPreferenceNotes':
          'Disimpan lokal untuk memilih tilawah saja, panduan, atau teks dahulu.',
      'privacyDataPrayerSettings': 'Pengaturan shalat',
      'privacyDataPrayerSettingsNotes':
          'Disimpan lokal untuk metode dan pengaturan perhitungan waktu shalat.',
      'privacyDataPrayerLocationPreset': 'Preset lokasi shalat',
      'privacyDataPrayerLocationPresetNotes':
          'Disimpan lokal secara default sebagai pilihan lokasi manual atau preset.',
      'privacyDataNotificationEnabledState': 'Status notifikasi aktif',
      'privacyDataNotificationEnabledStateNotes':
          'Disimpan lokal untuk mengingat status pengingat shalat, pilihan per shalat, jeda waktu pengingat shalat, status pengingat sesi harian, dan waktu pengingat sesi harian yang dipilih.',
      'privacyDataClosedTestingFeedbackStatus': 'Status masukan closed testing',
      'privacyDataClosedTestingFeedbackStatusNotes':
          'Hanya menyimpan apakah masukan Hari 1, Hari 3, Hari 7, atau Hari 14 ditandai terkirim. Teks masukan dan detail pribadi tidak disimpan.',
      'privacyDataWomenModeState': 'Status Mode Ibadah Perempuan',
      'privacyDataWomenModeStateNotes':
          'Sensitivitas tinggi. Dirancang lokal terlebih dahulu, dapat menyesuaikan rekomendasi UI lokal, dan tidak dikirim ke API konten jarak jauh.',
      'privacyDataLocalContentManifest': 'Manifest konten lokal',
      'privacyDataLocalContentManifestNotes':
          'Disimpan lokal untuk mengetahui bundle yang aktif dan disetujui.',
      'privacyDataLocalContentBundles': 'Bundle konten lokal',
      'privacyDataLocalContentBundlesNotes':
          'Disimpan lokal setelah pemeriksaan hash, skema, published, dan approved.',
      'privacyDataLocalRevokedContentIds': 'ID konten dicabut lokal',
      'privacyDataLocalRevokedContentIdsNotes':
          'Disimpan lokal agar konten yang dicabut disembunyikan dari klien.',
      'privacyDataSavedItems': 'Item tersimpan',
      'privacyDataSavedItemsNotes':
          'Sesi, doa, dzikir, dan referensi ayat yang disimpan tetap lokal.',
      'privacyDataSessionProgressHistory': 'Riwayat progres sesi',
      'privacyDataSessionProgressHistoryNotes':
          'Progres sesi dan catatan selesai hanya menyimpan ID sesi dan waktu secara lokal.',
      'privacyDataPrayerCompletionHistory': 'Riwayat penyelesaian shalat',
      'privacyDataPrayerCompletionHistoryNotes':
          'Catatan shalat menyimpan nama shalat dan waktu selesai lokal hanya di perangkat ini.',
      'privacyDataLocalPushDebug': 'Data debug payload push lokal',
      'privacyDataLocalPushDebugNotes':
          'Tidak ada antrean debug klien yang persisten di MVP.',
      'privacyDataAudioPlaybackState': 'Status pemutaran audio',
      'privacyDataAudioPlaybackStateNotes':
          'Riwayat pemutaran persisten tidak dikumpulkan di MVP.',
      'privacyDataRemoteContentApiConfig': 'Status konfigurasi API konten',
      'privacyDataRemoteContentApiConfigNotes':
          'Konfigurasi provider dan endpoint dapat ada secara lokal; token tidak pernah ditampilkan di Pusat Privasi.',
      'privacyDataRemoteContentRequestMetadata':
          'Metadata permintaan konten jarak jauh',
      'remoteContentRequestMetadataNotes':
          'Permintaan hanya dapat menyertakan bahasa, pasar, versi aplikasi, dan versi skema.',
      'privacyDataAnalyticsConsent': 'Preferensi persetujuan analitik',
      'privacyDataAnalyticsConsentNotes':
          'Disimpan lokal. Mematikannya menonaktifkan pengumpulan Firebase Analytics saat build analitik dikonfigurasi.',
      'privacyDataAnalyticsEvents': 'Event analitik default-nonaktif',
      'privacyDataAnalyticsEventsNotes':
          'Hanya dikirim saat analitik diaktifkan untuk build dan pengguna menyetujui. Event memakai daftar yang diizinkan dan mengecualikan koordinat, masukan, teks keagamaan, dan status persis Mode Ibadah Perempuan.',
      'privacyDataFutureAnalyticsCrash': 'Crash reporting',
      'privacyDataFutureAnalyticsCrashNotes':
          'SDK crash-reporting belum diterapkan di MVP.',
      'privacyDataAccountData': 'Data akun',
      'privacyDataAccountDataNotes': 'Login akun belum diterapkan di MVP.',
      'privacyDataPaymentsSubscriptions': 'Pembayaran dan langganan',
      'privacyDataPaymentsSubscriptionsNotes':
          'Pembayaran dan langganan belum diterapkan di MVP.',
      'privacyDataAdsTracking': 'Iklan atau pelacakan',
      'privacyDataAdsTrackingNotes':
          'Iklan, pelacakan, dan prompt ATT belum diterapkan di MVP.',
      'source': 'Sumber',
      'reviewed': 'Ditinjau',
      'approvedContent': 'konten disetujui',
      'draftContent': 'konten draf',
      'inReviewContent': 'konten sedang ditinjau',
      'rejectedContent': 'konten ditolak',
      'womenMode': 'Mode Ibadah Perempuan',
      'womenModeDescription': 'Atur pengingat dengan privasi dan penghormatan.',
      'womenModeWhatChangesTitle': 'Yang berubah secara lokal',
      'womenModeWhatChangesBody':
          'Rekomendasi Beranda dapat menjadi lebih tenang dan menonjolkan doa, dzikir, dan refleksi. Sesi harian dapat menampilkan catatan privat lokal saja.',
      'womenModeWhatStaysPrivateTitle': 'Yang tidak meninggalkan perangkat ini',
      'womenModeWhatStaysPrivateBody':
          'Mode persis Anda disimpan lokal dan tidak dikirim dengan permintaan konten jarak jauh.',
      'womenModeReminderPrivacyBody':
          'Teks pengingat tetap umum agar salinan layar kunci tidak membuka detail privat.',
      'womenModeTurnOffBody':
          'Matikan mode ini dengan memilih Normal, atau hapus dari Pusat Privasi > Hapus data lokal.',
      'openPrivacyCenter': 'Buka Pusat Privasi',
      'todaysMode': 'Mode hari ini',
      'modeNormal': 'Normal',
      'modeMenstruating': 'Menstruasi',
      'modePostpartum': 'Nifas',
      'modePregnancy': 'Kehamilan',
      'modePreferNotToTrack': 'Tidak dilacak',
      'dataStaysLocal': 'Data tetap lokal secara default',
      'recommendedNow': 'Direkomendasikan sekarang',
      'gentleWorshipMoment': 'Momen ibadah yang lembut',
      'womenRecommendedDescription':
          'Pengingat doa · dzikir · refleksi tanpa ajakan shalat langsung.',
      'reminderBehavior': 'Perilaku pengingat',
      'reminderBehaviorDescription':
          'Peringatan shalat dapat dijeda atau diganti dengan momen doa dan dzikir.',
      'duaUnavailable': 'Doa tidak tersedia.',
      'makeDua': 'Berdoa',
      'duaContext': 'Untuk fokus · Sebelum bekerja atau belajar',
      'saved': 'Tersimpan',
      'arabicLabel': 'Arab',
      'transliteration': 'Transliterasi',
      'meaning': 'Makna',
      'listen': 'Dengarkan',
      'repeatSlowly': 'Ulangi perlahan',
      'session': 'Sesi',
      'sessionUnavailable': 'Sesi tidak tersedia.',
      'next': 'Berikutnya',
      'finish': 'Selesai',
      'playRecitation': 'Putar tilawah',
      'pauseRecitation': 'Jeda tilawah',
      'textOnlyFallback': 'Fallback teks saja',
      'audioUnavailable': 'Audio tidak tersedia',
      'approvedReciter': 'qari yang disetujui',
      'approvedReciterLabel': 'Qari yang disetujui',
      'quranSafetyTitle': 'Keamanan Qur’an',
      'quranSafetyDescription':
          'Tidak ada suara latar di bawah tilawah Qur’an.',
      'reflectionSafetyTitle': 'Catatan renungan',
      'reflectionSafetyDescription':
          'Renungan adalah pengingat lembut, bukan fatwa atau putusan agama.',
      'completionFallback':
          'Berhenti sejenak, bernapas, dan jaga amal ini hanya untuk Allah.',
      'backgroundSoundAllowed': 'Suara latar diizinkan',
      'noBackgroundMusic': 'Tidak ada musik latar di bawah tilawah Quran',
      'timeIn': 'dalam',
      'hourShort': 'j',
      'minuteShort': 'm',
      'prayerFajr': 'Subuh',
      'prayerDhuhr': 'Zuhur',
      'prayerAsr': 'Asar',
      'prayerMaghrib': 'Magrib',
      'prayerIsha': 'Isya',
    },
    'ar': {
      'appTitle': 'سكينة يومية',
      'splashTagline': 'طمأنينة للقلب،\nوذكر لليوم',
      'splashFeatureLine': 'القرآن   ·   الدعاء   ·   الذكر   ·   الصلاة',
      'onboardingTitle': 'ابدأ بعبادة هادئة',
      'onboardingSubtitle': 'اختر اللغة والتفضيلات لرفيق يومي مطمئن.',
      'language': 'اللغة',
      'genderMode': 'التخصيص',
      'genderMale': 'ذكر',
      'genderFemale': 'أنثى',
      'genderPreferNotToSay': 'أفضل عدم الإجابة',
      'audioPreference': 'تفضيل الصوت',
      'audioRecitationOnly': 'التلاوة فقط',
      'audioQuietGuidance': 'إرشاد هادئ',
      'audioTextFirst': 'النص أولا',
      'prayerReminderConsent': 'تطلب تذكيرات الصلاة الإذن بعد هذا الشرح فقط.',
      'onboardingPrayerLocationBody':
          'تستخدم أوقات الصلاة والقبلة موقع الصلاة المحلي هذا.',
      'onboardingPrayerNoGps': 'لا يتم طلب إذن GPS في v0.1.',
      'continueLabel': 'متابعة',
      'homeGreeting': 'السلام عليكم',
      'homeFriend': 'رفيق',
      'homeFemaleName': 'عائشة',
      'homeDateLabel': 'الثلاثاء · 12 رمضان',
      'nextPrayer': 'الصلاة التالية',
      'dailyPrayerHomeTitle': 'الصلاة اليومية في المركز',
      'viewPrayerTimes': 'عرض أوقات الصلاة',
      'manageReminders': 'إدارة التذكيرات',
      'changeLocation': 'تغيير الموقع',
      'todaySession': 'جلسة السكينة اليوم',
      'sessionSubtitleMeta': '7 دقائق · آية · تأمل · دعاء · ذكر',
      'quickActions': 'إجراءات سريعة',
      'startSession': 'ابدأ الجلسة',
      'start': 'ابدأ',
      'voiceOnly': 'الصوت فقط',
      'home': 'الرئيسية',
      'quran': 'القرآن',
      'quranPageTitle': 'القرآن',
      'featuredAyah': 'آية مختارة',
      'openAyah': 'فتح الآية',
      'quranAvailableVerses': 'آيات متاحة',
      'quranLocalOnlyBrowserBody':
          'تصفح آيات البذرة المحلية التي تمت مراجعتها فقط. يتطلب المزيد من محتوى القرآن مصادر معتمدة.',
      'quranVerseSearchHint': 'ابحث بمرجع الآية أو المعنى',
      'quranVerseNoResults': 'لا توجد آية محلية مراجعة تطابق هذا البحث.',
      'quranVerseUnavailable': 'آية القرآن غير متاحة',
      'quranPreviousVerse': 'الآية السابقة',
      'quranNextVerse': 'الآية التالية',
      'saveAyah': 'حفظ الآية',
      'savedAyah': 'الآية محفوظة',
      'quranVoiceOnlyTitle': 'تلاوة القرآن صوت فقط',
      'quranVoiceOnlyBody':
          'تستخدم تلاوة القرآن أصولا صوتية معتمدة فقط ولا تعتمد على صوت قرآن اصطناعي.',
      'noQuranTts': 'لا يوجد TTS للقرآن',
      'noQuranBgm': 'لا موسيقى خلفية تحت تلاوة القرآن',
      'qibla': 'القبلة',
      'qiblaTitle': 'اتجاه القبلة',
      'qiblaBearing': 'زاوية القبلة',
      'qiblaBasedOnSelectedLocation': 'تستخدم القبلة موقع الصلاة المختار.',
      'qiblaChangeLocation': 'تغيير موقع الصلاة',
      'qiblaNoGpsRequired':
          'تستخدم القبلة موقع الصلاة المختار. لا يلزم GPS دقيق.',
      'tonight': 'الليلة',
      'sleepAyatKursi': 'نم مع آية الكرسي',
      'sleepSessionDescription':
          'جلسة هادئة من 5 دقائق مع تلاوة قرآن صافية وإرشاد لطيف.',
      'saveTonight': 'احفظ لليلة',
      'savedTonight': 'حفظت لليلة',
      'sessionCompletedTitle': 'اكتملت الجلسة',
      'sessionCompletedBody':
          'أكملت جلسة السكينة هذه. خذ لحظة هادئة قبل العودة.',
      'completedToday': 'اكتملت اليوم',
      'resumeSession': 'متابعة',
      'reviewSession': 'مراجعة',
      'localProgress': 'التقدم المحلي',
      'currentStreak': 'السلسلة الحالية',
      'completedThisWeek': 'اكتمل هذا الأسبوع',
      'progressLocalOnly': 'يبقى التقدم على هذا الجهاز فقط.',
      'prayersToday': 'الصلوات اليوم',
      'prayerCheckInsLocalOnly': 'تبقى علامات الصلاة على هذا الجهاز فقط.',
      'prayerWeekProgress': 'أسبوع الصلاة',
      'prayerWeekCheckInDays': 'أيام المتابعة',
      'prayerWeekStreak': 'سلسلة الصلاة',
      'saveSession': 'حفظ الجلسة',
      'sessionSaved': 'تم حفظ الجلسة',
      'openSavedItems': 'فتح العناصر المحفوظة',
      'setDailyReminder': 'ضبط تذكير يومي',
      'dailyReminderSet': 'تم ضبط التذكير اليومي',
      'manageDailyReminder': 'إدارة التذكير اليومي',
      'sessionReminderPermissionTitle': 'ضبط تذكير يومي؟',
      'sessionReminderPermissionBody':
          'يمكن لسكينة جدولة تذكير جلسة يومي محلي. يبقى نص التذكير آمنا على شاشة القفل.',
      'sessionReminderPermissionAllow': 'ضبط التذكير',
      'sessionReminderPermissionNotNow': 'ليس الآن',
      'backHome': 'العودة للرئيسية',
      'sessionProgressHistory': 'سجل تقدم الجلسات',
      'sessionProgressHistoryNotes':
          'يحفظ تقدم الجلسات وسجل الإكمال محليا فقط.',
      'noGuaranteedOutcome': 'لا يوجد ادعاء بنتيجة روحية مضمونة.',
      'dua': 'الدعاء',
      'dhikr': 'الذكر',
      'allCategories': 'الكل',
      'searchDuaHint': 'ابحث في الأدعية',
      'searchDhikrHint': 'ابحث في الأذكار',
      'noDuaResultsTitle': 'لا توجد أدعية',
      'noDuaResultsBody': 'جرب تصنيفا أو كلمة بحث أخرى.',
      'noDhikrResultsTitle': 'لا توجد أذكار',
      'noDhikrResultsBody': 'جرب تصنيفا أو كلمة بحث أخرى.',
      'categoryQuranic': 'من القرآن',
      'categoryMorning': 'الصباح',
      'categoryEvening': 'المساء',
      'categoryReflection': 'التأمل',
      'categoryDifficulty': 'الصعوبة',
      'categoryGratitude': 'الشكر',
      'categoryForgiveness': 'المغفرة',
      'categoryGeneral': 'عام',
      'settings': 'الإعدادات',
      'prayer': 'الصلاة',
      'prayerLocation': 'موقع الصلاة',
      'manualPrayerLocationTitle': 'موقع الصلاة اليدوي',
      'manualPrayerLocationBody':
          'أدخل موقع الصلاة يدويا. يخزن محليا ويستخدم لأوقات الصلاة والقبلة.',
      'locationLabel': 'اسم الموقع',
      'latitude': 'خط العرض',
      'longitude': 'خط الطول',
      'timezoneId': 'معرف المنطقة الزمنية',
      'saveLocation': 'حفظ الموقع',
      'invalidLatitude': 'يجب أن يكون خط العرض بين -90 و90.',
      'invalidLongitude': 'يجب أن يكون خط الطول بين -180 و180.',
      'locationSaved': 'تم حفظ الموقع',
      'locationLocalOnlyNoGps': 'يحفظ محليا. لا يلزم إذن GPS.',
      'prayerMethod': 'طريقة الصلاة',
      'prayerReminders': 'تذكيرات الصلاة',
      'todaysPrayerTimes': 'أوقات الصلاة اليوم',
      'currentPrayerStatus': 'الحالية',
      'nextPrayerStatus': 'التالية',
      'todaysPrayerCheckIn': 'متابعة صلوات اليوم',
      'prayerCheckInBody':
          'علّم الصلوات التي أديتها. تُحفظ على هذا الجهاز فقط.',
      'todaysPrayerCheckInComplete': 'تمت متابعة صلوات اليوم',
      'prayerCheckInCompleteBody':
          'تم حفظ علامات الصلوات الخمس على هذا الجهاز فقط.',
      'prayerCompletedStatus': 'مكتملة',
      'prayerReminderSubtitle': 'يطلب الإذن بعد الشرح.',
      'prayerReminderChoicesTitle': 'اختيارات تذكيرات الصلاة',
      'prayerReminderChoicesBody':
          'اختر أوقات الصلاة التي يمكن أن ترسل تذكيرات محلية.',
      'prayerReminderChoiceSubtitle': 'محدد لجدول التذكير',
      'prayerReminderLeadTimeTitle': 'توقيت التذكير',
      'prayerReminderLeadTimeBody':
          'أرسل كل تذكير صلاة محدد عند وقت الصلاة أو قبله بدقائق.',
      'nextPrayerReminderPreview': 'تذكير الصلاة التالي',
      'notificationSettingsTitle': 'إعدادات الإشعارات',
      'notificationSettingsSubtitle': 'إدارة تذكيرات الصلاة والجلسة اليومية.',
      'closedTestingGuideTitle': 'دليل الاختبار المغلق',
      'closedTestingGuideSubtitle':
          'فحوصات يومية للصلاة والتذكيرات والجلسة والخصوصية.',
      'closedTestingHomeBody':
          'استخدم أسئلة اليوم 1 / اليوم 3 / اليوم 7 / اليوم 14 لإرسال ملاحظات دون تفاصيل شخصية.',
      'closedTestingNextFeedback': 'الملاحظة التالية',
      'closedTestingAllFeedbackSent': 'تم تعليم كل الملاحظات كمرسلة',
      'closedTestingHomeButton': 'فتح الدليل',
      'closedTestingGuideIntroTitle': 'ساعد في اختبار مسار الصلاة اليومي',
      'closedTestingGuideIntroBody':
          'استخدم هذه القائمة أثناء الاختبار المغلق حتى تغطي الملاحظات الأجزاء المهمة لجودة الإطلاق والعودة اليومية.',
      'closedTestingGuideChecklistTitle': 'قائمة فحص المختبر اليومية',
      'closedTestingChecklistDailyOpen':
          'افتح التطبيق مرة كل يوم ولاحظ هل تبدو الصفحة الرئيسية مفيدة بما يكفي للعودة.',
      'closedTestingChecklistPrayer':
          'راجع وقت الصلاة التالية وموقع الصلاة والطريقة وقائمة أوقات اليوم.',
      'closedTestingChecklistReminder':
          'راجع إعدادات التذكير وفعل التذكيرات فقط إذا كان ذلك مناسبا لك.',
      'closedTestingChecklistSession':
          'ابدأ جلسة سكينة اليوم وأكملها أو تابعها لاحقا.',
      'closedTestingChecklistPrivacy':
          'راجع مركز الخصوصية ومصادر المحتوى وحذف البيانات المحلية.',
      'closedTestingChecklistFeedback':
          'أرسل ملاحظات عن النص غير الواضح أو مشاكل التوقيت أو التخطيط أو أي شيء جعلك تتجاهل التطبيق.',
      'closedTestingPromptTitle': 'أسئلة الملاحظات',
      'closedTestingPromptBody':
          'استخدم هذه المحطات لإرسال ملاحظات تساعد اختبار 14 يوما على تحسين العودة اليومية.',
      'closedTestingPromptDay1Label': 'اليوم 1',
      'closedTestingPromptDay1':
          'هل شرح التهيئة خيارات الموقع والإشعارات بوضوح؟',
      'closedTestingPromptDay3Label': 'اليوم 3',
      'closedTestingPromptDay3':
          'هل كانت أوقات الصلاة والموقع وعناصر التحكم بالتذكير موثوقة وواضحة؟',
      'closedTestingPromptDay7Label': 'اليوم 7',
      'closedTestingPromptDay7':
          'ما الذي جعلك ترغب في فتح التطبيق مرة أخرى أو تجاهله هذا الأسبوع؟',
      'closedTestingPromptDay14Label': 'اليوم 14',
      'closedTestingPromptDay14':
          'ما التغيير الواحد الذي يحسن الاستخدام اليومي قبل إصدار أوسع؟',
      'copyTestingFeedbackPrompt': 'نسخ السؤال',
      'closedTestingPromptCopied': 'تم نسخ سؤال الملاحظات.',
      'closedTestingPromptCopyHeader': 'ملاحظات اختبار Sakinah Daily المغلق',
      'closedTestingPromptCopyPromptLabel': 'السؤال',
      'closedTestingPromptCopyThemeLabel': 'الموضوع المقترح',
      'closedTestingPromptCopyChannelLabel': 'قناة الملاحظات',
      'closedTestingPromptCopyPrivacyLine':
          'يرجى تجنب التفاصيل الشخصية أو الصحية الحساسة.',
      'closedTestingPromptFeedbackSent': 'تم إرسال الملاحظات',
      'closedTestingPromptLocalOnlyStatus': 'محفوظ على هذا الجهاز فقط.',
      'closedTestingFeedbackTitle': 'قناة الملاحظات',
      'closedTestingFeedbackBody':
          'انسخ هذه القناة عند إرسال ملاحظات الاختبار المغلق.',
      'closedTestingFeedbackMissing': 'لم يتم إعداد ملاحظات الاختبار بعد.',
      'copyTestingFeedback': 'نسخ قناة الملاحظات',
      'testingFeedbackTitle': 'ملاحظات الاختبار',
      'testingFeedbackCopied': 'تم نسخ قناة ملاحظات الاختبار.',
      'dailySessionReminderTitle': 'تذكير الجلسة اليومية',
      'dailySessionReminderPrivacyNote':
          'تجدول تذكيرات الجلسة محليا ويبقى نص شاشة القفل آمنا للخصوصية.',
      'reminderTime': 'وقت التذكير',
      'reminderTimeSaved': 'تم حفظ وقت التذكير',
      'saveReminderTime': 'حفظ الوقت',
      'reminderStatusOn': 'مفعل',
      'reminderStatusOff': 'متوقف',
      'notificationPermissionTitle': 'تفعيل تذكيرات الصلاة؟',
      'notificationPermissionBody':
          'تجدول سكينة تذكيرات صلاة محلية بعد الإذن فقط. تبقى تذكيرات وضع النساء آمنة على شاشة القفل.',
      'notificationPermissionAllow': 'تفعيل التذكيرات',
      'notificationPermissionNotNow': 'ليس الآن',
      'notificationPermissionDenied':
          'الإشعارات متوقفة. يمكنك تفعيلها من إعدادات النظام.',
      'notificationScheduled': 'تم جدولة تذكيرات الصلاة المحلية.',
      'notificationTapMalformed': 'تعذر فتح هذا الإشعار بأمان.',
      'notificationTapFallbackPrayer': 'فتح أوقات الصلاة.',
      'notificationTapMissingContent':
          'محتوى هذا الإشعار غير متاح دون اتصال بعد.',
      'womenModeSubtitle': 'محلي افتراضيا. تبقى نصوص التذكير الحساسة خاصة.',
      'localOnlyMode': 'وضع محلي فقط',
      'womenModePrivatePath': 'مسار لطيف وخاص',
      'womenModeHomeSupportBody':
          'يبقى الدعاء والذكر والتأمل قريبين وسهلين. يبقى وضعك على هذا الجهاز.',
      'womenModeSessionNoteTitle': 'وضع محلي فقط',
      'womenModeSessionNoteBody':
          'يبقى وضعك على هذا الجهاز. تحافظ هذه الجلسة على مسار عبادة لطيف.',
      'continueFromSaved': 'تابع من المحفوظ',
      'savedRailLocalNote': 'محفوظ محليا على هذا الجهاز.',
      'savedItems': 'العناصر المحفوظة',
      'savedItemsEmptyTitle': 'لا توجد عناصر محفوظة بعد',
      'savedItemsEmptyBody':
          'تبقى العناصر المحفوظة على هذا الجهاز للرجوع إليها لاحقا.',
      'save': 'حفظ',
      'unsave': 'إلغاء الحفظ',
      'removeSavedItem': 'إزالة العنصر المحفوظ',
      'savedLocalOnly': 'تبقى العناصر المحفوظة على هذا الجهاز فقط.',
      'savedItemsPrivacyNotes': 'تحفظ محليا. لا حساب ولا مزامنة في نسخة MVP.',
      'privacy': 'الخصوصية',
      'privacySubtitle': 'لا ترسل بيانات وضع النساء عن بعد في نسخة MVP.',
      'privacyCenterTitle': 'مركز الخصوصية',
      'dataInventoryTitle': 'قائمة البيانات',
      'dataInventoryBody':
          'تصف هذه القائمة بيانات العميل في نسخة MVP ومكان تخزينها.',
      'dataOnDeviceTitle': 'البيانات التي تبقى على هذا الجهاز',
      'dataCanLeaveDeviceTitle': 'البيانات التي قد تغادر هذا الجهاز',
      'localOnlyData':
          'تبقى معظم التفضيلات وإعدادات الصلاة ووضع النساء وذاكرة المحتوى على هذا الجهاز.',
      'leavesDeviceData':
          'قد تتضمن طلبات المحتوى اللغة والسوق وإصدار التطبيق وإصدار المخطط.',
      'womenModePrivacyTitle': 'خصوصية وضع عبادة النساء',
      'womenModePrivacyBody':
          'صمم وضع عبادة النساء ليكون محليا أولا. لا ترسل الحالة الدقيقة مع طلبات المحتوى عن بعد.',
      'prayerLocationPrivacyTitle': 'خصوصية موقع الصلاة',
      'prayerLocationPrivacyBody':
          'يستخدم موقع الصلاة اختيارات يدوية أو جاهزة افتراضيا لحساب أوقات الصلاة.',
      'notificationPrivacyTitle': 'خصوصية الإشعارات',
      'notificationPrivacyBody':
          'تجدول تذكيرات الصلاة محليا حيثما أمكن، وتبقى نصوص وضع النساء الحساسة خارج شاشة القفل.',
      'remoteContentPrivacyTitle': 'ذاكرة المحتوى عن بعد',
      'remoteContentPrivacyBody':
          'يمكن تخزين حزم المحتوى المعتمدة على هذا الجهاز. قد تتضمن طلبات المحتوى اللغة والسوق وإصدار التطبيق وإصدار المخطط.',
      'analyticsPrivacyTitle': 'خصوصية تحليلات الاستخدام',
      'analyticsPrivacyBody':
          'تحليلات الاستخدام متوقفة افتراضيا. إذا فعلت في بناء تمت مراجعته، ترسل سكينة أحداث مسار التطبيق المسموح بها فقط ولا ترسل الإحداثيات الدقيقة أو الحالة الدقيقة لوضع عبادة النساء أو نص الملاحظات أو النصوص الدينية.',
      'analyticsOptInTitle': 'مشاركة تحليلات الاستخدام',
      'analyticsOptInAvailableBody':
          'اختياري. يساعد على تحسين تذكيرات الصلاة والاحتفاظ بالجلسات باستخدام أسماء أحداث آمنة للخصوصية فقط.',
      'analyticsOptInUnavailableBody': 'جمع التحليلات متوقف في هذا البناء.',
      'deleteLocalDataTitle': 'حذف البيانات المحلية',
      'deleteLocalDataBody':
          'إعادة ضبط تفضيلات التطبيق والعناصر المحفوظة وتقدم الجلسات وحالة وضع النساء وذاكرة المحتوى المحلية والتذكيرات المجدولة على هذا الجهاز.',
      'deleteLocalDataKeepsSeed':
          'يبقى محتوى التطبيق المضمن وملفات التطبيق. لا يتصل هذا بخدمة عن بعد.',
      'deleteLocalDataConfirm': 'حذف البيانات المحلية',
      'deleteLocalDataDeleting': 'جار الحذف...',
      'deleteLocalDataDialogTitle': 'تأكيد إعادة الضبط المحلية',
      'deleteLocalDataDialogBody':
          'يمسح هذا التفضيلات المحلية والعناصر المحفوظة وتقدم الجلسات والحزم المخزنة والتذكيرات المجدولة على هذا الجهاز.',
      'deleteLocalDataCancel': 'إلغاء',
      'deleteLocalDataSuccess':
          'تمت إعادة ضبط البيانات المحلية على هذا الجهاز.',
      'storePrivacyDraftTitle': 'ملخص سلامة بيانات المتجر',
      'storePrivacyDraftBody':
          'تم توثيق مسودات إقرارات المتجر للمراجعة قبل الإرسال.',
      'privacyPolicyDraftTitle': 'مسودة سياسة الخصوصية',
      'privacyPolicyDraftBody':
          'توجد مسودة سياسة خصوصية للمراجعة القانونية ومراجعة المتجر.',
      'privacyPolicyPublishedTitle': 'سياسة الخصوصية المنشورة',
      'privacyPolicyLinkCopied': 'تم نسخ رابط سياسة الخصوصية.',
      'contentSourcesTitle': 'مصادر المحتوى',
      'contentSourcesSubtitle':
          'تسميات المصادر وحالة المراجعة وحدود الذكاء الاصطناعي.',
      'contentSourcesIntro':
          'تعرض سكينة محتوى العبادة مع ضوابط المصدر والمراجعة حتى يفهم المستخدم ما يقرأه أو يسمعه.',
      'contentSourcesSeedTitle': 'محتوى مبدئي مراجع وحزم معتمدة',
      'contentSourcesSeedBody':
          'يجب أن يأتي محتوى القرآن والدعاء والذكر والجلسات المعروض في التطبيق من محتوى مبدئي مراجع أو حزم CMS معتمدة.',
      'contentSourcesApprovalTitle': 'منشور ومعتمد فقط',
      'contentSourcesApprovalBody':
          'يخفى محتوى CMS عن بعد ما لم يكن منشورا ومعتمدا معا. تتم تصفية المسودات والمحتوى قيد المراجعة أو المرفوض أو الملغى.',
      'contentSourcesGeneratedTitle': 'غير مولد',
      'contentSourcesGeneratedBody':
          'لا يولد العميل نص القرآن أو الترجمات أو الدعاء أو الذكر أو التأمل أو الإجابات الدينية.',
      'contentSourcesAudioTitle': 'سلامة صوت القرآن',
      'contentSourcesAudioBody':
          'تستخدم تلاوة القرآن أصولا صوتية معتمدة فقط. لا يوجد TTS عام للقرآن ولا موسيقى خلفية تحت تلاوة القرآن.',
      'contentSourcesFatwaTitle': 'لا فتاوى AI ولا أسئلة دينية AI',
      'contentSourcesFatwaBody':
          'عند وجود اختلافات مذهبية أو إقليمية، تستخدم سكينة صياغة محايدة وتسميات مصادر بدلا من ادعاءات تشبه الفتوى.',
      'storageLocalDevice': 'الجهاز المحلي',
      'storageRemoteOptional': 'طلب عن بعد',
      'storageNotCollected': 'لا تجمع',
      'sensitivityLow': 'حساسية منخفضة',
      'sensitivityMedium': 'حساسية متوسطة',
      'sensitivityHigh': 'حساسية عالية',
      'localOnlyShort': 'محلي فقط',
      'leavesDeviceShort': 'يغادر الجهاز',
      'userCanDeleteShort': 'يمكن للمستخدم حذفه',
      'privacyDataLanguagePreference': 'تفضيل اللغة',
      'privacyDataLanguagePreferenceNotes':
          'يخزن محليا لاختيار لغة التطبيق ولغة المحتوى.',
      'privacyDataGenderModePreference': 'تفضيل وضع الجنس',
      'privacyDataGenderModePreferenceNotes':
          'يخزن محليا لتخصيص العميل في نسخة MVP.',
      'privacyDataAudioPreference': 'تفضيل الصوت',
      'privacyDataAudioPreferenceNotes':
          'يخزن محليا لاختيار التلاوة فقط أو الإرشاد أو النص أولا.',
      'privacyDataPrayerSettings': 'إعدادات الصلاة',
      'privacyDataPrayerSettingsNotes':
          'تخزن محليا لطريقة حساب أوقات الصلاة وإعداداتها.',
      'privacyDataPrayerLocationPreset': 'موقع الصلاة الجاهز',
      'privacyDataPrayerLocationPresetNotes':
          'يخزن محليا افتراضيا كاختيار يدوي أو جاهز للموقع.',
      'privacyDataNotificationEnabledState': 'حالة تفعيل الإشعارات',
      'privacyDataNotificationEnabledStateNotes':
          'تخزن محليا لتذكر حالة تذكيرات الصلاة، واختيارات كل صلاة، ومدة التذكير قبل الصلاة، وحالة تذكير الجلسة اليومية، ووقت تذكير الجلسة اليومي المختار.',
      'privacyDataClosedTestingFeedbackStatus': 'حالة ملاحظات الاختبار المغلق',
      'privacyDataClosedTestingFeedbackStatusNotes':
          'يخزن فقط ما إذا تم تحديد ملاحظات اليوم 1 أو اليوم 3 أو اليوم 7 أو اليوم 14 كمرسلة. لا يتم حفظ نص الملاحظات أو التفاصيل الشخصية.',
      'privacyDataWomenModeState': 'حالة وضع عبادة النساء',
      'privacyDataWomenModeStateNotes':
          'حساسية عالية. صممت محلية أولا، وقد تضبط توصيات الواجهة المحلية، ولا ترسل إلى واجهات المحتوى عن بعد.',
      'privacyDataLocalContentManifest': 'بيان المحتوى المحلي',
      'privacyDataLocalContentManifestNotes':
          'يخزن محليا لمعرفة الحزم المعتمدة النشطة.',
      'privacyDataLocalContentBundles': 'حزم المحتوى المحلية',
      'privacyDataLocalContentBundlesNotes':
          'تخزن محليا بعد فحص البصمة والمخطط والنشر والاعتماد.',
      'privacyDataLocalRevokedContentIds': 'معرفات المحتوى الملغى محليا',
      'privacyDataLocalRevokedContentIdsNotes':
          'تخزن محليا حتى يخفى المحتوى الملغى من العميل.',
      'privacyDataSavedItems': 'العناصر المحفوظة',
      'privacyDataSavedItemsNotes':
          'تبقى الجلسات والأدعية والأذكار ومراجع الآيات المحفوظة محلية فقط.',
      'privacyDataSessionProgressHistory': 'سجل تقدم الجلسات',
      'privacyDataSessionProgressHistoryNotes':
          'يحفظ تقدم الجلسات وسجلات الإكمال معرفات الجلسات والأوقات محليا فقط.',
      'privacyDataPrayerCompletionHistory': 'سجل إكمال الصلاة',
      'privacyDataPrayerCompletionHistoryNotes':
          'تحفظ علامات الصلاة أسماء الصلوات وأوقات الإكمال المحلية على هذا الجهاز فقط.',
      'privacyDataLocalPushDebug': 'بيانات تصحيح رسائل الدفع المحلية',
      'privacyDataLocalPushDebugNotes':
          'لا تجمع قائمة تصحيح مستمرة على العميل في نسخة MVP.',
      'privacyDataAudioPlaybackState': 'حالة تشغيل الصوت',
      'privacyDataAudioPlaybackStateNotes':
          'لا يجمع سجل تشغيل مستمر في نسخة MVP.',
      'privacyDataRemoteContentApiConfig': 'حالة إعداد واجهة المحتوى',
      'privacyDataRemoteContentApiConfigNotes':
          'قد توجد إعدادات المزود والنقطة محليا؛ لا تعرض الرموز في مركز الخصوصية.',
      'privacyDataRemoteContentRequestMetadata': 'بيانات طلب المحتوى عن بعد',
      'remoteContentRequestMetadataNotes':
          'قد تتضمن الطلبات اللغة والسوق وإصدار التطبيق وإصدار المخطط فقط.',
      'privacyDataAnalyticsConsent': 'تفضيل الموافقة على التحليلات',
      'privacyDataAnalyticsConsentNotes':
          'يحفظ محليا. إيقافه يعطل جمع Firebase Analytics عندما تكون بناءات التحليلات مهيأة.',
      'privacyDataAnalyticsEvents': 'أحداث تحليلات متوقفة افتراضيا',
      'privacyDataAnalyticsEventsNotes':
          'ترسل فقط عندما تكون التحليلات مفعلة للبناء ويوافق المستخدم. الأحداث من قائمة مسموح بها وتستبعد الإحداثيات والملاحظات والنصوص الدينية والحالة الدقيقة لوضع عبادة النساء.',
      'privacyDataFutureAnalyticsCrash': 'تقارير الأعطال',
      'privacyDataFutureAnalyticsCrashNotes':
          'لم يتم تنفيذ SDK لتقارير الأعطال في نسخة MVP.',
      'privacyDataAccountData': 'بيانات الحساب',
      'privacyDataAccountDataNotes': 'تسجيل الدخول غير مطبق في نسخة MVP.',
      'privacyDataPaymentsSubscriptions': 'المدفوعات والاشتراكات',
      'privacyDataPaymentsSubscriptionsNotes':
          'المدفوعات والاشتراكات غير مطبقة في نسخة MVP.',
      'privacyDataAdsTracking': 'إعلانات أو تتبع',
      'privacyDataAdsTrackingNotes':
          'الإعلانات والتتبع ومطالبة ATT غير مطبقة في نسخة MVP.',
      'source': 'المصدر',
      'reviewed': 'مراجعة',
      'approvedContent': 'محتوى معتمد',
      'draftContent': 'محتوى مسودة',
      'inReviewContent': 'محتوى قيد المراجعة',
      'rejectedContent': 'محتوى مرفوض',
      'womenMode': 'وضع عبادة النساء',
      'womenModeDescription': 'اضبطي التذكيرات بخصوصية واحترام.',
      'womenModeWhatChangesTitle': 'ما يتغير محليا',
      'womenModeWhatChangesBody':
          'قد تصبح توصيات الرئيسية أهدأ وتبرز الدعاء والذكر والتأمل. قد تعرض الجلسات اليومية ملاحظة خاصة ومحلية فقط.',
      'womenModeWhatStaysPrivateTitle': 'ما لا يغادر هذا الجهاز',
      'womenModeWhatStaysPrivateBody':
          'يحفظ وضعك الدقيق محليا ولا يرسل مع طلبات المحتوى عن بعد.',
      'womenModeReminderPrivacyBody':
          'تبقى نصوص التذكير عامة حتى لا تكشف شاشة القفل تفاصيل خاصة.',
      'womenModeTurnOffBody':
          'أوقفي هذا الوضع باختيار عادي، أو امسحيه من مركز الخصوصية > حذف البيانات المحلية.',
      'openPrivacyCenter': 'فتح مركز الخصوصية',
      'todaysMode': 'وضع اليوم',
      'modeNormal': 'عادي',
      'modeMenstruating': 'الحيض',
      'modePostpartum': 'النفاس',
      'modePregnancy': 'الحمل',
      'modePreferNotToTrack': 'أفضل عدم التتبع',
      'dataStaysLocal': 'تبقى البيانات محلية افتراضيا',
      'recommendedNow': 'موصى به الآن',
      'gentleWorshipMoment': 'لحظة عبادة لطيفة',
      'womenRecommendedDescription':
          'تذكيرات دعاء · ذكر · تأمل بدون دعوات مباشرة للصلاة.',
      'reminderBehavior': 'سلوك التذكيرات',
      'reminderBehaviorDescription':
          'يمكن إيقاف تنبيهات الصلاة أو استبدالها بلحظات دعاء وذكر.',
      'duaUnavailable': 'الدعاء غير متاح.',
      'makeDua': 'الدعاء',
      'duaContext': 'للتركيز · قبل العمل أو الدراسة',
      'saved': 'محفوظ',
      'arabicLabel': 'العربية',
      'transliteration': 'النقل الصوتي',
      'meaning': 'المعنى',
      'listen': 'استمع',
      'repeatSlowly': 'كرر ببطء',
      'session': 'الجلسة',
      'sessionUnavailable': 'الجلسة غير متاحة.',
      'next': 'التالي',
      'finish': 'إنهاء',
      'playRecitation': 'تشغيل التلاوة',
      'pauseRecitation': 'إيقاف التلاوة مؤقتا',
      'textOnlyFallback': 'الرجوع إلى النص فقط',
      'audioUnavailable': 'الصوت غير متاح',
      'approvedReciter': 'قارئ معتمد',
      'approvedReciterLabel': 'قارئ معتمد',
      'quranSafetyTitle': 'سلامة القرآن',
      'quranSafetyDescription': 'لا يتم تشغيل صوت خلفي تحت تلاوة القرآن.',
      'reflectionSafetyTitle': 'ملاحظة التأمل',
      'reflectionSafetyDescription':
          'التأمل تذكير لطيف وليس فتوى أو حكما دينيا.',
      'completionFallback': 'توقف وتنفس واجعل هذا العمل لله وحده.',
      'backgroundSoundAllowed': 'الصوت الخلفي مسموح',
      'noBackgroundMusic': 'لا موسيقى خلفية تحت تلاوة القرآن',
      'timeIn': 'بعد',
      'hourShort': 'س',
      'minuteShort': 'د',
      'prayerFajr': 'الفجر',
      'prayerDhuhr': 'الظهر',
      'prayerAsr': 'العصر',
      'prayerMaghrib': 'المغرب',
      'prayerIsha': 'العشاء',
    },
  };

  String t(String key) {
    return _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;
  }

  String prayerName(String name) {
    return switch (name) {
      'Fajr' => t('prayerFajr'),
      'Dhuhr' => t('prayerDhuhr'),
      'Asr' => t('prayerAsr'),
      'Maghrib' => t('prayerMaghrib'),
      'Isha' => t('prayerIsha'),
      _ => name,
    };
  }

  String prayerCountdown(String name, int hours, int minutes) {
    return '${prayerName(name)} ${t('timeIn')} $hours${t('hourShort')} $minutes${t('minuteShort')}';
  }

  String prayerReminderLeadTimeLabel(int minutes) {
    if (minutes <= 0) {
      return switch (locale.languageCode) {
        'id' => 'Saat waktu shalat',
        'ar' => 'عند وقت الصلاة',
        _ => 'At prayer time',
      };
    }
    return switch (locale.languageCode) {
      'id' => '$minutes menit sebelumnya',
      'ar' => 'قبل $minutes دقائق',
      _ => '$minutes minutes before',
    };
  }

  String quranVerseLabel(String verseKey) {
    return '${t('quran')} $verseKey';
  }

  String qiblaBearingLabel(int degrees, String cardinalLabel) {
    return switch (locale.languageCode) {
      'id' => '${t('qiblaBearing')}: $degrees° $cardinalLabel',
      'ar' => '${t('qiblaBearing')}: $degrees° $cardinalLabel',
      _ => '${t('qiblaBearing')}: $degrees° $cardinalLabel',
    };
  }

  String recitedBy(String reciterName) {
    return switch (locale.languageCode) {
      'id' => 'Dilantunkan oleh $reciterName',
      'ar' => 'تلاوة $reciterName',
      _ => 'Recited by $reciterName',
    };
  }

  String stepProgress(int current, int total, String stepTitle) {
    return switch (locale.languageCode) {
      'id' => 'Langkah $current dari $total · $stepTitle',
      'ar' => 'الخطوة $current من $total · $stepTitle',
      _ => 'Step $current of $total · $stepTitle',
    };
  }

  String reviewContentLabel(String reviewStatus) {
    return switch (reviewStatus) {
      'approved' => t('approvedContent'),
      'draft' => t('draftContent'),
      'inReview' => t('inReviewContent'),
      'rejected' => t('rejectedContent'),
      _ => reviewStatus,
    };
  }
}

class _SakinahLocalizationsDelegate
    extends LocalizationsDelegate<SakinahLocalizations> {
  const _SakinahLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return SakinahLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<SakinahLocalizations> load(Locale locale) async {
    return SakinahLocalizations(locale);
  }

  @override
  bool shouldReload(_SakinahLocalizationsDelegate old) => false;
}
