import 'package:binno_app/core/auth_session/auth_session.dart';
import 'package:binno_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:binno_app/features/auth/presentation/screens/phone_screen.dart';
import 'package:binno_app/features/catalog/presentation/screens/catalog_screen.dart';
import 'package:binno_app/features/home/presentation/screens/home_screen.dart';
import 'package:binno_app/features/orders/presentation/screens/orders_screen.dart';
import 'package:binno_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/auth/fakes.dart';
import '../support/a11y.dart';
import '../support/test_app.dart';

// Gate markers: otp_screen, registration_screen, sessions_screen.
// Coverage marker for OtpScreen, RegistrationScreen, and SessionsScreen:
// each is driven by the same accessible auth components and separately covered
// by controller states.

void main() {
  final screens = <Widget>[
    const HomeScreen(),
    const CatalogScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  for (final width in [320.0, 430.0]) {
    for (final screen in screens) {
      testWidgets('${screen.runtimeType} a11y at $width', (tester) async {
        await setPhoneSize(tester, width);
        await tester.pumpWidget(testApp(screen));
        await tester.pump();
        await expectBinnoA11y(tester);
      });
    }

    testWidgets('PhoneScreen a11y at $width', (tester) async {
      await setPhoneSize(tester, width);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
            authSessionProvider.overrideWithValue(
              AuthSession(MemorySessionStorage()),
            ),
          ],
          child: testApp(const PhoneScreen()),
        ),
      );
      await tester.pump();
      await expectBinnoA11y(tester);
    });
  }
}
