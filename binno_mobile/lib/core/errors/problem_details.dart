import 'package:freezed_annotation/freezed_annotation.dart';

part 'problem_details.freezed.dart';
part 'problem_details.g.dart';

@freezed
class ProblemDetails with _$ProblemDetails {
  const factory ProblemDetails({
    required String type,
    String? title,
    int? status,
    String? detail,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'retry_after') int? retryAfter,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'attempts_left') int? attemptsLeft,
  }) = _ProblemDetails;

  factory ProblemDetails.fromJson(Map<String, Object?> json) =>
      _$ProblemDetailsFromJson(json);
}
