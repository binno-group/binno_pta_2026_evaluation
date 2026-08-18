import 'package:binno_api/binno_api.dart' as api;
import 'package:binno_app/core/api/problem_parser.dart';
import 'package:binno_app/core/auth_session/session_tokens.dart';
import 'package:binno_app/core/errors/domain_failure.dart';
import 'package:binno_app/core/errors/failure_mapper.dart';
import 'package:binno_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:binno_app/features/auth/data/models/auth_dto.dart';
import 'package:binno_app/features/auth/domain/auth_models.dart';
import 'package:dio/dio.dart';

final class GeneratedAuthRemoteDataSource implements AuthRemoteDataSource {
  const GeneratedAuthRemoteDataSource(this._api);

  final api.AuthApi _api;

  @override
  Future<OtpChallengeDto> requestOtp(
    String phone,
    OtpPurpose purpose,
  ) async {
    try {
      final response = await _api.authOtpRequestPost(
        authOtpRequestPostRequest: api.AuthOtpRequestPostRequest(
          (builder) => builder
            ..phone = phone
            ..purpose = purpose == OtpPurpose.login
                ? api.AuthOtpRequestPostRequestPurposeEnum.login
                : api.AuthOtpRequestPostRequestPurposeEnum.register,
        ),
      );
      final data = response.data;
      if (data?.requestId == null) throw const UnexpectedFailure();
      return OtpChallengeDto(
        requestId: data!.requestId!,
        expiresIn: data.expiresIn ?? 0,
        retryAfter: data.retryAfter ?? 0,
      );
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<OtpVerificationDto> verifyOtp(
    String requestId,
    String code,
  ) async {
    try {
      final response = await _api.authOtpVerifyPost(
        authOtpVerifyPostRequest: api.AuthOtpVerifyPostRequest(
          (builder) => builder
            ..requestId = requestId
            ..code = code,
        ),
      );
      final value = response.data?.oneOf.value;
      if (value is api.TokenPair) {
        if (value.accessToken == null || value.refreshToken == null) {
          throw const UnexpectedFailure();
        }
        return AuthenticatedOtpVerificationDto(
          SessionTokens(
            accessToken: value.accessToken!,
            refreshToken: value.refreshToken!,
          ),
        );
      }
      if (value is api.AuthOtpVerifyPost200ResponseOneOf &&
          value.registrationToken != null) {
        return RegistrationRequiredOtpVerificationDto(
          value.registrationToken!,
        );
      }
      throw const UnexpectedFailure();
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  // These operations deliberately fail closed: the supplied OpenAPI contract
  // has no paths for them. Add paths to the SSOT and regenerate before wiring.
  @override
  Future<void> completeRegistration({
    required String registrationToken,
    required String name,
    required String region,
  }) =>
      throw const UnexpectedFailure();

  @override
  Future<List<ActiveSessionDto>> getSessions() =>
      throw const UnexpectedFailure();

  @override
  Future<void> logoutAll() => throw const UnexpectedFailure();

  @override
  Future<void> revokeSession(String sessionId) =>
      throw const UnexpectedFailure();

  static DomainFailure _failureFrom(DioException error) {
    final attached = error.error;
    if (attached is DomainFailure) return attached;
    final problem = ProblemParser.fromResponse(error.response);
    return problem == null
        ? const UnexpectedFailure()
        : FailureMapper.fromProblem(problem);
  }
}
