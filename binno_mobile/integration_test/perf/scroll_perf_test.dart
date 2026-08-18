import 'package:binno_app/main_staging.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('catalog scroll performance', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    final list = find.byKey(const Key('catalog_grid'));
    if (list.evaluate().isEmpty) return;
    await binding.traceAction(
      () async {
        for (var index = 0; index < 10; index++) {
          await tester.fling(list, const Offset(0, -600), 2500);
          await tester.pumpAndSettle();
        }
      },
      reportKey: 'scroll_timeline',
    );
  });
}
