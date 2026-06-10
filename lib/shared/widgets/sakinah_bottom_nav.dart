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
                  context.go('/prayer');
                  return;
                case 2:
                  context.go('/session/session_morning_ease');
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
                key: SakinahKeys.bottomNavPrayer,
                icon: const Icon(Icons.schedule_outlined),
                selectedIcon: const Icon(Icons.schedule_rounded),
                label: l10n.t('prayer'),
              ),
              NavigationDestination(
                key: SakinahKeys.bottomNavSession,
                icon: const Icon(Icons.nightlight_outlined),
                selectedIcon: const Icon(Icons.nightlight_round),
                label: l10n.t('session'),
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
