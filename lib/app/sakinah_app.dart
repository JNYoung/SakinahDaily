import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/sakinah_localizations.dart';
import '../core/providers/app_providers.dart';
import '../shared/widgets/sakinah_scroll_behavior.dart';
import 'sakinah_router.dart';
import 'theme/sakinah_theme.dart';

class SakinahApp extends ConsumerWidget {
  const SakinahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Sakinah Daily',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: SakinahLocalizations.supportedLocales,
      localizationsDelegates: const [
        SakinahLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: SakinahTheme.light,
      darkTheme: SakinahTheme.dark,
      scrollBehavior: const SakinahScrollBehavior(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
