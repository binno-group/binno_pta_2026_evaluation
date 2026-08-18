import 'package:binno_app/core/auth_session/auth_session.dart';
import 'package:binno_app/core/errors/domain_failure.dart';
import 'package:binno_app/features/auth/domain/auth_models.dart';
import 'package:binno_app/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:binno_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class AuthController extends StateNotifier<AuthState> {
  AuthController(this._useCases, this._session)
      : super(const PhoneEntryState());

  final AuthUseCases _useCases;
  final AuthSession _session;
  bool _mutationInFlight = false;

  Future<bool> requestOtp(String rawPhone) async {
    if (_mutationInFlight) return false;
    _mutationInFlight = true;
    state = const PhoneEntryState(submitting: true);
    try {
      final requested = await _useCases.requestLoginOtp(rawPhone);
      if (requested == null) {
        state = const PhoneEntryState();
        return false;
      }
      state = OtpEntryState(
        challenge: requested.challenge,
        phone: requested.phone,
      );
      return true;
    } on RateLimitedFailure catch (failure) {
      state = OtpEntryState(
        challenge: OtpChallenge(
          requestId: '',
          expiresIn: 0,
          retryAfter: failure.retryAfter,
        ),
        phone: rawPhone,
        error: OtpError.rateLimited,
      );
      return false;
    } finally {
      _mutationInFlight = false;
    }
  }

  Future<bool> verifyOtp(String code) async {
    final current = state;
    if (current is! OtpEntryState ||
        _mutationInFlight ||
        !_useCases.isValidOtpCode(code)) {
      return false;
    }
    _mutationInFlight = true;
    state = OtpEntryState(
      challenge: current.challenge,
      phone: current.phone,
      submitting: true,
      attemptsLeft: current.attemptsLeft,
    );
    try {
      final result = await _useCases.verifyOtp(
        current.challenge.requestId,
        code,
      );
      switch (result) {
        case AuthenticatedOtpVerification(:final tokens):
          await _session.establish(tokens);
          state = const AuthenticatedState();
        case RegistrationRequiredOtpVerification(:final registrationToken):
          state = RegistrationEntryState(
            registrationToken: registrationToken,
          );
      }
      return true;
    } on InvalidCodeFailure catch (failure) {
      state = OtpEntryState(
        challenge: current.challenge,
        phone: current.phone,
        attemptsLeft: failure.attemptsLeft,
        error: failure.attemptsLeft == 0 ? OtpError.locked : OtpError.invalid,
      );
      return false;
    } on ExpiredFailure {
      state = OtpEntryState(
        challenge: current.challenge,
        phone: current.phone,
        error: OtpError.expired,
      );
      return false;
    } on RateLimitedFailure {
      state = OtpEntryState(
        challenge: current.challenge,
        phone: current.phone,
        error: OtpError.rateLimited,
      );
      return false;
    } finally {
      _mutationInFlight = false;
    }
  }

  Future<void> completeRegistration(String name, String region) async {
    final current = state;
    if (current is! RegistrationEntryState || _mutationInFlight) return;
    _mutationInFlight = true;
    state = RegistrationEntryState(
      registrationToken: current.registrationToken,
      submitting: true,
    );
    try {
      await _useCases.completeRegistration(
        registrationToken: current.registrationToken,
        name: name,
        region: region,
      );
      state = const AuthenticatedState();
    } finally {
      _mutationInFlight = false;
    }
  }
}
