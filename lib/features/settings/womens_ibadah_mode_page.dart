import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/sakinah_theme.dart';
import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/analytics_service.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/primary_button.dart';

class WomensIbadahModePage extends ConsumerWidget {
  const WomensIbadahModePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = SakinahLocalizations.of(context);
    final preferences = ref.watch(userPreferencesProvider);
    final status = preferences.womenIbadahMode.status;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LanguageAwareScaffold(
      title: l10n.t('womenMode'),
      selectedNavIndex: 3,
      body: ListView(
        children: [
          Text(
            l10n.t('womenMode'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.t('womenModeDescription'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          AppCard(
            color: isDark ? SakinahColors.navyCard : null,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.t('todaysMode'),
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _ModeChip(
                      key: SakinahKeys.womenModeNormalChip,
                      label: l10n.t('modeNormal'),
                      selected: status == WomenIbadahStatus.normal,
                      onTap: () => _setWomenModeStatus(
                        ref,
                        WomenIbadahStatus.normal,
                      ),
                    ),
                    _ModeChip(
                      key: SakinahKeys.womenModeMenstruatingChip,
                      label: l10n.t('modeMenstruating'),
                      selected: status == WomenIbadahStatus.menstruating,
                      onTap: () => _setWomenModeStatus(
                        ref,
                        WomenIbadahStatus.menstruating,
                      ),
                    ),
                    _ModeChip(
                      key: SakinahKeys.womenModePostpartumChip,
                      label: l10n.t('modePostpartum'),
                      selected: status == WomenIbadahStatus.postpartum,
                      onTap: () => _setWomenModeStatus(
                        ref,
                        WomenIbadahStatus.postpartum,
                      ),
                    ),
                    _ModeChip(
                      key: SakinahKeys.womenModePregnancyChip,
                      label: l10n.t('modePregnancy'),
                      selected: status == WomenIbadahStatus.pregnancy,
                      onTap: () => _setWomenModeStatus(
                        ref,
                        WomenIbadahStatus.pregnancy,
                      ),
                    ),
                    _ModeChip(
                      key: SakinahKeys.womenModePreferNotToTrackChip,
                      label: l10n.t('modePreferNotToTrack'),
                      selected: status == WomenIbadahStatus.preferNotToTrack,
                      onTap: () => _setWomenModeStatus(
                        ref,
                        WomenIbadahStatus.preferNotToTrack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Chip(
                  avatar: const Icon(Icons.lock_outline_rounded, size: 16),
                  label: Text(l10n.t('dataStaysLocal')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            key: SakinahKeys.womenModeLocalChangesCard,
            color: isDark ? SakinahColors.navyCard : null,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('womenModeWhatChangesTitle'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(l10n.t('womenModeWhatChangesBody')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            key: SakinahKeys.womenModePrivacyDetailsCard,
            color: isDark ? SakinahColors.navyCard : null,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('womenModeWhatStaysPrivateTitle'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(l10n.t('womenModeWhatStaysPrivateBody')),
                const SizedBox(height: 12),
                Text(l10n.t('womenModeReminderPrivacyBody')),
                const SizedBox(height: 12),
                Text(l10n.t('womenModeTurnOffBody')),
                const SizedBox(height: 18),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: PrimaryButton(
                    label: l10n.t('openPrivacyCenter'),
                    tonal: true,
                    icon: Icons.privacy_tip_outlined,
                    onPressed: () => context.go('/settings/privacy'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            key: SakinahKeys.womenModeRecommendedCard,
            color: SakinahColors.deepEmerald,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('recommendedNow'),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.78)),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.t('gentleWorshipMoment'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t('womenRecommendedDescription'),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.78)),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 128,
                  child: PrimaryButton(
                    key: SakinahKeys.womenModeStartButton,
                    label: l10n.t('start'),
                    onPressed: () => context.go('/home'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            color: isDark ? SakinahColors.navyCard : null,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('reminderBehavior'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.t('reminderBehaviorDescription'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _setWomenModeStatus(WidgetRef ref, WomenIbadahStatus status) {
  unawaited(
    ref.read(userPreferencesProvider.notifier).setWomenModeStatus(status),
  );
  ref.read(analyticsServiceProvider).track(
    AnalyticsEventCatalog.womenIbadahModeChanged,
    {
      'enabled': status != WomenIbadahStatus.normal,
      'source': 'women_mode',
    },
  );
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
      label: SizedBox(
        width: 116,
        child: Center(child: Text(label)),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: SakinahColors.deepEmerald,
      labelStyle: TextStyle(
        color: selected
            ? Colors.white
            : (isDark ? Colors.white70 : SakinahColors.ink),
        fontWeight: FontWeight.w700,
      ),
      backgroundColor:
          isDark ? SakinahColors.midnightNavy : const Color(0xFFEFE7DC),
      side: BorderSide.none,
    );
  }
}
