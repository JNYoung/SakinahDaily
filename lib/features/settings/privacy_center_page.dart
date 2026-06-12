import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../core/localization/sakinah_localizations.dart';
import '../../core/services/analytics_service.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/settings_tile.dart';

class PrivacyCenterPage extends ConsumerWidget {
  const PrivacyCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = SakinahLocalizations.of(context);
    final appEnvironment = ref.watch(appEnvironmentConfigProvider);
    final preferences = ref.watch(userPreferencesProvider);
    final userPreferencesController =
        ref.read(userPreferencesProvider.notifier);
    final privacyPolicyUri = appEnvironment.privacyPolicyUri;
    final analyticsAvailable = appEnvironment.analyticsEnabled;

    return LanguageAwareScaffold(
      key: SakinahKeys.privacyCenterPage,
      title: l10n.t('privacyCenterTitle'),
      selectedNavIndex: 3,
      body: ListView(
        children: [
          AppCard(
            radius: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SettingsTile(
                  title: l10n.t('dataOnDeviceTitle'),
                  subtitle: l10n.t('localOnlyData'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/privacy/data'),
                ),
                const Divider(),
                SettingsTile(
                  title: l10n.t('dataCanLeaveDeviceTitle'),
                  subtitle: l10n.t('leavesDeviceData'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _PrivacySection(
            title: l10n.t('womenModePrivacyTitle'),
            body: l10n.t('womenModePrivacyBody'),
          ),
          _PrivacySection(
            title: l10n.t('prayerLocationPrivacyTitle'),
            body: l10n.t('prayerLocationPrivacyBody'),
          ),
          _PrivacySection(
            title: l10n.t('notificationPrivacyTitle'),
            body: l10n.t('notificationPrivacyBody'),
          ),
          _PrivacySection(
            title: l10n.t('remoteContentPrivacyTitle'),
            body: l10n.t('remoteContentPrivacyBody'),
          ),
          _PrivacySection(
            title: l10n.t('analyticsPrivacyTitle'),
            body: l10n.t('analyticsPrivacyBody'),
          ),
          const SizedBox(height: 12),
          AppCard(
            radius: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SettingsTile(
                  title: l10n.t('analyticsOptInTitle'),
                  subtitle: analyticsAvailable
                      ? l10n.t('analyticsOptInAvailableBody')
                      : l10n.t('analyticsOptInUnavailableBody'),
                  trailing: Switch(
                    key: SakinahKeys.privacyAnalyticsSwitch,
                    value: analyticsAvailable && preferences.analyticsOptIn,
                    onChanged: analyticsAvailable
                        ? (enabled) {
                            unawaited(
                              _setAnalyticsOptInFromPrivacyCenter(
                                ref,
                                userPreferencesController,
                                enabled,
                              ),
                            );
                          }
                        : null,
                  ),
                ),
                const Divider(),
                SettingsTile(
                  title: l10n.t('deleteLocalDataTitle'),
                  subtitle: l10n.t('deleteLocalDataBody'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.go('/settings/privacy/delete-local-data'),
                ),
                const Divider(),
                if (privacyPolicyUri == null)
                  SettingsTile(
                    title: l10n.t('privacyPolicyDraftTitle'),
                    subtitle: l10n.t('privacyPolicyDraftBody'),
                  )
                else
                  SettingsTile(
                    key: SakinahKeys.privacyPolicyLinkTile,
                    title: l10n.t('privacyPolicyPublishedTitle'),
                    subtitle: privacyPolicyUri.toString(),
                    trailing: const Icon(Icons.copy),
                    onTap: () => _copyPrivacyPolicyUrl(
                      context,
                      l10n,
                      privacyPolicyUri,
                    ),
                  ),
                const Divider(),
                SettingsTile(
                  title: l10n.t('storePrivacyDraftTitle'),
                  subtitle: l10n.t('storePrivacyDraftBody'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _setAnalyticsOptInFromPrivacyCenter(
  WidgetRef ref,
  UserPreferencesController userPreferencesController,
  bool enabled,
) async {
  if (!enabled) {
    ref.read(analyticsServiceProvider).track(
      AnalyticsEventCatalog.analyticsConsentChanged,
      const {
        'enabled': false,
        'source': 'privacy_center',
      },
    );
    await userPreferencesController.setAnalyticsOptIn(false);
    await _setAnalyticsCollectionEnabled(ref, false);
    return;
  }

  await userPreferencesController.setAnalyticsOptIn(true);
  await _setAnalyticsCollectionEnabled(ref, true);
  ref.read(analyticsServiceProvider).track(
    AnalyticsEventCatalog.analyticsConsentChanged,
    const {
      'enabled': true,
      'source': 'privacy_center',
    },
  );
}

Future<void> _setAnalyticsCollectionEnabled(WidgetRef ref, bool enabled) async {
  if (!ref.read(appEnvironmentConfigProvider).analyticsEnabled) {
    return;
  }
  try {
    await ref
        .read(analyticsCollectionControllerProvider)
        .setCollectionEnabled(enabled);
  } catch (_) {
    // Firebase may be absent in local tests or unconfigured QA builds.
  }
}

void _copyPrivacyPolicyUrl(
  BuildContext context,
  SakinahLocalizations l10n,
  Uri privacyPolicyUri,
) {
  Clipboard.setData(ClipboardData(text: privacyPolicyUri.toString()));
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(l10n.t('privacyPolicyLinkCopied'))),
    );
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        radius: 8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}
