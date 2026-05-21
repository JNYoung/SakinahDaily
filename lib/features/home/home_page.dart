import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/sakinah_theme.dart';
import '../../core/localization/sakinah_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/primary_button.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = SakinahLocalizations.of(context);
    final preferences = ref.watch(userPreferencesProvider);
    final sessions = ref.watch(dailySessionsProvider);
    final prayerService = ref.watch(prayerCalculationServiceProvider);
    final now = DateTime.now();
    final nextPrayer =
        prayerService.nextPrayer(now, preferences.prayerSettings);
    final session = sessions.first;

    return LanguageAwareScaffold(
      title: l10n.t('appTitle'),
      showAppBar: false,
      selectedNavIndex: 0,
      actions: [
        IconButton(
          tooltip: l10n.t('settings'),
          onPressed: () => context.go('/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      body: ListView(
        key: SakinahKeys.homeContentList,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.t('homeGreeting')},',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: SakinahColors.mutedText),
                    ),
                    Text(
                      preferences.genderMode.name == 'female'
                          ? l10n.t('homeFemaleName')
                          : l10n.t('homeFriend'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      l10n.t('homeDateLabel'),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: SakinahColors.mutedText),
                    ),
                  ],
                ),
              ),
              _PrayerBadge(
                key: SakinahKeys.homePrayerBadge,
                label: l10n.prayerCountdown(
                  nextPrayer.name,
                  nextPrayer.time.difference(now).inHours.clamp(0, 24),
                  nextPrayer.time
                      .difference(now)
                      .inMinutes
                      .remainder(60)
                      .clamp(0, 59),
                ),
                onTap: () => context.push('/prayer'),
              ),
            ],
          ),
          const SizedBox(height: 26),
          _HeroSessionCard(
            eyebrow: l10n.t('todaySession'),
            title: session.title.resolve(preferences.languageCode),
            subtitle: l10n.t('sessionSubtitleMeta'),
            startButtonKey: SakinahKeys.homeSessionStartButton,
            startLabel: l10n.t('start'),
            voiceOnlyLabel: l10n.t('voiceOnly'),
            onStart: () => context.go('/session/${session.id}'),
          ),
          const SizedBox(height: 28),
          Text(l10n.t('quickActions'),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            childAspectRatio: 0.9,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _QuickAction(
                key: SakinahKeys.homeQuickActionQuran,
                icon: Icons.menu_book_outlined,
                label: l10n.t('quran'),
                onTap: () => context.go('/session/${session.id}'),
              ),
              _QuickAction(
                key: SakinahKeys.homeQuickActionDua,
                icon: Icons.favorite_border_rounded,
                label: l10n.t('dua'),
                onTap: () => context.go('/dua'),
              ),
              _QuickAction(
                key: SakinahKeys.homeQuickActionDhikr,
                icon: Icons.radio_button_checked_rounded,
                label: l10n.t('dhikr'),
                onTap: () => context.go('/dhikr'),
              ),
              _QuickAction(
                key: SakinahKeys.homeQuickActionQibla,
                icon: Icons.explore_outlined,
                label: l10n.t('qibla'),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 28),
          AppCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('tonight'),
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: SakinahColors.mutedText),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.t('sleepAyatKursi'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t('sleepSessionDescription'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 136,
                  child: PrimaryButton(
                    label: l10n.t('saveTonight'),
                    tonal: true,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerBadge extends StatelessWidget {
  const _PrayerBadge({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.circle, size: 8, color: SakinahColors.sandGold),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: const Color(0xFFEAF3E7),
      side: BorderSide.none,
      labelStyle: const TextStyle(
        color: SakinahColors.deepEmerald,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _HeroSessionCard extends StatelessWidget {
  const _HeroSessionCard({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.startButtonKey,
    required this.startLabel,
    required this.voiceOnlyLabel,
    required this.onStart,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Key startButtonKey;
  final String startLabel;
  final String voiceOnlyLabel;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: SakinahColors.deepEmerald,
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          PositionedDirectional(
            end: 6,
            top: 16,
            child: Icon(
              Icons.nightlight_round,
              size: 72,
              color: SakinahColors.sandGold.withValues(alpha: 0.82),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.78)),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      key: startButtonKey,
                      label: startLabel,
                      onPressed: onStart,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: PrimaryButton(
                      label: voiceOnlyLabel,
                      tonal: true,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: SakinahColors.sandGold),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SakinahColors.ink,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
