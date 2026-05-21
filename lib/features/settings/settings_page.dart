import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/settings_tile.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = SakinahLocalizations.of(context);
    final preferences = ref.watch(userPreferencesProvider);
    final controller = ref.read(userPreferencesProvider.notifier);

    return LanguageAwareScaffold(
      title: l10n.t('settings'),
      selectedNavIndex: 3,
      body: ListView(
        children: [
          SettingsTile(
            title: l10n.t('language'),
            subtitle: preferences.languageCode,
            trailing: DropdownButton<String>(
              value: preferences.languageCode,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'id', child: Text('Indonesia')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.setLanguage(value);
                }
              },
            ),
          ),
          const Divider(),
          SettingsTile(
            title: l10n.t('prayerMethod'),
            subtitle: preferences.prayerSettings.method,
          ),
          const Divider(),
          SettingsTile(
            title: l10n.t('prayerReminders'),
            subtitle: l10n.t('prayerReminderSubtitle'),
            trailing: Switch(
              value: preferences.notificationsEnabled,
              onChanged: controller.setNotificationsEnabled,
            ),
          ),
          const Divider(),
          SettingsTile(
            key: SakinahKeys.settingsWomenModeTile,
            title: l10n.t('womenMode'),
            subtitle: l10n.t('womenModeSubtitle'),
            trailing: Switch(
              value: preferences.womenIbadahMode.enabled,
              onChanged: controller.setWomenMode,
            ),
            onTap: () => context.go('/settings/women'),
          ),
          const Divider(),
          SettingsTile(
            title: l10n.t('privacy'),
            subtitle: l10n.t('privacySubtitle'),
          ),
        ],
      ),
    );
  }
}
