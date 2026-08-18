import 'dart:typed_data';

import 'package:binno_app/core/api/auth_api.dart';
import 'package:binno_app/core/api/binno_interceptor.dart';
import 'package:binno_app/core/auth_session/auth_session.dart';
import 'package:binno_app/core/auth_session/session_storage.dart';
import 'package:binno_app/core/auth_session/session_tokens.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

final class _MemoryStorage implements SessionStorage {
  String? refreshToken;

  @override
  Future<void> clear() async => refreshToken = null;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> writeRefreshToken(String token) async => refreshToken = token;
}

final class _RefreshApi implements TokenRefreshApi {
  @override
  Future<SessionTokens> refresh(String refreshToken) async {
    return const SessionTokens(
      accessToken: 'rotated-access',
      refreshToken: 'rotated-refresh',
    );
  }
}

final class _CaptureAdapter implements HttpClientAdapter {
  RequestOptions? captured;
  bool reuseFailure = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    if (reuseFailure) {
      return ResponseBody.fromString(
        '{"type":"token_reuse_detected","status":403}',
        403,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('adds auth, trace and idempotency headers', () async {
    final storage = _MemoryStorage();
    final session = AuthSession(storage);
    await session.establish(
      const SessionTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
      ),
    );
    final adapter = _CaptureAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    dio.interceptors.add(
      BinnoInterceptor(
        session: session,
        storage: storage,
        refreshApi: _RefreshApi(),
      ),
    );

    await dio.post<Object?>('/mutation');

    expect(adapter.captured?.headers['Authorization'], 'Bearer access');
    expect(adapter.captured?.headers['X-Request-ID'], isNotEmpty);
    expect(adapter.captured?.headers['X-Trace-ID'], isNotEmpty);
    expect(adapter.captured?.headers['Idempotency-Key'], isNotEmpty);
  });

  test('token reuse wipes session and requests security logout', () async {
    final storage = _MemoryStorage();
    final session = AuthSession(storage);
    await session.establish(
      const SessionTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
      ),
    );
    final adapter = _CaptureAdapter()..reuseFailure = true;
    final dio = Dio()..httpClientAdapter = adapter;
    dio.interceptors.add(
      BinnoInterceptor(
        session: session,
        storage: storage,
        refreshApi: _RefreshApi(),
      ),
    );

    await expectLater(
      dio.get<Object?>('/protected'),
      throwsA(isA<DioException>()),
    );

    expect(session.accessToken, isNull);
    expect(session.status, AuthSessionStatus.securityLogout);
    expect(storage.refreshToken, isNull);
  });
}
