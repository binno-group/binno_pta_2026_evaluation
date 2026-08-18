import 'package:binno_api/binno_api.dart' as api;

import 'package:binno_app/core/api/auth_api.dart';
import 'package:binno_app/core/api/problem_parser.dart';
import 'package:binno_app/core/auth_session/session_tokens.dart';
import 'package:binno_app/core/errors/domain_failure.dart';
import 'package:binno_app/core/errors/failure_mapper.dart';
import 'package:dio/dio.dart';

final class GeneratedTokenRefreshApi implements TokenRefreshApi {
  const GeneratedTokenRefreshApi(this._api);

  final api.AuthApi _api;

  @override
  Future<SessionTokens> refresh(String refreshToken) async {
    try {
      final response = await _api.authRefreshPost(
        authRefreshPostRequest: api.AuthRefreshPostRequest(
          (builder) => builder.refreshToken = refreshToken,
        ),
      );
      final data = response.data;
      if (data?.accessToken == null || data?.refreshToken == null) {
        throw const UnexpectedFailure();
      }
      return SessionTokens(
        accessToken: data!.accessToken!,
        refreshToken: data.refreshToken!,
      );
    } on DioException catch (error) {
      final problem = ProblemParser.fromResponse(error.response);
      throw problem == null
          ? const UnexpectedFailure()
          : FailureMapper.fromProblem(problem);
    }
  }
}
