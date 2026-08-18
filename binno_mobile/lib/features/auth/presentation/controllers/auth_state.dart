import 'package:binno_app/features/auth/domain/auth_models.dart';

sealed class AuthState {
  const AuthState();
}

final class PhoneEntryState extends AuthState {
  const PhoneEntryState({this.submitting = false});
  final bool submitting;
}

final class OtpEntryState extends AuthState {
  const OtpEntryState({
    required this.challenge,
    required this.phone,
    this.submitting = false,
    this.attemptsLeft,
    this.error,
  });

  final OtpChallenge challenge;
  final String phone;
  final bool submitting;
  final int? attemptsLeft;
  final OtpError? error;
}

enum OtpError { invalid, expired, locked, rateLimited, unexpected }

final class RegistrationEntryState extends AuthState {
  const RegistrationEntryState({
    required this.registrationToken,
    this.submitting = false,
  });
  final String registrationToken;
  final bool submitting;
}

final class AuthenticatedState extends AuthState {
  const AuthenticatedState();
}
