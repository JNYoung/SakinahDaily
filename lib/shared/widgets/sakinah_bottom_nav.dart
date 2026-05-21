import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
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
    );
  }
}
