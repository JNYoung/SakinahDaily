import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('Quran page remains available as a secondary route',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/quran',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.quranPage), findsOneWidget);
    expect(find.text('Quran'), findsWidgets);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Quran page renders featured ayah source', (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/quran',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.quranPage), findsOneWidget);
    expect(find.text('Featured ayah'), findsOneWidget);
    expect(
        find.text('For indeed, with hardship will be ease.'), findsOneWidget);
    expect(
      find.textContaining('Seed metadata; replace with approved Quran source'),
      findsOneWidget,
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('Quran page shows voice-only safety labels', (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/quran',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('No Quran TTS'), findsOneWidget);
    expect(find.textContaining('No background music'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });
}
