import 'package:binno_app/features/auth/domain/auth_models.dart';
import 'package:binno_app/features/auth/domain/auth_repository.dart';
import 'package:binno_app/features/auth/domain/phone_number.dart';

final class RequestedOtp {
  const RequestedOtp({required this.phone, required this.challenge});

  final String phone;
  final OtpChallenge challenge;
}

final class AuthUseCases {
  const AuthUseCases(this._repository);

  final AuthRepository _repository;

  Future<RequestedOtp?> requestLoginOtp(String rawPhone) async {
    final phone = UzbekistanPhoneNumber.parse(rawPhone);
    if (phone == null) return null;
    final challenge =
        await _repository.requestOtp(phone.e164, OtpPurpose.login);
    return RequestedOtp(phone: phone.e164, challenge: challenge);
  }

  bool isValidOtpCode(String code) => RegExp(r'^\d{6}$').hasMatch(code);

  Future<OtpVerification> verifyOtp(String requestId, String code) =>
      _repository.verifyOtp(requestId, code);

  Future<void> completeRegistration({
    required String registrationToken,
    required String name,
    required String region,
  }) =>
      _repository.completeRegistration(
        registrationToken: registrationToken,
        name: name,
        region: region,
      );

  Future<List<ActiveSession>> getSessions() => _repository.getSessions();

  Future<void> revokeSession(String sessionId) =>
      _repository.revokeSession(sessionId);

  Future<void> logoutAll() => _repository.logoutAll();
}
