// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sakinah Daily';

  @override
  String get splashTagline => 'Calm for the heart,\nremembrance for the day';

  @override
  String get splashFeatureLine => 'QURAN   ·   DUA   ·   DHIKR   ·   PRAYER';

  @override
  String get onboardingTitle => 'Begin with calm worship';

  @override
  String get onboardingSubtitle =>
      'Choose your language and preferences for a quiet daily companion.';

  @override
  String get language => 'Language';

  @override
  String get genderMode => 'Personalization';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderPreferNotToSay => 'Prefer not to say';

  @override
  String get audioPreference => 'Audio preference';

  @override
  String get audioRecitationOnly => 'Recitation only';

  @override
  String get audioQuietGuidance => 'Quiet guidance';

  @override
  String get audioTextFirst => 'Text first';

  @override
  String get prayerReminderConsent =>
      'Prayer reminders ask permission only after this explanation.';

  @override
  String get onboardingPrayerLocationBody =>
      'Prayer times and Qibla use this local prayer location.';

  @override
  String get onboardingPrayerNoGps => 'No GPS permission is requested in v0.1.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get homeGreeting => 'Assalamu alaikum';

  @override
  String get homeFriend => 'Friend';

  @override
  String get homeFemaleName => 'Aisha';

  @override
  String get homeDateLabel => 'Tuesday · 12 Ramadan';

  @override
  String get nextPrayer => 'Next prayer';

  @override
  String get dailyPrayerHomeTitle => 'Daily prayer at the center';

  @override
  String get viewPrayerTimes => 'View prayer times';

  @override
  String get manageReminders => 'Manage reminders';

  @override
  String get changeLocation => 'Change location';

  @override
  String get todaySession => 'Today\'s Sakinah Session';

  @override
  String get sessionSubtitleMeta => '7 min · Ayah · Reflection · Dua · Dhikr';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get startSession => 'Start session';

  @override
  String get start => 'Start';

  @override
  String get voiceOnly => 'Voice only';

  @override
  String get home => 'Home';

  @override
  String get quran => 'Quran';

  @override
  String get quranPageTitle => 'Quran';

  @override
  String get featuredAyah => 'Featured ayah';

  @override
  String get openAyah => 'Open ayah';

  @override
  String get quranAvailableVerses => 'Available verses';

  @override
  String get quranLocalOnlyBrowserBody =>
      'Browse reviewed local seed ayahs only. More Quran content requires approved sources.';

  @override
  String get quranVerseSearchHint => 'Search by verse reference or meaning';

  @override
  String get quranVerseNoResults =>
      'No reviewed local verse matches this search.';

  @override
  String get quranVerseUnavailable => 'Quran verse unavailable';

  @override
  String get quranPreviousVerse => 'Previous verse';

  @override
  String get quranNextVerse => 'Next verse';

  @override
  String get saveAyah => 'Save ayah';

  @override
  String get savedAyah => 'Saved ayah';

  @override
  String get quranVoiceOnlyTitle => 'Quran recitation is voice-only';

  @override
  String get quranVoiceOnlyBody =>
      'Quran recitation uses approved voice assets only and does not rely on synthetic Quran audio.';

  @override
  String get noQuranTts => 'No Quran TTS';

  @override
  String get noQuranBgm => 'No background music under Quran recitation';

  @override
  String get qibla => 'Qibla';

  @override
  String get qiblaTitle => 'Qibla direction';

  @override
  String get qiblaBearing => 'Qibla bearing';

  @override
  String get qiblaBasedOnSelectedLocation =>
      'Qibla uses your selected prayer location.';

  @override
  String get qiblaChangeLocation => 'Change prayer location';

  @override
  String get qiblaNoGpsRequired =>
      'Qibla uses your selected prayer location. Exact GPS is not required.';

  @override
  String get tonight => 'Tonight';

  @override
  String get sleepAyatKursi => 'Sleep with Ayat al-Kursi';

  @override
  String get sleepSessionDescription =>
      'A quiet 5-minute session with pure Qur\'an recitation and soft guidance.';

  @override
  String get saveTonight => 'Save tonight';

  @override
  String get savedTonight => 'Saved tonight';

  @override
  String get sessionCompletedTitle => 'Session complete';

  @override
  String get sessionCompletedBody =>
      'You completed this Sakinah session. Take a quiet moment before returning.';

  @override
  String get completedToday => 'Completed today';

  @override
  String get resumeSession => 'Resume';

  @override
  String get reviewSession => 'Review';

  @override
  String get localProgress => 'Local progress';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get completedThisWeek => 'Completed this week';

  @override
  String get progressLocalOnly => 'Progress stays on this device only.';

  @override
  String get prayersToday => 'Prayers today';

  @override
  String get prayerCheckInsLocalOnly =>
      'Prayer check-ins stay on this device only.';

  @override
  String get continuePrayerCheckIn => 'Continue prayer check-in';

  @override
  String get reviewPrayerCheckIn => 'Review prayer check-in';

  @override
  String get prayerWeekProgress => 'Prayer week';

  @override
  String get prayerWeekCheckInDays => 'Check-in days';

  @override
  String get prayerWeekStreak => 'Prayer streak';

  @override
  String get saveSession => 'Save session';

  @override
  String get sessionSaved => 'Session saved';

  @override
  String get openSavedItems => 'Open Saved Items';

  @override
  String get setDailyReminder => 'Set daily reminder';

  @override
  String get dailyReminderSet => 'Daily reminder set';

  @override
  String get manageDailyReminder => 'Manage daily reminder';

  @override
  String get sessionReminderPermissionTitle => 'Set daily reminder?';

  @override
  String get sessionReminderPermissionBody =>
      'Sakinah can schedule a local daily session reminder. The reminder text stays privacy-safe on the lock screen.';

  @override
  String get sessionReminderPermissionAllow => 'Set reminder';

  @override
  String get sessionReminderPermissionNotNow => 'Not now';

  @override
  String get backHome => 'Back Home';

  @override
  String get sessionProgressHistory => 'Session progress history';

  @override
  String get sessionProgressHistoryNotes =>
      'Session progress and completion history are stored locally only.';

  @override
  String get noGuaranteedOutcome =>
      'No guaranteed spiritual outcome is claimed.';

  @override
  String get dua => 'Dua';

  @override
  String get dhikr => 'Dhikr';

  @override
  String get allCategories => 'All';

  @override
  String get searchDuaHint => 'Search duas';

  @override
  String get searchDhikrHint => 'Search dhikr';

  @override
  String get noDuaResultsTitle => 'No duas found';

  @override
  String get noDuaResultsBody => 'Try another category or search term.';

  @override
  String get noDhikrResultsTitle => 'No dhikr found';

  @override
  String get noDhikrResultsBody => 'Try another category or search term.';

  @override
  String get categoryQuranic => 'Quranic';

  @override
  String get categoryMorning => 'Morning';

  @override
  String get categoryEvening => 'Evening';

  @override
  String get categoryReflection => 'Reflection';

  @override
  String get categoryDifficulty => 'Difficulty';

  @override
  String get categoryGratitude => 'Gratitude';

  @override
  String get categoryForgiveness => 'Forgiveness';

  @override
  String get categoryGeneral => 'General';

  @override
  String get settings => 'Settings';

  @override
  String get prayer => 'Prayer';

  @override
  String get prayerLocation => 'Prayer location';

  @override
  String get manualPrayerLocationTitle => 'Manual prayer location';

  @override
  String get manualPrayerLocationBody =>
      'Enter a prayer location manually. It is stored locally and used for prayer times and Qibla.';

  @override
  String get locationLabel => 'Location label';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get timezoneId => 'Timezone ID';

  @override
  String get saveLocation => 'Save location';

  @override
  String get invalidLatitude => 'Latitude must be between -90 and 90.';

  @override
  String get invalidLongitude => 'Longitude must be between -180 and 180.';

  @override
  String get locationSaved => 'Location saved';

  @override
  String get locationLocalOnlyNoGps =>
      'Stored locally. No GPS permission is required.';

  @override
  String get prayerMethod => 'Prayer method';

  @override
  String get prayerReminders => 'Prayer reminders';

  @override
  String get todaysPrayerTimes => 'Today\'s prayer times';

  @override
  String get currentPrayerStatus => 'Current';

  @override
  String get nextPrayerStatus => 'Next';

  @override
  String get todaysPrayerCheckIn => 'Today\'s prayer check-in';

  @override
  String get prayerCheckInBody =>
      'Mark prayers you have completed. Stored locally only.';

  @override
  String get todaysPrayerCheckInComplete => 'Today\'s prayers are checked in';

  @override
  String get prayerCheckInCompleteBody =>
      'Your five prayer check-ins are saved on this device only.';

  @override
  String get prayerCompletedStatus => 'Completed';

  @override
  String get prayerReminderSubtitle =>
      'Permission is requested after explanation.';

  @override
  String get prayerReminderChoicesTitle => 'Prayer reminder choices';

  @override
  String get prayerReminderChoicesBody =>
      'Choose which prayer times can send local reminders.';

  @override
  String get prayerReminderChoiceSubtitle => 'Selected for reminder schedule';

  @override
  String get prayerReminderLeadTimeTitle => 'Reminder timing';

  @override
  String get prayerReminderLeadTimeBody =>
      'Send each selected prayer reminder at the prayer time or a few minutes before.';

  @override
  String get nextPrayerReminderPreview => 'Next prayer reminder';

  @override
  String get notificationPermissionTitle => 'Enable prayer reminders?';

  @override
  String get notificationPermissionBody =>
      'Sakinah schedules local prayer reminders only after permission. Women\'s mode reminders stay privacy-safe on the lock screen.';

  @override
  String get notificationPermissionAllow => 'Enable reminders';

  @override
  String get notificationPermissionNotNow => 'Not now';

  @override
  String get notificationPermissionDenied =>
      'Notifications are off. You can enable them from system settings.';

  @override
  String get notificationPermissionRecoveryBody =>
      'After enabling notifications in system settings, return here and try reminders again.';

  @override
  String get notificationPermissionRecoveryButton =>
      'Open notification settings';

  @override
  String get notificationPermissionRecoveryOpened =>
      'System notification settings opened.';

  @override
  String get notificationPermissionRecoveryUnavailable =>
      'System notification settings could not be opened from Sakinah.';

  @override
  String get notificationScheduled => 'Local prayer reminders are scheduled.';

  @override
  String get notificationSettingsTitle => 'Notification settings';

  @override
  String get notificationSettingsSubtitle =>
      'Manage prayer and daily session reminders.';

  @override
  String get closedTestingHomeBody =>
      'Use the Day 1 / Day 3 / Day 7 / Day 14 prompts to send feedback without personal details.';

  @override
  String get closedTestingNextFeedback => 'Next feedback';

  @override
  String get closedTestingAllFeedbackSent => 'All feedback marked sent';

  @override
  String get closedTestingHomeButton => 'Open guide';

  @override
  String get closedTestingPromptTitle => 'Feedback prompts';

  @override
  String get closedTestingPromptBody =>
      'Use these checkpoints to send feedback that helps the 14-day closed test improve daily return.';

  @override
  String get closedTestingPromptDay1Label => 'Day 1';

  @override
  String get closedTestingPromptDay1 =>
      'Did onboarding explain location and notification choices clearly?';

  @override
  String get closedTestingPromptDay3Label => 'Day 3';

  @override
  String get closedTestingPromptDay3 =>
      'Were prayer times, location, and reminder controls easy to trust?';

  @override
  String get closedTestingPromptDay7Label => 'Day 7';

  @override
  String get closedTestingPromptDay7 =>
      'What made you want to reopen or ignore the app this week?';

  @override
  String get closedTestingPromptDay14Label => 'Day 14';

  @override
  String get closedTestingPromptDay14 =>
      'What one change would most improve daily use before wider release?';

  @override
  String get copyTestingFeedbackPrompt => 'Copy prompt';

  @override
  String get closedTestingPromptCopied => 'Feedback prompt copied.';

  @override
  String get closedTestingPromptCopyHeader =>
      'Sakinah Daily closed test feedback';

  @override
  String get closedTestingPromptCopyPromptLabel => 'Prompt';

  @override
  String get closedTestingPromptCopyThemeLabel => 'Suggested theme';

  @override
  String get closedTestingPromptCopyChannelLabel => 'Feedback channel';

  @override
  String get closedTestingPromptCopyPrivacyLine =>
      'Please avoid personal or sensitive health details.';

  @override
  String get closedTestingPromptFeedbackSent => 'Feedback sent';

  @override
  String get closedTestingPromptLocalOnlyStatus =>
      'Stored only on this device.';

  @override
  String get dailySessionReminderTitle => 'Daily session reminder';

  @override
  String get dailySessionReminderPrivacyNote =>
      'Session reminders are scheduled locally and keep lock-screen text privacy-safe.';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get reminderTimeSaved => 'Reminder time saved';

  @override
  String get saveReminderTime => 'Save time';

  @override
  String get reminderStatusOn => 'On';

  @override
  String get reminderStatusOff => 'Off';

  @override
  String get notificationTapMalformed =>
      'This notification could not be opened safely.';

  @override
  String get notificationTapFallbackPrayer => 'Opening prayer times.';

  @override
  String get notificationTapMissingContent =>
      'This notification content is not available offline yet.';

  @override
  String get womenModeSubtitle =>
      'Local-only by default. Sensitive reminder copy stays private.';

  @override
  String get localOnlyMode => 'Local-only mode';

  @override
  String get womenModePrivatePath => 'Private gentle path';

  @override
  String get womenModeHomeSupportBody =>
      'Dua, dhikr, and reflection stay easy to reach. Your mode stays on this device.';

  @override
  String get womenModeSessionNoteTitle => 'Local-only mode';

  @override
  String get womenModeSessionNoteBody =>
      'Your mode stays on this device. This session keeps a gentle worship-friendly path.';

  @override
  String get continueFromSaved => 'Continue from saved';

  @override
  String get savedRailLocalNote => 'Saved locally on this device.';

  @override
  String get savedItems => 'Saved Items';

  @override
  String get savedItemsEmptyTitle => 'Nothing saved yet';

  @override
  String get savedItemsEmptyBody =>
      'Saved items stay on this device for quick return later.';

  @override
  String get save => 'Save';

  @override
  String get unsave => 'Unsave';

  @override
  String get removeSavedItem => 'Remove saved item';

  @override
  String get savedLocalOnly => 'Saved items stay on this device only.';

  @override
  String get savedItemsPrivacyNotes =>
      'Saved locally. No account or sync in MVP.';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacySubtitle =>
      'Women\'s mode data is not sent remotely in MVP.';

  @override
  String get privacyCenterTitle => 'Privacy Center';

  @override
  String get dataInventoryTitle => 'Data inventory';

  @override
  String get dataInventoryBody =>
      'This inventory describes MVP client data and where it is stored.';

  @override
  String get dataOnDeviceTitle => 'Data we keep on this device';

  @override
  String get dataCanLeaveDeviceTitle => 'Data that can leave this device';

  @override
  String get localOnlyData =>
      'Most preferences, prayer settings, women’s mode, and content cache stay on this device.';

  @override
  String get leavesDeviceData =>
      'Remote content requests may include language, market, app version, and schema version.';

  @override
  String get womenModePrivacyTitle => 'Women\'s Ibadah Mode privacy';

  @override
  String get womenModePrivacyBody =>
      'Women’s Ibadah Mode is designed local-first. Exact status is not sent with remote content requests.';

  @override
  String get prayerLocationPrivacyTitle => 'Prayer location privacy';

  @override
  String get prayerLocationPrivacyBody =>
      'Prayer location uses manual or preset choices by default for prayer time calculation.';

  @override
  String get notificationPrivacyTitle => 'Notifications privacy';

  @override
  String get notificationPrivacyBody =>
      'Prayer reminders are scheduled locally where possible, and sensitive women’s mode copy stays off the lock screen.';

  @override
  String get remoteContentPrivacyTitle => 'Remote content cache';

  @override
  String get remoteContentPrivacyBody =>
      'Approved content bundles can be cached on this device. Remote content requests may include language, market, app version, and schema version.';

  @override
  String get analyticsPrivacyTitle => 'Usage analytics privacy';

  @override
  String get analyticsPrivacyBody =>
      'Usage analytics is default-off. If enabled in a reviewed build, Sakinah sends only whitelisted app-flow events and never sends exact coordinates, Women’s Ibadah Mode exact status, feedback text, or religious text.';

  @override
  String get analyticsOptInTitle => 'Share usage analytics';

  @override
  String get analyticsOptInAvailableBody =>
      'Optional. Helps improve prayer reminders and session retention with privacy-safe event names only.';

  @override
  String get analyticsOptInUnavailableBody =>
      'Analytics collection is off in this build.';

  @override
  String get deleteLocalDataTitle => 'Delete local data';

  @override
  String get deleteLocalDataBody =>
      'Reset app preferences, saved items, session progress, women’s mode state, local content cache, and scheduled reminders on this device.';

  @override
  String get deleteLocalDataKeepsSeed =>
      'Bundled seed content and app files are kept. This does not contact a remote service.';

  @override
  String get deleteLocalDataConfirm => 'Delete local data';

  @override
  String get deleteLocalDataDeleting => 'Deleting...';

  @override
  String get deleteLocalDataDialogTitle => 'Confirm local reset';

  @override
  String get deleteLocalDataDialogBody =>
      'This clears local preferences, saved items, session progress, cached bundles, and scheduled reminders on this device.';

  @override
  String get deleteLocalDataCancel => 'Cancel';

  @override
  String get deleteLocalDataSuccess =>
      'Local data has been reset on this device.';

  @override
  String get storePrivacyDraftTitle => 'Store data safety summary';

  @override
  String get storePrivacyDraftBody =>
      'Draft store declarations are documented for review before submission.';

  @override
  String get privacyPolicyDraftTitle => 'Privacy policy draft';

  @override
  String get privacyPolicyDraftBody =>
      'A draft privacy policy exists for legal and store review.';

  @override
  String get contentSourcesTitle => 'Content Sources';

  @override
  String get contentSourcesSubtitle =>
      'Source labels, review status, and AI limits.';

  @override
  String get contentSourcesIntro =>
      'Sakinah shows worship content with source and review guardrails so users can understand what they are reading or hearing.';

  @override
  String get contentSourcesSeedTitle => 'Reviewed seed and approved bundles';

  @override
  String get contentSourcesSeedBody =>
      'Quran, Dua, Dhikr, and session content shown in the app must come from reviewed seed content or approved CMS bundles.';

  @override
  String get contentSourcesApprovalTitle => 'Published + approved only';

  @override
  String get contentSourcesApprovalBody =>
      'Remote CMS content is hidden unless it is both published and approved. Draft, in-review, rejected, or revoked content is filtered out.';

  @override
  String get contentSourcesGeneratedTitle => 'Not generated';

  @override
  String get contentSourcesGeneratedBody =>
      'The client does not generate Quran text, translations, Dua, Dhikr, reflection, or religious answers.';

  @override
  String get contentSourcesAudioTitle => 'Quran audio safety';

  @override
  String get contentSourcesAudioBody =>
      'Quran recitation uses approved voice assets only. There is no generic Quran TTS and no background music under Quran recitation.';

  @override
  String get contentSourcesFatwaTitle => 'No AI fatwa or religious Q&A';

  @override
  String get contentSourcesFatwaBody =>
      'When a topic has school or regional differences, Sakinah uses neutral wording and source labels rather than fatwa-style claims.';

  @override
  String get storageLocalDevice => 'Local device';

  @override
  String get storageRemoteOptional => 'Remote request';

  @override
  String get storageNotCollected => 'Not collected';

  @override
  String get sensitivityLow => 'Low sensitivity';

  @override
  String get sensitivityMedium => 'Medium sensitivity';

  @override
  String get sensitivityHigh => 'High sensitivity';

  @override
  String get localOnlyShort => 'Local only';

  @override
  String get leavesDeviceShort => 'Leaves device';

  @override
  String get userCanDeleteShort => 'User can delete';

  @override
  String get privacyDataLanguagePreference => 'Language preference';

  @override
  String get privacyDataLanguagePreferenceNotes =>
      'Stored locally and used to choose app language and content language.';

  @override
  String get privacyDataGenderModePreference => 'Gender mode preference';

  @override
  String get privacyDataGenderModePreferenceNotes =>
      'Stored locally for client personalization in MVP.';

  @override
  String get privacyDataAudioPreference => 'Audio preference';

  @override
  String get privacyDataAudioPreferenceNotes =>
      'Stored locally to choose recitation-only, guidance, or text-first behavior.';

  @override
  String get privacyDataPrayerSettings => 'Prayer settings';

  @override
  String get privacyDataPrayerSettingsNotes =>
      'Stored locally for prayer time method and calculation settings.';

  @override
  String get privacyDataPrayerLocationPreset => 'Prayer location preset';

  @override
  String get privacyDataPrayerLocationPresetNotes =>
      'Stored locally by default as a manual or preset location choice.';

  @override
  String get privacyDataNotificationEnabledState =>
      'Notification enabled state';

  @override
  String get privacyDataNotificationEnabledStateNotes =>
      'Stored locally to remember prayer reminder status, per-prayer choices, prayer reminder lead-time offset, daily session reminder status, and the selected daily session reminder time.';

  @override
  String get privacyDataClosedTestingFeedbackStatus =>
      'Closed testing feedback status';

  @override
  String get privacyDataClosedTestingFeedbackStatusNotes =>
      'Stores only whether Day 1, Day 3, Day 7, or Day 14 feedback was marked sent. Feedback text and personal details are not stored.';

  @override
  String get privacyDataWomenModeState => 'Women\'s Ibadah Mode state';

  @override
  String get privacyDataWomenModeStateNotes =>
      'High sensitivity. Designed local-first, may adjust local UI recommendations, and is not sent to remote content APIs.';

  @override
  String get privacyDataLocalContentManifest => 'Local content manifest';

  @override
  String get privacyDataLocalContentManifestNotes =>
      'Stored locally to know which approved bundles are active.';

  @override
  String get privacyDataLocalContentBundles => 'Local content bundles';

  @override
  String get privacyDataLocalContentBundlesNotes =>
      'Stored locally after hash, schema, published, and approved checks.';

  @override
  String get privacyDataLocalRevokedContentIds => 'Local revoked content IDs';

  @override
  String get privacyDataLocalRevokedContentIdsNotes =>
      'Stored locally so revoked content is hidden from the client.';

  @override
  String get privacyDataSavedItems => 'Saved items';

  @override
  String get privacyDataSavedItemsNotes =>
      'Saved sessions, duas, dhikr, and verse references are stored locally only.';

  @override
  String get privacyDataSessionProgressHistory => 'Session progress history';

  @override
  String get privacyDataSessionProgressHistoryNotes =>
      'Session progress and completion records store session IDs and timestamps locally only.';

  @override
  String get privacyDataPrayerCompletionHistory => 'Prayer completion history';

  @override
  String get privacyDataPrayerCompletionHistoryNotes =>
      'Prayer check-ins store prayer names and local completion timestamps on this device only.';

  @override
  String get privacyDataLocalPushDebug => 'Local push payload debug data';

  @override
  String get privacyDataLocalPushDebugNotes =>
      'No persistent client-side debug queue is collected in MVP.';

  @override
  String get privacyDataAudioPlaybackState => 'Audio playback state';

  @override
  String get privacyDataAudioPlaybackStateNotes =>
      'No persistent playback history is collected in MVP.';

  @override
  String get privacyDataRemoteContentApiConfig =>
      'Remote content API config state';

  @override
  String get privacyDataRemoteContentApiConfigNotes =>
      'Provider and endpoint configuration may exist locally; tokens are never displayed in Privacy Center.';

  @override
  String get privacyDataRemoteContentRequestMetadata =>
      'Remote content request metadata';

  @override
  String get remoteContentRequestMetadataNotes =>
      'Requests may include language, market, app version, and schema version only.';

  @override
  String get privacyDataAnalyticsConsent => 'Analytics consent preference';

  @override
  String get privacyDataAnalyticsConsentNotes =>
      'Stored locally. Turning it off disables Firebase Analytics collection when analytics builds are configured.';

  @override
  String get privacyDataAnalyticsEvents => 'Default-off analytics events';

  @override
  String get privacyDataAnalyticsEventsNotes =>
      'Only sent when analytics is enabled for the build and the user opts in. Events are whitelisted and exclude coordinates, feedback, religious text, and Women’s Ibadah Mode exact status.';

  @override
  String get privacyDataFutureAnalyticsCrash => 'Crash reporting';

  @override
  String get privacyDataFutureAnalyticsCrashNotes =>
      'Crash-reporting SDK is not implemented in MVP.';

  @override
  String get privacyDataAccountData => 'Account data';

  @override
  String get privacyDataAccountDataNotes =>
      'Account login is not implemented in MVP.';

  @override
  String get privacyDataPaymentsSubscriptions => 'Payments and subscriptions';

  @override
  String get privacyDataPaymentsSubscriptionsNotes =>
      'Payments and subscriptions are not implemented in MVP.';

  @override
  String get source => 'Source';

  @override
  String get reviewed => 'Reviewed';

  @override
  String get approvedContent => 'approved content';

  @override
  String get draftContent => 'draft content';

  @override
  String get inReviewContent => 'in review content';

  @override
  String get rejectedContent => 'rejected content';

  @override
  String get womenMode => 'Women\'s Ibadah Mode';

  @override
  String get womenModeDescription =>
      'Adjust reminders with privacy and respect.';

  @override
  String get womenModeWhatChangesTitle => 'What changes locally';

  @override
  String get womenModeWhatChangesBody =>
      'Home recommendations may become quieter and highlight dua, dhikr, and reflection. Daily sessions may show a private local-only note.';

  @override
  String get womenModeWhatStaysPrivateTitle =>
      'What does not leave this device';

  @override
  String get womenModeWhatStaysPrivateBody =>
      'Your exact mode is stored locally and is not sent with remote content requests.';

  @override
  String get womenModeReminderPrivacyBody =>
      'Reminder text stays generic so lock-screen copy does not reveal private details.';

  @override
  String get womenModeTurnOffBody =>
      'Turn this mode off by choosing Normal, or clear it from Privacy Center > Delete local data.';

  @override
  String get openPrivacyCenter => 'Open Privacy Center';

  @override
  String get todaysMode => 'Today\'s mode';

  @override
  String get modeNormal => 'Normal';

  @override
  String get modeMenstruating => 'Menstruating';

  @override
  String get modePostpartum => 'Postpartum';

  @override
  String get modePregnancy => 'Pregnancy';

  @override
  String get modePreferNotToTrack => 'Prefer not to track';

  @override
  String get dataStaysLocal => 'Data stays local by default';

  @override
  String get womenModeDiscreetToggleTitle => 'Discreet privacy mode';

  @override
  String get womenModeDiscreetToggleBody =>
      'Hide women’s mode support copy on Home and Daily Session. Your status still stays on this device.';

  @override
  String get recommendedNow => 'Recommended now';

  @override
  String get gentleWorshipMoment => 'A gentle worship moment';

  @override
  String get womenRecommendedDescription =>
      'Dua · Dhikr · Reflection reminders without direct prayer prompts.';

  @override
  String get reminderBehavior => 'Reminder behavior';

  @override
  String get reminderBehaviorDescription =>
      'Prayer alerts can be paused or replaced with Dua and Dhikr moments.';

  @override
  String get duaUnavailable => 'Dua unavailable.';

  @override
  String get makeDua => 'Make Dua';

  @override
  String get duaContext => 'For focus · Before work or study';

  @override
  String get saved => 'Saved';

  @override
  String get arabicLabel => 'Arabic';

  @override
  String get transliteration => 'Transliteration';

  @override
  String get meaning => 'Meaning';

  @override
  String get listen => 'Listen';

  @override
  String get repeatSlowly => 'Repeat slowly';

  @override
  String get session => 'Session';

  @override
  String get sessionUnavailable => 'Session unavailable.';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get playRecitation => 'Play recitation';

  @override
  String get pauseRecitation => 'Pause recitation';

  @override
  String get textOnlyFallback => 'Text-only fallback';

  @override
  String get audioUnavailable => 'Audio unavailable';

  @override
  String get approvedReciter => 'approved reciter';

  @override
  String get approvedReciterLabel => 'Approved reciter';

  @override
  String get quranSafetyTitle => 'Qur\'an Safety';

  @override
  String get quranSafetyDescription =>
      'No background sound is played under Qur\'an recitation.';

  @override
  String get reflectionSafetyTitle => 'Reflection note';

  @override
  String get reflectionSafetyDescription =>
      'Reflection is a gentle reminder, not a fatwa or religious ruling.';

  @override
  String get completionFallback =>
      'Pause, breathe, and keep this act for Allah alone.';

  @override
  String get backgroundSoundAllowed => 'Background sound allowed';

  @override
  String get noBackgroundMusic => 'No background music under Quran recitation';

  @override
  String get timeIn => 'in';

  @override
  String get hourShort => 'h';

  @override
  String get minuteShort => 'm';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';
}
