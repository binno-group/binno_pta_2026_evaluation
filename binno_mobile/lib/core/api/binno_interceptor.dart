import 'package:binno_app/core/api/auth_api.dart';
import 'package:binno_app/core/api/problem_parser.dart';
import 'package:binno_app/core/auth_session/auth_session.dart';
import 'package:binno_app/core/auth_session/session_storage.dart';
import 'package:binno_app/core/errors/domain_failure.dart';
import 'package:binno_app/core/errors/failure_mapper.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

final class BinnoInterceptor extends Interceptor {
  BinnoInterceptor({
    required AuthSession session,
    required SessionStorage storage,
    required TokenRefreshApi refreshApi,
    Uuid uuid = const Uuid(),
  })  : _session = session,
        _storage = storage,
        _refreshApi = refreshApi,
        _uuid = uuid;

  final AuthSession _session;
  final SessionStorage _storage;
  final TokenRefreshApi _refreshApi;
  final Uuid _uuid;
  Dio? _dio;

  void attach(Dio dio) {
    _dio = dio;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final accessToken = _session.accessToken;
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    options.headers['X-Request-ID'] ??= _uuid.v4();
    options.headers['X-Trace-ID'] ??= _uuid.v4();
    if (_isMutation(options.method)) {
      options.headers['Idempotency-Key'] ??= _uuid.v4();
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final problem = ProblemParser.fromResponse(err.response);
    final failure = problem == null
        ? const UnexpectedFailure()
        : FailureMapper.fromProblem(problem);
    if (failure is TokenReuseDetectedFailure) {
      await _session.clear(securityEvent: true);
    }
    if (err.response?.statusCode == 401 &&
        err.requestOptions.extra['binno_retried'] != true &&
        _dio != null) {
      try {
        await rotate();
        final options = err.requestOptions;
        options.extra['binno_retried'] = true;
        final accessToken = _session.accessToken;
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.resolve(await _dio!.fetch<Object?>(options));
        return;
      } on TokenReuseDetectedFailure {
        await _session.clear(securityEvent: true);
      }
    }
    handler.next(err.copyWith(error: failure));
  }

  Future<void> rotate() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null) {
      await _session.clear();
      return;
    }
    final tokens = await _refreshApi.refresh(refreshToken);
    await _session.establish(tokens);
  }

  static bool _isMutation(String method) {
    return const {'POST', 'PUT', 'PATCH', 'DELETE'}
        .contains(method.toUpperCase());
  }
}
