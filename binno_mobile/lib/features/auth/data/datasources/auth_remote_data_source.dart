import 'package:binno_app/features/auth/data/models/auth_dto.dart';
import 'package:binno_app/features/auth/domain/auth_models.dart';

abstract interface class AuthRemoteDataSource {
  Future<OtpChallengeDto> requestOtp(String phone, OtpPurpose purpose);
  Future<OtpVerificationDto> verifyOtp(String requestId, String code);
  Future<void> completeRegistration({
    required String registrationToken,
    required String name,
    required String region,
  });
  Future<List<ActiveSessionDto>> getSessions();
  Future<void> revokeSession(String sessionId);
  Future<void> logoutAll();
}
