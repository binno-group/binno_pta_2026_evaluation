// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'problem_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProblemDetails _$ProblemDetailsFromJson(Map<String, dynamic> json) {
  return _ProblemDetails.fromJson(json);
}

/// @nodoc
mixin _$ProblemDetails {
  String get type => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  int? get status => throw _privateConstructorUsedError;
  String? get detail => throw _privateConstructorUsedError;
  @JsonKey(name: 'retry_after')
  int? get retryAfter => throw _privateConstructorUsedError;
  @JsonKey(name: 'attempts_left')
  int? get attemptsLeft => throw _privateConstructorUsedError;

  /// Serializes this ProblemDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProblemDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProblemDetailsCopyWith<ProblemDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProblemDetailsCopyWith<$Res> {
  factory $ProblemDetailsCopyWith(
          ProblemDetails value, $Res Function(ProblemDetails) then) =
      _$ProblemDetailsCopyWithImpl<$Res, ProblemDetails>;
  @useResult
  $Res call(
      {String type,
      String? title,
      int? status,
      String? detail,
      @JsonKey(name: 'retry_after') int? retryAfter,
      @JsonKey(name: 'attempts_left') int? attemptsLeft});
}

/// @nodoc
class _$ProblemDetailsCopyWithImpl<$Res, $Val extends ProblemDetails>
    implements $ProblemDetailsCopyWith<$Res> {
  _$ProblemDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProblemDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = freezed,
    Object? status = freezed,
    Object? detail = freezed,
    Object? retryAfter = freezed,
    Object? attemptsLeft = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int?,
      detail: freezed == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as String?,
      retryAfter: freezed == retryAfter
          ? _value.retryAfter
          : retryAfter // ignore: cast_nullable_to_non_nullable
              as int?,
      attemptsLeft: freezed == attemptsLeft
          ? _value.attemptsLeft
          : attemptsLeft // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProblemDetailsImplCopyWith<$Res>
    implements $ProblemDetailsCopyWith<$Res> {
  factory _$$ProblemDetailsImplCopyWith(_$ProblemDetailsImpl value,
          $Res Function(_$ProblemDetailsImpl) then) =
      __$$ProblemDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String type,
      String? title,
      int? status,
      String? detail,
      @JsonKey(name: 'retry_after') int? retryAfter,
      @JsonKey(name: 'attempts_left') int? attemptsLeft});
}

/// @nodoc
class __$$ProblemDetailsImplCopyWithImpl<$Res>
    extends _$ProblemDetailsCopyWithImpl<$Res, _$ProblemDetailsImpl>
    implements _$$ProblemDetailsImplCopyWith<$Res> {
  __$$ProblemDetailsImplCopyWithImpl(
      _$ProblemDetailsImpl _value, $Res Function(_$ProblemDetailsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProblemDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = freezed,
    Object? status = freezed,
    Object? detail = freezed,
    Object? retryAfter = freezed,
    Object? attemptsLeft = freezed,
  }) {
    return _then(_$ProblemDetailsImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int?,
      detail: freezed == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as String?,
      retryAfter: freezed == retryAfter
          ? _value.retryAfter
          : retryAfter // ignore: cast_nullable_to_non_nullable
              as int?,
      attemptsLeft: freezed == attemptsLeft
          ? _value.attemptsLeft
          : attemptsLeft // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProblemDetailsImpl implements _ProblemDetails {
  const _$ProblemDetailsImpl(
      {required this.type,
      this.title,
      this.status,
      this.detail,
      @JsonKey(name: 'retry_after') this.retryAfter,
      @JsonKey(name: 'attempts_left') this.attemptsLeft});

  factory _$ProblemDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProblemDetailsImplFromJson(json);

  @override
  final String type;
  @override
  final String? title;
  @override
  final int? status;
  @override
  final String? detail;
  @override
  @JsonKey(name: 'retry_after')
  final int? retryAfter;
  @override
  @JsonKey(name: 'attempts_left')
  final int? attemptsLeft;

  @override
  String toString() {
    return 'ProblemDetails(type: $type, title: $title, status: $status, detail: $detail, retryAfter: $retryAfter, attemptsLeft: $attemptsLeft)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProblemDetailsImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.detail, detail) || other.detail == detail) &&
            (identical(other.retryAfter, retryAfter) ||
                other.retryAfter == retryAfter) &&
            (identical(other.attemptsLeft, attemptsLeft) ||
                other.attemptsLeft == attemptsLeft));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, type, title, status, detail, retryAfter, attemptsLeft);

  /// Create a copy of ProblemDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProblemDetailsImplCopyWith<_$ProblemDetailsImpl> get copyWith =>
      __$$ProblemDetailsImplCopyWithImpl<_$ProblemDetailsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProblemDetailsImplToJson(
      this,
    );
  }
}

abstract class _ProblemDetails implements ProblemDetails {
  const factory _ProblemDetails(
          {required final String type,
          final String? title,
          final int? status,
          final String? detail,
          @JsonKey(name: 'retry_after') final int? retryAfter,
          @JsonKey(name: 'attempts_left') final int? attemptsLeft}) =
      _$ProblemDetailsImpl;

  factory _ProblemDetails.fromJson(Map<String, dynamic> json) =
      _$ProblemDetailsImpl.fromJson;

  @override
  String get type;
  @override
  String? get title;
  @override
  int? get status;
  @override
  String? get detail;
  @override
  @JsonKey(name: 'retry_after')
  int? get retryAfter;
  @override
  @JsonKey(name: 'attempts_left')
  int? get attemptsLeft;

  /// Create a copy of ProblemDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProblemDetailsImplCopyWith<_$ProblemDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
