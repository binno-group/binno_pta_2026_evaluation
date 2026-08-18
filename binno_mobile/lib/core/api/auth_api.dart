import 'package:binno_app/core/auth_session/session_tokens.dart';

abstract interface class TokenRefreshApi {
  Future<SessionTokens> refresh(String refreshToken);
}
