import 'package:binno_app/core/api/binno_interceptor.dart';
import 'package:dio/dio.dart';

abstract final class DioFactory {
  static Dio createBare(String baseUrl) {
    return Dio(BaseOptions(baseUrl: baseUrl));
  }

  static Dio create({
    required String baseUrl,
    required BinnoInterceptor interceptor,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.add(interceptor);
    interceptor.attach(dio);
    return dio;
  }
}
