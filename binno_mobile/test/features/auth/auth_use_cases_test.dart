import 'package:binno_app/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('normalizes Uzbekistan phone before repository access', () async {
    final result = await AuthUseCases(
      FakeAuthRepository(),
    ).requestLoginOtp('90 123 45 67');

    expect(result?.phone, '+998901234567');
  });

  test('rejects malformed phone in the domain use case', () async {
    final result = await AuthUseCases(
      FakeAuthRepository(),
    ).requestLoginOtp('12');

    expect(result, isNull);
  });

  test('validates six digit OTP in the domain use case', () {
    final useCases = AuthUseCases(FakeAuthRepository());

    expect(useCases.isValidOtpCode('123456'), isTrue);
    expect(useCases.isValidOtpCode('12345a'), isFalse);
  });
}
