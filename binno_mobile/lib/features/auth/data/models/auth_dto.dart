import 'package:binno_app/core/auth_session/session_tokens.dart';

final class OtpChallengeDto {
  const OtpChallengeDto({
    required this.requestId,
    required this.expiresIn,
    required this.retryAfter,
  });

  final String requestId;
  final int expiresIn;
  final int retryAfter;
}

sealed class OtpVerificationDto {
  const OtpVerificationDto();
}

final class AuthenticatedOtpVerificationDto extends OtpVerificationDto {
  const AuthenticatedOtpVerificationDto(this.tokens);

  final SessionTokens tokens;
}

final class RegistrationRequiredOtpVerificationDto extends OtpVerificationDto {
  const RegistrationRequiredOtpVerificationDto(this.registrationToken);

  final String registrationToken;
}

final class ActiveSessionDto {
  const ActiveSessionDto({
    required this.id,
    required this.deviceLabel,
    required this.createdAt,
    required this.lastUsedAt,
    required this.isCurrent,
  });

  final String id;
  final String deviceLabel;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  final bool isCurrent;
}
