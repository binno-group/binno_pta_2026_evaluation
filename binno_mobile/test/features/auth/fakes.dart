import 'dart:async';

import 'package:binno_app/core/auth_session/session_storage.dart';
import 'package:binno_app/features/auth/domain/auth_models.dart';
import 'package:binno_app/features/auth/domain/auth_repository.dart';

final class MemorySessionStorage implements SessionStorage {
  String? token;

  @override
  Future<void> clear() async => token = null;

  @override
  Future<String?> readRefreshToken() async => token;

  @override
  Future<void> writeRefreshToken(String token) async => this.token = token;
}

final class FakeAuthRepository implements AuthRepository {
  OtpChallenge challenge = const OtpChallenge(
    requestId: 'request-id',
    expiresIn: 120,
    retryAfter: 60,
  );
  Object? requestError;
  Object? verifyError;
  OtpVerification verification = const OtpVerification.registrationRequired(
    'registration-token',
  );
  Completer<OtpVerification>? verificationCompleter;
  List<ActiveSession> sessions = [];

  @override
  Future<void> completeRegistration({
    required String registrationToken,
    required String name,
    required String region,
  }) async {}

  @override
  Future<List<ActiveSession>> getSessions() async => sessions;

  @override
  Future<void> logoutAll() async {}

  @override
  Future<OtpChallenge> requestOtp(String phone, OtpPurpose purpose) async {
    if (requestError case final error?) throw error;
    return challenge;
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    sessions = sessions.where((session) => session.id != sessionId).toList();
  }

  @override
  Future<OtpVerification> verifyOtp(String requestId, String code) {
    if (verifyError case final error?) throw error;
    return verificationCompleter?.future ?? Future.value(verification);
  }
}
