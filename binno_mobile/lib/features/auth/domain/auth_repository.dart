import 'package:binno_app/features/auth/domain/auth_models.dart';

abstract interface class AuthRepository {
  Future<OtpChallenge> requestOtp(String phone, OtpPurpose purpose);
  Future<OtpVerification> verifyOtp(String requestId, String code);
  Future<void> completeRegistration({
    required String registrationToken,
    required String name,
    required String region,
  });
  Future<List<ActiveSession>> getSessions();
  Future<void> revokeSession(String sessionId);
  Future<void> logoutAll();
}
