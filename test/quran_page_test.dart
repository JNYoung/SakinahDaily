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
      find.text('For indeed, with hardship will be ease.'),
      findsWidgets,
    );
    expect(
      find.textContaining('Seed metadata; replace with approved Quran source'),
      findsWidgets,
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

  testWidgets('Quran page lists approved local verses and opens detail',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/quran',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.text('Available verses'), findsOneWidget);
    expect(find.byKey(SakinahKeys.quranVerseCard('1:1')), findsOneWidget);
    expect(find.byKey(SakinahKeys.quranVerseCard('94:5')), findsOneWidget);
    expect(find.byKey(SakinahKeys.quranVerseCard('13:28')), findsOneWidget);

    await tapByKey(tester, SakinahKeys.quranVerseCard('13:28'));

    expect(find.byKey(SakinahKeys.quranVerseDetailPage), findsOneWidget);
    expect(find.text('Quran 13:28'), findsWidgets);
    expect(
      find.text(
          'Unquestionably, by the remembrance of Allah hearts are assured.'),
      findsOneWidget,
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('Quran page filters approved local verses by reference and text',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/quran',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(SakinahKeys.quranVerseSearchField),
      'remembrance',
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.quranVerseCard('13:28')), findsOneWidget);
    expect(find.byKey(SakinahKeys.quranVerseCard('94:5')), findsNothing);

    await tester.enterText(
      find.byKey(SakinahKeys.quranVerseSearchField),
      '2:255',
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.quranVerseEmptyState), findsOneWidget);
    expect(find.text('No reviewed local verse matches this search.'),
        findsOneWidget);
    expectNoFlutterErrors(tester);
  });
}
