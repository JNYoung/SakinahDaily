import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('Daily Session renders local-only women mode note',
      (tester) async {
    final store = await _preferencesWithWomenMode(
      WomenIbadahStatus.menstruating,
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/session/session_morning_ease',
      settleSplash: false,
      preferencesStore: store,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.sessionWomenModeNote), findsOneWidget);
    expect(find.text('Local-only mode'), findsOneWidget);
    expect(
      find.textContaining('Your mode stays on this device'),
      findsOneWidget,
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('Daily Session note avoids sensitive status terms',
      (tester) async {
    final store = await _preferencesWithWomenMode(
      WomenIbadahStatus.postpartum,
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/session/session_morning_ease',
      settleSplash: false,
      preferencesStore: store,
    );
    await tester.pumpAndSettle();

    final visible = _visibleText(tester).toLowerCase();
    for (final term in _sensitiveTerms) {
      expect(visible, isNot(contains(term)));
    }
    expectNoFlutterErrors(tester);
  });

  testWidgets('normal mode Daily Session is unaffected', (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/session/session_morning_ease',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.text('Step 1 of 6 · Set intention'), findsOneWidget);
    expect(find.byKey(SakinahKeys.sessionWomenModeNote), findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets('discreet women mode hides Daily Session privacy note',
      (tester) async {
    final store = await _preferencesWithWomenMode(
      WomenIbadahStatus.menstruating,
      discreetModeEnabled: true,
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/session/session_morning_ease',
      settleSplash: false,
      preferencesStore: store,
    );
    await tester.pumpAndSettle();

    expect(find.text('Step 1 of 6 · Set intention'), findsOneWidget);
    expect(find.byKey(SakinahKeys.sessionWomenModeNote), findsNothing);
    expect(find.text('Local-only mode'), findsNothing);
    expectNoFlutterErrors(tester);
  });
}

const _sensitiveTerms = [
  'menstruat',
  'period',
  'postpartum',
  'pregnan',
  'cycle',
  'haidh',
  'nifas',
];

Future<InMemoryUserPreferencesStore> _preferencesWithWomenMode(
  WomenIbadahStatus status, {
  bool discreetModeEnabled = false,
}) async {
  final store = InMemoryUserPreferencesStore();
  await UserPreferencesRepository(store).save(
    UserPreferences.defaults().copyWith(
      womenIbadahMode: WomenIbadahMode(
        enabled: true,
        status: status,
        discreetModeEnabled: discreetModeEnabled,
      ),
    ),
  );
  return store;
}

String _visibleText(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
      .join('\n');
}
