import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/daily_session/daily_session_page.dart';
import '../features/dhikr/dhikr_page.dart';
import '../features/dua/dua_detail_page.dart';
import '../features/dua/dua_library_page.dart';
import '../features/home/home_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/prayer/prayer_page.dart';
import '../features/qibla/qibla_page.dart';
import '../features/quran/quran_page.dart';
import '../features/quran/quran_verse_detail_page.dart';
import '../features/saved/saved_items_page.dart';
import '../features/prayer/manual_prayer_location_page.dart';
import '../features/settings/settings_page.dart';
import '../features/settings/delete_local_data_page.dart';
import '../features/settings/privacy_center_page.dart';
import '../features/settings/privacy_data_inventory_page.dart';
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
        path: '/qibla',
        builder: (context, state) => const QiblaPage(),
      ),
      GoRoute(
        path: '/quran',
        builder: (context, state) => const QuranPage(),
      ),
      GoRoute(
        path: '/quran/:verseKey',
        builder: (context, state) {
          return QuranVerseDetailPage(
            verseKey: state.pathParameters['verseKey']!,
          );
        },
      ),
      GoRoute(
        path: '/saved',
        builder: (context, state) => const SavedItemsPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/settings/privacy',
        builder: (context, state) => const PrivacyCenterPage(),
      ),
      GoRoute(
        path: '/settings/privacy/data',
        builder: (context, state) => const PrivacyDataInventoryPage(),
      ),
      GoRoute(
        path: '/settings/privacy/delete-local-data',
        builder: (context, state) => const DeleteLocalDataPage(),
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
        path: '/settings/prayer-location',
        builder: (context, state) => const ManualPrayerLocationPage(),
      ),
      GoRoute(
        path: '/prayer',
        builder: (context, state) => const PrayerPage(),
      ),
    ],
  );
}
