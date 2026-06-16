import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('women mode enabled changes Home support label', (tester) async {
    final store = await _preferencesWithWomenMode(
      WomenIbadahStatus.menstruating,
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
      preferencesStore: store,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.homeWomenModeSupportCard), findsOneWidget);
    expect(find.text('Private gentle path'), findsOneWidget);
    expect(find.text('Local-only mode'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Home does not show sensitive women mode terms', (tester) async {
    final store = await _preferencesWithWomenMode(
      WomenIbadahStatus.postpartum,
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
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

  testWidgets('women mode disabled shows standard Home', (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.homeSessionCard), findsOneWidget);
    expect(find.byKey(SakinahKeys.homeWomenModeSupportCard), findsNothing);
    expect(find.text('Private gentle path'), findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets('discreet women mode hides Home support copy', (tester) async {
    final store = await _preferencesWithWomenMode(
      WomenIbadahStatus.menstruating,
      discreetModeEnabled: true,
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
      preferencesStore: store,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.homeSessionCard), findsOneWidget);
    expect(find.byKey(SakinahKeys.homeWomenModeSupportCard), findsNothing);
    expect(find.text('Private gentle path'), findsNothing);
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
