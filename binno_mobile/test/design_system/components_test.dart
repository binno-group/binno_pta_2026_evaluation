import 'package:binno_app/design_system/components/binno_button.dart';
import 'package:binno_app/design_system/components/binno_empty_state.dart';
import 'package:binno_app/design_system/components/binno_error_state.dart';
import 'package:binno_app/design_system/components/binno_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/a11y.dart';
import '../support/test_app.dart';

void main() {
  for (final width in [320.0, 430.0]) {
    testWidgets('F1 components are accessible at $width', (tester) async {
      await setPhoneSize(tester, width);
      await tester.pumpWidget(
        testApp(
          Scaffold(
            body: ListView(
              children: [
                BinnoButton(label: 'Davom etish', onPressed: () {}),
                const BinnoTextField(label: 'Telefon raqami'),
                const BinnoEmptyState(
                  title: "Ma'lumot yo'q",
                  explanation: "Yangi ma'lumot shu yerda ko'rinadi.",
                ),
                BinnoErrorState(
                  title: 'Xatolik',
                  explanation: "Qayta urinib ko'ring.",
                  actionLabel: 'Qayta urinish',
                  onRetry: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await expectBinnoA11y(tester);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/f1_components_$width.png'),
      );
    });
  }
}
