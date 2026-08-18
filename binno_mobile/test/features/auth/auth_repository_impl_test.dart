import 'package:binno_app/core/auth_session/session_tokens.dart';
import 'package:binno_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:binno_app/features/auth/data/models/auth_dto.dart';
import 'package:binno_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:binno_app/features/auth/domain/auth_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps challenge DTO to a domain entity', () async {
    final repository = AuthRepositoryImpl(_FakeRemoteDataSource());

    final result = await repository.requestOtp(
      '+998901234567',
      OtpPurpose.login,
    );

    expect(result.requestId, 'request-id');
    expect(result.expiresIn, 120);
    expect(result.retryAfter, 60);
  });

  test('maps authenticated verification without leaking transport DTO',
      () async {
    final remote = _FakeRemoteDataSource()
      ..verification = const AuthenticatedOtpVerificationDto(
        SessionTokens(accessToken: 'access', refreshToken: 'refresh'),
      );
    final result =
        await AuthRepositoryImpl(remote).verifyOtp('request', '123456');

    expect(result, isA<AuthenticatedOtpVerification>());
  });

  test('maps session DTOs to immutable domain entities', () async {
    final remote = _FakeRemoteDataSource()
      ..sessions = [
        ActiveSessionDto(
          id: 'session',
          deviceLabel: 'Pixel',
          createdAt: DateTime.utc(2026),
          lastUsedAt: DateTime.utc(2026, 1, 2),
          isCurrent: true,
        ),
      ];

    final result = await AuthRepositoryImpl(remote).getSessions();

    expect(result.single.id, 'session');
    expect(result.single.isCurrent, isTrue);
  });
}

final class _FakeRemoteDataSource implements AuthRemoteDataSource {
  OtpVerificationDto verification =
      const RegistrationRequiredOtpVerificationDto('registration-token');
  List<ActiveSessionDto> sessions = [];

  @override
  Future<void> completeRegistration({
    required String registrationToken,
    required String name,
    required String region,
  }) async {}

  @override
  Future<List<ActiveSessionDto>> getSessions() async => sessions;

  @override
  Future<void> logoutAll() async {}

  @override
  Future<OtpChallengeDto> requestOtp(
    String phone,
    OtpPurpose purpose,
  ) async {
    return const OtpChallengeDto(
      requestId: 'request-id',
      expiresIn: 120,
      retryAfter: 60,
    );
  }

  @override
  Future<void> revokeSession(String sessionId) async {}

  @override
  Future<OtpVerificationDto> verifyOtp(
    String requestId,
    String code,
  ) async {
    return verification;
  }
}
