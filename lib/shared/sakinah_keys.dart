import 'package:flutter/foundation.dart';

abstract final class SakinahKeys {
  static const splashPage = ValueKey<String>('splash_page');
  static const splashBrand = ValueKey<String>('splash_brand');
  static const splashTagline = ValueKey<String>('splash_tagline');

  static const onboardingContinueButton =
      ValueKey<String>('onboarding_continue_button');
  static const onboardingPrayerLocationDropdown =
      ValueKey<String>('onboarding_prayer_location_dropdown');

  static const homePrayerBadge = ValueKey<String>('home_prayer_badge');
  static const homePrayerPrimaryCard =
      ValueKey<String>('home_prayer_primary_card');
  static const homePrayerTimesButton =
      ValueKey<String>('home_prayer_times_button');
  static const homePrayerReminderSettingsButton =
      ValueKey<String>('home_prayer_reminder_settings_button');
  static const homePrayerNextReminderPreview =
      ValueKey<String>('home_prayer_next_reminder_preview');
  static const homeContentList = ValueKey<String>('home_content_list');
  static const homeSessionCard = ValueKey<String>('home_session_card');
  static const homeSessionReminderStatusChip =
      ValueKey<String>('home_session_reminder_status_chip');
  static const homeQuickActionsCard =
      ValueKey<String>('home_quick_actions_card');
  static const homeNightCard = ValueKey<String>('home_night_card');
  static const homeSavedRail = ValueKey<String>('home_saved_rail');
  static const homeSavedItemsButton =
      ValueKey<String>('home_saved_items_button');
  static const homeClosedTestingGuideCard =
      ValueKey<String>('home_closed_testing_guide_card');
  static const homeClosedTestingGuideButton =
      ValueKey<String>('home_closed_testing_guide_button');
  static const homeSessionStartButton =
      ValueKey<String>('home_session_start_button');
  static const homeSessionReminderCtaButton =
      ValueKey<String>('home_session_reminder_cta_button');
  static const homeVoiceOnlyButton = ValueKey<String>('home_voice_only_button');
  static const homeSaveTonightButton =
      ValueKey<String>('home_save_tonight_button');
  static const homeQuickActionQuran =
      ValueKey<String>('home_quick_action_quran');
  static const homeQuickActionDua = ValueKey<String>('home_quick_action_dua');
  static const homeQuickActionDhikr =
      ValueKey<String>('home_quick_action_dhikr');
  static const homeQuickActionQibla =
      ValueKey<String>('home_quick_action_qibla');
  static const homeWomenModeSupportCard =
      ValueKey<String>('home_women_mode_support_card');
  static const homeWomenModeLocalChip =
      ValueKey<String>('home_women_mode_local_chip');

  static ValueKey<String> homeSavedItemTile(String savedItemId) {
    return ValueKey<String>('home_saved_item_$savedItemId');
  }

  static const bottomNavHome = ValueKey<String>('bottom_nav_home');
  static const bottomNavPrayer = ValueKey<String>('bottom_nav_prayer');
  static const bottomNavSession = ValueKey<String>('bottom_nav_session');
  static const bottomNavDua = ValueKey<String>('bottom_nav_dua');
  static const bottomNavDhikr = ValueKey<String>('bottom_nav_dhikr');
  static const bottomNavSettings = ValueKey<String>('bottom_nav_settings');

  static const dhikrCounter = ValueKey<String>('dhikr_counter');
  static const sessionDhikrCounter = ValueKey<String>('session_dhikr_counter');
  static const sessionNextButton = ValueKey<String>('session_next_button');
  static const sessionFinishButton = ValueKey<String>('session_finish_button');
  static const sessionProgressBar = ValueKey<String>('session_progress_bar');
  static const sessionResumeBadge = ValueKey<String>('session_resume_badge');
  static const sessionWomenModeNote =
      ValueKey<String>('session_women_mode_note');
  static const sessionCompletionPage =
      ValueKey<String>('session_completion_page');
  static const sessionCompletionSaveButton =
      ValueKey<String>('session_completion_save_button');
  static const sessionCompletionReminderButton =
      ValueKey<String>('session_completion_reminder_button');
  static const sessionCompletionBackHomeButton =
      ValueKey<String>('session_completion_back_home_button');
  static const sessionCompletionSavedItemsButton =
      ValueKey<String>('session_completion_saved_items_button');
  static const homeProgressCard = ValueKey<String>('home_progress_card');
  static const homePrayerCompletionMetric =
      ValueKey<String>('home_prayer_completion_metric');
  static const homePrayerWeekProgress =
      ValueKey<String>('home_prayer_week_progress');
  static const homePrayerWeekDaysMetric =
      ValueKey<String>('home_prayer_week_days_metric');
  static const homePrayerWeekStreakMetric =
      ValueKey<String>('home_prayer_week_streak_metric');
  static const sessionAudioPlayerBar =
      ValueKey<String>('session_audio_player_bar');
  static const sessionSafetyCard = ValueKey<String>('session_safety_card');
  static const sessionReflectionSafetyCard =
      ValueKey<String>('session_reflection_safety_card');
  static const audioPlayPauseButton =
      ValueKey<String>('audio_play_pause_button');
  static const quranSafetyCard = sessionSafetyCard;
  static const duaSourceCard = ValueKey<String>('dua_source_card');

  static const settingsWomenModeTile =
      ValueKey<String>('settings_women_mode_tile');
  static const settingsPrivacyTile = ValueKey<String>('settings_privacy_tile');
  static const settingsContentSourcesTile =
      ValueKey<String>('settings_content_sources_tile');
  static const settingsTestingFeedbackTile =
      ValueKey<String>('settings_testing_feedback_tile');
  static const settingsClosedTestingGuideTile =
      ValueKey<String>('settings_closed_testing_guide_tile');
  static const settingsSavedItemsTile =
      ValueKey<String>('settings_saved_items_tile');
  static const settingsNotificationSettingsTile =
      ValueKey<String>('settings_notification_settings_tile');
  static const notificationSettingsPage =
      ValueKey<String>('notification_settings_page');
  static const settingsDailySessionReminderSwitch =
      ValueKey<String>('settings_daily_session_reminder_switch');
  static const settingsDailySessionReminderTimeButton =
      ValueKey<String>('settings_daily_session_reminder_time_button');
  static const settingsDailySessionReminderHourDropdown =
      ValueKey<String>('settings_daily_session_reminder_hour_dropdown');
  static const settingsDailySessionReminderMinuteDropdown =
      ValueKey<String>('settings_daily_session_reminder_minute_dropdown');
  static const settingsDailySessionReminderTimeSaveButton =
      ValueKey<String>('settings_daily_session_reminder_time_save_button');
  static const notificationSmokeTestButton =
      ValueKey<String>('notification_smoke_test_button');
  static const prayerReminderSmokeTestButton =
      ValueKey<String>('prayer_reminder_smoke_test_button');
  static const settingsPrayerLocationDropdown =
      ValueKey<String>('settings_prayer_location_dropdown');
  static const settingsPrayerMethodDropdown =
      ValueKey<String>('settings_prayer_method_dropdown');
  static const settingsNotificationSwitch =
      ValueKey<String>('settings_notification_switch');
  static const settingsPrayerNextReminderPreview =
      ValueKey<String>('settings_prayer_next_reminder_preview');
  static const settingsPrayerReminderLeadTimeDropdown =
      ValueKey<String>('settings_prayer_reminder_lead_time_dropdown');
  static ValueKey<String> settingsPrayerReminderPrayerSwitch(
    String prayerName,
  ) {
    return ValueKey<String>('settings_prayer_reminder_$prayerName');
  }

  static const prayerContentList = ValueKey<String>('prayer_content_list');
  static const prayerTopReminderSettingsButton =
      ValueKey<String>('prayer_top_reminder_settings_button');
  static const prayerTimesSectionHeader =
      ValueKey<String>('prayer_times_section_header');
  static const prayerCompletionSummaryCard =
      ValueKey<String>('prayer_completion_summary_card');
  static const prayerCompletionStartSessionButton =
      ValueKey<String>('prayer_completion_start_session_button');
  static const prayerCompletionReminderSettingsButton =
      ValueKey<String>('prayer_completion_reminder_settings_button');
  static ValueKey<String> prayerListItem(String prayerName) {
    return ValueKey<String>('prayer_list_item_$prayerName');
  }

  static ValueKey<String> prayerCompletionCheckbox(String prayerName) {
    return ValueKey<String>('prayer_completion_checkbox_$prayerName');
  }

  static ValueKey<String> prayerStatusChip(String prayerName) {
    return ValueKey<String>('prayer_status_chip_$prayerName');
  }

  static const quranPage = ValueKey<String>('quran_page');
  static const quranOpenFeaturedButton =
      ValueKey<String>('quran_open_featured_button');
  static const quranVerseSearchField =
      ValueKey<String>('quran_verse_search_field');
  static const quranVerseEmptyState =
      ValueKey<String>('quran_verse_empty_state');
  static const quranVerseDetailPage =
      ValueKey<String>('quran_verse_detail_page');
  static const quranVerseSafetyCard =
      ValueKey<String>('quran_verse_safety_card');
  static const quranVerseSaveButton =
      ValueKey<String>('quran_verse_save_button');
  static const quranPreviousVerseButton =
      ValueKey<String>('quran_previous_verse_button');
  static const quranNextVerseButton =
      ValueKey<String>('quran_next_verse_button');
  static ValueKey<String> quranVerseCard(String verseKey) {
    return ValueKey<String>('quran_verse_card_$verseKey');
  }

  static const qiblaPage = ValueKey<String>('qibla_page');
  static const savedItemsPage = ValueKey<String>('saved_items_page');
  static const duaSearchField = ValueKey<String>('dua_search_field');
  static const duaEmptyState = ValueKey<String>('dua_empty_state');
  static const duaSaveButton = ValueKey<String>('dua_save_button');
  static const dhikrSearchField = ValueKey<String>('dhikr_search_field');
  static const dhikrEmptyState = ValueKey<String>('dhikr_empty_state');
  static const dhikrSaveButton = ValueKey<String>('dhikr_save_button');
  static const womenModeNormalChip = ValueKey<String>('women_mode_normal_chip');
  static const womenModeMenstruatingChip =
      ValueKey<String>('women_mode_menstruating_chip');
  static const womenModePostpartumChip =
      ValueKey<String>('women_mode_postpartum_chip');
  static const womenModePregnancyChip =
      ValueKey<String>('women_mode_pregnancy_chip');
  static const womenModePreferNotToTrackChip =
      ValueKey<String>('women_mode_prefer_not_to_track_chip');
  static const womenModeStartButton =
      ValueKey<String>('women_mode_start_button');
  static const womenModeLocalChangesCard =
      ValueKey<String>('women_mode_local_changes_card');
  static const womenModePrivacyDetailsCard =
      ValueKey<String>('women_mode_privacy_details_card');
  static const womenModeRecommendedCard =
      ValueKey<String>('women_mode_recommended_card');
  static const privacyCenterPage = ValueKey<String>('privacy_center_page');
  static const privacyPolicyLinkTile =
      ValueKey<String>('privacy_policy_link_tile');
  static const privacyAnalyticsSwitch =
      ValueKey<String>('privacy_analytics_switch');
  static const contentSourcesPage = ValueKey<String>('content_sources_page');
  static const closedTestingGuidePage =
      ValueKey<String>('closed_testing_guide_page');
  static const closedTestingPromptDay1 =
      ValueKey<String>('closed_testing_prompt_day_1');
  static const closedTestingPromptDay1CopyButton =
      ValueKey<String>('closed_testing_prompt_day_1_copy_button');
  static const closedTestingPromptDay1CompletedCheckbox =
      ValueKey<String>('closed_testing_prompt_day_1_completed_checkbox');
  static const closedTestingPromptDay3 =
      ValueKey<String>('closed_testing_prompt_day_3');
  static const closedTestingPromptDay3CopyButton =
      ValueKey<String>('closed_testing_prompt_day_3_copy_button');
  static const closedTestingPromptDay3CompletedCheckbox =
      ValueKey<String>('closed_testing_prompt_day_3_completed_checkbox');
  static const closedTestingPromptDay7 =
      ValueKey<String>('closed_testing_prompt_day_7');
  static const closedTestingPromptDay7CopyButton =
      ValueKey<String>('closed_testing_prompt_day_7_copy_button');
  static const closedTestingPromptDay7CompletedCheckbox =
      ValueKey<String>('closed_testing_prompt_day_7_completed_checkbox');
  static const closedTestingPromptDay14 =
      ValueKey<String>('closed_testing_prompt_day_14');
  static const closedTestingPromptDay14CopyButton =
      ValueKey<String>('closed_testing_prompt_day_14_copy_button');
  static const closedTestingPromptDay14CompletedCheckbox =
      ValueKey<String>('closed_testing_prompt_day_14_completed_checkbox');
  static const closedTestingFeedbackCopyButton =
      ValueKey<String>('closed_testing_feedback_copy_button');
  static const privacyDataInventoryPage =
      ValueKey<String>('privacy_data_inventory_page');
  static const deleteLocalDataPage = ValueKey<String>('delete_local_data_page');
  static const deleteLocalDataButton =
      ValueKey<String>('delete_local_data_button');
  static const settingsPrayerLocationTile =
      ValueKey<String>('settings_prayer_location_tile');
  static const manualPrayerLocationPage =
      ValueKey<String>('manual_prayer_location_page');
  static const manualLocationLabelField =
      ValueKey<String>('manual_location_label_field');
  static const manualLatitudeField = ValueKey<String>('manual_latitude_field');
  static const manualLongitudeField =
      ValueKey<String>('manual_longitude_field');
  static const manualTimezoneField = ValueKey<String>('manual_timezone_field');
  static const manualPrayerMethodDropdown =
      ValueKey<String>('manual_prayer_method_dropdown');
  static const manualLocationSaveButton =
      ValueKey<String>('manual_location_save_button');

  static ValueKey<String> duaListItem(String duaId) {
    return ValueKey<String>('dua_list_item_$duaId');
  }

  static ValueKey<String> duaCategoryChip(String category) {
    return ValueKey<String>('dua_category_$category');
  }

  static ValueKey<String> dhikrListItem(String dhikrId) {
    return ValueKey<String>('dhikr_list_item_$dhikrId');
  }

  static ValueKey<String> dhikrCategoryChip(String category) {
    return ValueKey<String>('dhikr_category_$category');
  }

  static ValueKey<String> savedItemTile(String savedItemId) {
    return ValueKey<String>('saved_item_tile_$savedItemId');
  }

  static ValueKey<String> savedItemRemoveButton(String savedItemId) {
    return ValueKey<String>('saved_item_remove_$savedItemId');
  }
}
