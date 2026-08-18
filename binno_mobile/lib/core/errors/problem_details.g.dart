// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProblemDetailsImpl _$$ProblemDetailsImplFromJson(Map<String, dynamic> json) =>
    _$ProblemDetailsImpl(
      type: json['type'] as String,
      title: json['title'] as String?,
      status: (json['status'] as num?)?.toInt(),
      detail: json['detail'] as String?,
      retryAfter: (json['retry_after'] as num?)?.toInt(),
      attemptsLeft: (json['attempts_left'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ProblemDetailsImplToJson(
        _$ProblemDetailsImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'status': instance.status,
      'detail': instance.detail,
      'retry_after': instance.retryAfter,
      'attempts_left': instance.attemptsLeft,
    };
