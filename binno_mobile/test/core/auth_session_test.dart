import 'package:binno_app/core/auth_session/auth_session.dart';
import 'package:binno_app/core/auth_session/session_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/auth/fakes.dart';

void main() {
  test('publishes authenticated and signed-out state changes', () async {
    final session = AuthSession(MemorySessionStorage());
    var notifications = 0;
    session.addListener(() => notifications++);

    await session.establish(
      const SessionTokens(accessToken: 'access', refreshToken: 'refresh'),
    );
    expect(session.status, AuthSessionStatus.authenticated);

    await session.clear();
    expect(session.status, AuthSessionStatus.signedOut);
    expect(notifications, 2);
  });

  test('publishes a distinct security logout state', () async {
    final session = AuthSession(MemorySessionStorage());

    await session.clear(securityEvent: true);

    expect(session.status, AuthSessionStatus.securityLogout);
  });
}
