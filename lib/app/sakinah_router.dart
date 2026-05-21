import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/daily_session/daily_session_page.dart';
import '../features/dhikr/dhikr_page.dart';
import '../features/dua/dua_detail_page.dart';
import '../features/dua/dua_library_page.dart';
import '../features/home/home_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/prayer/prayer_page.dart';
import '../features/settings/settings_page.dart';
import '../features/settings/womens_ibadah_mode_page.dart';
import '../features/splash/splash_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return createSakinahRouter();
});

GoRouter createSakinahRouter({String initialLocation = '/splash'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/session/:sessionId',
        builder: (context, state) {
          return DailySessionPage(
            sessionId: state.pathParameters['sessionId']!,
          );
        },
      ),
      GoRoute(
        path: '/daily-session/:sessionId',
        builder: (context, state) {
          return DailySessionPage(
            sessionId: state.pathParameters['sessionId']!,
          );
        },
      ),
      GoRoute(
        path: '/dua',
        builder: (context, state) => const DuaLibraryPage(),
      ),
      GoRoute(
        path: '/dua/:duaId',
        builder: (context, state) {
          return DuaDetailPage(duaId: state.pathParameters['duaId']!);
        },
      ),
      GoRoute(
        path: '/dhikr',
        builder: (context, state) => const DhikrPage(),
      ),
      GoRoute(
        path: '/dhikr/:dhikrId',
        builder: (context, state) {
          return DhikrPage(initialDhikrId: state.pathParameters['dhikrId']);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/settings/women',
        builder: (context, state) => const WomensIbadahModePage(),
      ),
      GoRoute(
        path: '/settings/women-ibadah',
        builder: (context, state) => const WomensIbadahModePage(),
      ),
      GoRoute(
        path: '/prayer',
        builder: (context, state) => const PrayerPage(),
      ),
    ],
  );
}
