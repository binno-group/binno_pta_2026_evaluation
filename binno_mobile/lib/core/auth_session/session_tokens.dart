import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_tokens.freezed.dart';

@freezed
class SessionTokens with _$SessionTokens {
  const factory SessionTokens({
    required String accessToken,
    required String refreshToken,
  }) = _SessionTokens;
}
