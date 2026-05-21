import 'package:flutter/foundation.dart';

abstract final class SakinahKeys {
  static const splashPage = ValueKey<String>('splash_page');
  static const splashBrand = ValueKey<String>('splash_brand');
  static const splashTagline = ValueKey<String>('splash_tagline');

  static const onboardingContinueButton =
      ValueKey<String>('onboarding_continue_button');

  static const homePrayerBadge = ValueKey<String>('home_prayer_badge');
  static const homeContentList = ValueKey<String>('home_content_list');
  static const homeSessionStartButton =
      ValueKey<String>('home_session_start_button');
  static const homeQuickActionQuran =
      ValueKey<String>('home_quick_action_quran');
  static const homeQuickActionDua = ValueKey<String>('home_quick_action_dua');
  static const homeQuickActionDhikr =
      ValueKey<String>('home_quick_action_dhikr');
  static const homeQuickActionQibla =
      ValueKey<String>('home_quick_action_qibla');

  static const bottomNavHome = ValueKey<String>('bottom_nav_home');
  static const bottomNavDua = ValueKey<String>('bottom_nav_dua');
  static const bottomNavDhikr = ValueKey<String>('bottom_nav_dhikr');
  static const bottomNavSettings = ValueKey<String>('bottom_nav_settings');

  static const dhikrCounter = ValueKey<String>('dhikr_counter');
  static const sessionDhikrCounter = ValueKey<String>('session_dhikr_counter');
  static const sessionNextButton = ValueKey<String>('session_next_button');
  static const sessionFinishButton = ValueKey<String>('session_finish_button');

  static const settingsWomenModeTile =
      ValueKey<String>('settings_women_mode_tile');
  static const settingsPrayerMethodDropdown =
      ValueKey<String>('settings_prayer_method_dropdown');
  static const settingsNotificationSwitch =
      ValueKey<String>('settings_notification_switch');
  static const womenModeNormalChip = ValueKey<String>('women_mode_normal_chip');
  static const womenModeMenstruatingChip =
      ValueKey<String>('women_mode_menstruating_chip');
  static const womenModePostpartumChip =
      ValueKey<String>('women_mode_postpartum_chip');
  static const womenModePregnancyChip =
      ValueKey<String>('women_mode_pregnancy_chip');
  static const womenModeStartButton =
      ValueKey<String>('women_mode_start_button');

  static ValueKey<String> duaListItem(String duaId) {
    return ValueKey<String>('dua_list_item_$duaId');
  }
}
