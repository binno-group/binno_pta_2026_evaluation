import 'package:binno_app/core/errors/problem_details.dart';
import 'package:dio/dio.dart';

abstract final class ProblemParser {
  static ProblemDetails? fromResponse(Response<Object?>? response) {
    final data = response?.data;
    if (data is! Map) {
      return null;
    }
    return ProblemDetails.fromJson(
      data.map((key, value) => MapEntry(key.toString(), value)),
    );
  }
}
