import 'package:test/test.dart';
import 'package:binno_api/binno_api.dart';

/// tests for AuthApi
void main() {
  final instance = BinnoApi().getAuthApi();

  group(AuthApi, () {
    // Request an OTP (BR-01.2, BR-01.3)
    //
    //Future<AuthOtpRequestPost200Response> authOtpRequestPost(AuthOtpRequestPostRequest authOtpRequestPostRequest) async
    test('test authOtpRequestPost', () async {
      // TODO
    });

    // Verify an OTP (BR-01.4)
    //
    //Future<AuthOtpVerifyPost200Response> authOtpVerifyPost(AuthOtpVerifyPostRequest authOtpVerifyPostRequest) async
    test('test authOtpVerifyPost', () async {
      // TODO
    });

    // Refresh tokens — rotation is mandatory (BR-02.3)
    //
    //Future<TokenPair> authRefreshPost(AuthRefreshPostRequest authRefreshPostRequest) async
    test('test authRefreshPost', () async {
      // TODO
    });
  });
}
