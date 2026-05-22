import 'dart:math' as math;

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

class QiblaPage extends ConsumerWidget {
  const QiblaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = SakinahLocalizations.of(context);
    final preferences = ref.watch(userPreferencesProvider);
    final bearing = ref
        .watch(qiblaServiceProvider)
        .calculateBearing(preferences.prayerSettings);
    final roundedDegrees = bearing.degrees.round();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LanguageAwareScaffold(
      title: l10n.t('qibla'),
      body: ListView(
        key: SakinahKeys.qiblaPage,
        children: [
          Text(
            l10n.t('qiblaTitle'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.t('qiblaNoGpsRequired'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          AppCard(
            color: isDark ? SakinahColors.navyCard : null,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  preferences.prayerSettings.locationLabel,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 22),
                _StaticCompass(degrees: bearing.degrees),
                const SizedBox(height: 18),
                Text(
                  l10n.qiblaBearingLabel(
                    roundedDegrees,
                    bearing.cardinalLabel,
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t('qiblaBasedOnSelectedLocation'),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: l10n.t('qiblaChangeLocation'),
            icon: Icons.location_on_outlined,
            tonal: true,
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
    );
  }
}

class _StaticCompass extends StatelessWidget {
  const _StaticCompass({required this.degrees});

  final double degrees;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox.square(
      dimension: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? SakinahColors.midnightNavy : SakinahColors.ivory,
              border: Border.all(color: SakinahColors.sandGold, width: 2),
            ),
          ),
          const Positioned(top: 16, child: Text('N')),
          const Positioned(right: 18, child: Text('E')),
          const Positioned(bottom: 16, child: Text('S')),
          const Positioned(left: 18, child: Text('W')),
          Transform.rotate(
            angle: degrees * math.pi / 180,
            child: const Icon(
              Icons.navigation_rounded,
              size: 88,
              color: SakinahColors.deepEmerald,
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: SakinahColors.sandGold,
            ),
          ),
        ],
      ),
    );
  }
}
