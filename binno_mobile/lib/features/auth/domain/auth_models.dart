import 'package:binno_app/core/auth_session/session_tokens.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';

enum OtpPurpose { register, login }

@freezed
class OtpChallenge with _$OtpChallenge {
  const factory OtpChallenge({
    required String requestId,
    required int expiresIn,
    required int retryAfter,
  }) = _OtpChallenge;
}

@freezed
class OtpVerification with _$OtpVerification {
  const factory OtpVerification.authenticated(SessionTokens tokens) =
      AuthenticatedOtpVerification;
  const factory OtpVerification.registrationRequired(
    String registrationToken,
  ) = RegistrationRequiredOtpVerification;
}

@freezed
class ActiveSession with _$ActiveSession {
  const factory ActiveSession({
    required String id,
    required String deviceLabel,
    required DateTime createdAt,
    required DateTime lastUsedAt,
    required bool isCurrent,
  }) = _ActiveSession;
}
