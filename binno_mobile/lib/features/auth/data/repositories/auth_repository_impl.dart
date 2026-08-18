import 'package:binno_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:binno_app/features/auth/data/models/auth_dto.dart';
import 'package:binno_app/features/auth/domain/auth_models.dart';
import 'package:binno_app/features/auth/domain/auth_repository.dart';

final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<OtpChallenge> requestOtp(String phone, OtpPurpose purpose) async {
    final dto = await _remote.requestOtp(phone, purpose);
    return OtpChallenge(
      requestId: dto.requestId,
      expiresIn: dto.expiresIn,
      retryAfter: dto.retryAfter,
    );
  }

  @override
  Future<OtpVerification> verifyOtp(String requestId, String code) async {
    final dto = await _remote.verifyOtp(requestId, code);
    return switch (dto) {
      AuthenticatedOtpVerificationDto(:final tokens) =>
        OtpVerification.authenticated(tokens),
      RegistrationRequiredOtpVerificationDto(:final registrationToken) =>
        OtpVerification.registrationRequired(registrationToken),
    };
  }

  @override
  Future<void> completeRegistration({
    required String registrationToken,
    required String name,
    required String region,
  }) =>
      _remote.completeRegistration(
        registrationToken: registrationToken,
        name: name,
        region: region,
      );

  @override
  Future<List<ActiveSession>> getSessions() async {
    final sessions = await _remote.getSessions();
    return sessions
        .map(
          (dto) => ActiveSession(
            id: dto.id,
            deviceLabel: dto.deviceLabel,
            createdAt: dto.createdAt,
            lastUsedAt: dto.lastUsedAt,
            isCurrent: dto.isCurrent,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> revokeSession(String sessionId) =>
      _remote.revokeSession(sessionId);

  @override
  Future<void> logoutAll() => _remote.logoutAll();
}
