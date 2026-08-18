import 'package:binno_app/core/auth_session/session_storage.dart';
import 'package:binno_app/core/auth_session/session_tokens.dart';
import 'package:flutter/foundation.dart';

enum AuthSessionStatus { signedOut, authenticated, securityLogout }

final class AuthSession extends ChangeNotifier {
  AuthSession(this._storage);

  final SessionStorage _storage;
  String? _accessToken;
  AuthSessionStatus _status = AuthSessionStatus.signedOut;

  String? get accessToken => _accessToken;
  AuthSessionStatus get status => _status;

  Future<void> establish(SessionTokens tokens) async {
    _accessToken = tokens.accessToken;
    await _storage.writeRefreshToken(tokens.refreshToken);
    _status = AuthSessionStatus.authenticated;
    notifyListeners();
  }

  Future<void> clear({bool securityEvent = false}) async {
    _accessToken = null;
    await _storage.clear();
    _status = securityEvent
        ? AuthSessionStatus.securityLogout
        : AuthSessionStatus.signedOut;
    notifyListeners();
  }
}
