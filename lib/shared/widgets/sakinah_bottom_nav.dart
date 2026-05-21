import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/sakinah_theme.dart';
import '../../core/localization/sakinah_localizations.dart';
import '../sakinah_keys.dart';

class SakinahBottomNav extends StatelessWidget {
  const SakinahBottomNav({
    required this.selectedIndex,
    super.key,
  });

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = SakinahLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : SakinahColors.warmTaupe.withValues(alpha: 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/home');
                  return;
                case 1:
                  context.go('/dua');
                  return;
                case 2:
                  context.go('/dhikr');
                  return;
                case 3:
                  context.go('/settings');
                  return;
              }
            },
            destinations: [
              NavigationDestination(
                key: SakinahKeys.bottomNavHome,
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: l10n.t('home'),
              ),
              NavigationDestination(
                key: SakinahKeys.bottomNavDua,
                icon: const Icon(Icons.favorite_border_rounded),
                selectedIcon: const Icon(Icons.favorite_rounded),
                label: l10n.t('dua'),
              ),
              NavigationDestination(
                key: SakinahKeys.bottomNavDhikr,
                icon: const Icon(Icons.radio_button_unchecked_rounded),
                selectedIcon: const Icon(Icons.radio_button_checked_rounded),
                label: l10n.t('dhikr'),
              ),
              NavigationDestination(
                key: SakinahKeys.bottomNavSettings,
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings_rounded),
                label: l10n.t('settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
