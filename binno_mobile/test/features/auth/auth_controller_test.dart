import 'dart:async';

import 'package:binno_app/core/auth_session/auth_session.dart';
import 'package:binno_app/core/auth_session/session_tokens.dart';
import 'package:binno_app/core/errors/domain_failure.dart';
import 'package:binno_app/features/auth/domain/auth_models.dart';
import 'package:binno_app/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:binno_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:binno_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  late FakeAuthRepository repository;
  late AuthController controller;

  setUp(() {
    repository = FakeAuthRepository();
    controller = AuthController(
      AuthUseCases(repository),
      AuthSession(MemorySessionStorage()),
    );
  });

  test('normalizes phone and opens OTP state', () async {
    expect(await controller.requestOtp('90 123 45 67'), isTrue);
    expect(controller.state, isA<OtpEntryState>());
  });

  test('rejects malformed phone without a request', () async {
    expect(await controller.requestOtp('12'), isFalse);
    expect(controller.state, isA<PhoneEntryState>());
  });

  test('invalid code exposes attempts left', () async {
    await controller.requestOtp('901234567');
    repository.verifyError = const InvalidCodeFailure(3);
    expect(await controller.verifyOtp('111111'), isFalse);
    final state = controller.state as OtpEntryState;
    expect(state.error, OtpError.invalid);
    expect(state.attemptsLeft, 3);
  });

  test('fifth invalid code enters lock state', () async {
    await controller.requestOtp('901234567');
    repository.verifyError = const InvalidCodeFailure(0);
    await controller.verifyOtp('111111');
    expect((controller.state as OtpEntryState).error, OtpError.locked);
  });

  test('410 expired remains recoverable', () async {
    await controller.requestOtp('901234567');
    repository.verifyError = const ExpiredFailure();
    await controller.verifyOtp('111111');
    expect((controller.state as OtpEntryState).error, OtpError.expired);
  });

  test('429 rate limit uses server retry_after', () async {
    repository.requestError = const RateLimitedFailure(45);
    await controller.requestOtp('901234567');
    final state = controller.state as OtpEntryState;
    expect(state.error, OtpError.rateLimited);
    expect(state.challenge.retryAfter, 45);
  });

  test('does not publish success before repository acknowledgement', () async {
    await controller.requestOtp('901234567');
    repository.verificationCompleter = Completer<OtpVerification>();
    final future = controller.verifyOtp('111111');
    expect((controller.state as OtpEntryState).submitting, isTrue);
    repository.verificationCompleter!.complete(
      const OtpVerification.registrationRequired('token'),
    );
    await future;
    expect(controller.state, isA<RegistrationEntryState>());
  });

  test('authenticated verification establishes session', () async {
    await controller.requestOtp('901234567');
    repository.verification = const OtpVerification.authenticated(
      SessionTokens(accessToken: 'access', refreshToken: 'refresh'),
    );
    expect(await controller.verifyOtp('123456'), isTrue);
    expect(controller.state, isA<AuthenticatedState>());
  });

  test('registration completes only from registration state', () async {
    await controller.completeRegistration('Name', 'Region');
    expect(controller.state, isA<PhoneEntryState>());
    await controller.requestOtp('901234567');
    await controller.verifyOtp('123456');
    await controller.completeRegistration('Name', 'Region');
    expect(controller.state, isA<AuthenticatedState>());
  });
}
