import 'package:flutter/material.dart';

import '../../app/theme/sakinah_theme.dart';
import 'sakinah_bottom_nav.dart';
import 'sakinah_pattern.dart';

class LanguageAwareScaffold extends StatelessWidget {
  const LanguageAwareScaffold({
    required this.title,
    required this.body,
    this.actions,
    this.selectedNavIndex,
    this.darkPattern = false,
    this.showAppBar = true,
    super.key,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final int? selectedNavIndex;
  final bool darkPattern;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final background =
        darkPattern ? SakinahColors.midnightNavy : SakinahColors.ivory;
    return Scaffold(
      backgroundColor: background,
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              backgroundColor: Colors.transparent,
              actions: actions,
            )
          : null,
      body: SakinahPattern(
        dark: darkPattern,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 16),
            child: body,
          ),
        ),
      ),
      bottomNavigationBar: selectedNavIndex == null
          ? null
          : SakinahBottomNav(selectedIndex: selectedNavIndex!),
    );
  }
}
