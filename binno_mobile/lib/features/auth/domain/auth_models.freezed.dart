// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OtpChallenge {
  String get requestId => throw _privateConstructorUsedError;
  int get expiresIn => throw _privateConstructorUsedError;
  int get retryAfter => throw _privateConstructorUsedError;

  /// Create a copy of OtpChallenge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OtpChallengeCopyWith<OtpChallenge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OtpChallengeCopyWith<$Res> {
  factory $OtpChallengeCopyWith(
          OtpChallenge value, $Res Function(OtpChallenge) then) =
      _$OtpChallengeCopyWithImpl<$Res, OtpChallenge>;
  @useResult
  $Res call({String requestId, int expiresIn, int retryAfter});
}

/// @nodoc
class _$OtpChallengeCopyWithImpl<$Res, $Val extends OtpChallenge>
    implements $OtpChallengeCopyWith<$Res> {
  _$OtpChallengeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OtpChallenge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestId = null,
    Object? expiresIn = null,
    Object? retryAfter = null,
  }) {
    return _then(_value.copyWith(
      requestId: null == requestId
          ? _value.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      expiresIn: null == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int,
      retryAfter: null == retryAfter
          ? _value.retryAfter
          : retryAfter // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OtpChallengeImplCopyWith<$Res>
    implements $OtpChallengeCopyWith<$Res> {
  factory _$$OtpChallengeImplCopyWith(
          _$OtpChallengeImpl value, $Res Function(_$OtpChallengeImpl) then) =
      __$$OtpChallengeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String requestId, int expiresIn, int retryAfter});
}

/// @nodoc
class __$$OtpChallengeImplCopyWithImpl<$Res>
    extends _$OtpChallengeCopyWithImpl<$Res, _$OtpChallengeImpl>
    implements _$$OtpChallengeImplCopyWith<$Res> {
  __$$OtpChallengeImplCopyWithImpl(
      _$OtpChallengeImpl _value, $Res Function(_$OtpChallengeImpl) _then)
      : super(_value, _then);

  /// Create a copy of OtpChallenge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestId = null,
    Object? expiresIn = null,
    Object? retryAfter = null,
  }) {
    return _then(_$OtpChallengeImpl(
      requestId: null == requestId
          ? _value.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      expiresIn: null == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int,
      retryAfter: null == retryAfter
          ? _value.retryAfter
          : retryAfter // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$OtpChallengeImpl implements _OtpChallenge {
  const _$OtpChallengeImpl(
      {required this.requestId,
      required this.expiresIn,
      required this.retryAfter});

  @override
  final String requestId;
  @override
  final int expiresIn;
  @override
  final int retryAfter;

  @override
  String toString() {
    return 'OtpChallenge(requestId: $requestId, expiresIn: $expiresIn, retryAfter: $retryAfter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtpChallengeImpl &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.expiresIn, expiresIn) ||
                other.expiresIn == expiresIn) &&
            (identical(other.retryAfter, retryAfter) ||
                other.retryAfter == retryAfter));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, requestId, expiresIn, retryAfter);

  /// Create a copy of OtpChallenge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OtpChallengeImplCopyWith<_$OtpChallengeImpl> get copyWith =>
      __$$OtpChallengeImplCopyWithImpl<_$OtpChallengeImpl>(this, _$identity);
}

abstract class _OtpChallenge implements OtpChallenge {
  const factory _OtpChallenge(
      {required final String requestId,
      required final int expiresIn,
      required final int retryAfter}) = _$OtpChallengeImpl;

  @override
  String get requestId;
  @override
  int get expiresIn;
  @override
  int get retryAfter;

  /// Create a copy of OtpChallenge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OtpChallengeImplCopyWith<_$OtpChallengeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$OtpVerification {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(SessionTokens tokens) authenticated,
    required TResult Function(String registrationToken) registrationRequired,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(SessionTokens tokens)? authenticated,
    TResult? Function(String registrationToken)? registrationRequired,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(SessionTokens tokens)? authenticated,
    TResult Function(String registrationToken)? registrationRequired,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthenticatedOtpVerification value) authenticated,
    required TResult Function(RegistrationRequiredOtpVerification value)
        registrationRequired,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthenticatedOtpVerification value)? authenticated,
    TResult? Function(RegistrationRequiredOtpVerification value)?
        registrationRequired,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthenticatedOtpVerification value)? authenticated,
    TResult Function(RegistrationRequiredOtpVerification value)?
        registrationRequired,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OtpVerificationCopyWith<$Res> {
  factory $OtpVerificationCopyWith(
          OtpVerification value, $Res Function(OtpVerification) then) =
      _$OtpVerificationCopyWithImpl<$Res, OtpVerification>;
}

/// @nodoc
class _$OtpVerificationCopyWithImpl<$Res, $Val extends OtpVerification>
    implements $OtpVerificationCopyWith<$Res> {
  _$OtpVerificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OtpVerification
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AuthenticatedOtpVerificationImplCopyWith<$Res> {
  factory _$$AuthenticatedOtpVerificationImplCopyWith(
          _$AuthenticatedOtpVerificationImpl value,
          $Res Function(_$AuthenticatedOtpVerificationImpl) then) =
      __$$AuthenticatedOtpVerificationImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SessionTokens tokens});

  $SessionTokensCopyWith<$Res> get tokens;
}

/// @nodoc
class __$$AuthenticatedOtpVerificationImplCopyWithImpl<$Res>
    extends _$OtpVerificationCopyWithImpl<$Res,
        _$AuthenticatedOtpVerificationImpl>
    implements _$$AuthenticatedOtpVerificationImplCopyWith<$Res> {
  __$$AuthenticatedOtpVerificationImplCopyWithImpl(
      _$AuthenticatedOtpVerificationImpl _value,
      $Res Function(_$AuthenticatedOtpVerificationImpl) _then)
      : super(_value, _then);

  /// Create a copy of OtpVerification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tokens = null,
  }) {
    return _then(_$AuthenticatedOtpVerificationImpl(
      null == tokens
          ? _value.tokens
          : tokens // ignore: cast_nullable_to_non_nullable
              as SessionTokens,
    ));
  }

  /// Create a copy of OtpVerification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionTokensCopyWith<$Res> get tokens {
    return $SessionTokensCopyWith<$Res>(_value.tokens, (value) {
      return _then(_value.copyWith(tokens: value));
    });
  }
}

/// @nodoc

class _$AuthenticatedOtpVerificationImpl
    implements AuthenticatedOtpVerification {
  const _$AuthenticatedOtpVerificationImpl(this.tokens);

  @override
  final SessionTokens tokens;

  @override
  String toString() {
    return 'OtpVerification.authenticated(tokens: $tokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthenticatedOtpVerificationImpl &&
            (identical(other.tokens, tokens) || other.tokens == tokens));
  }

  @override
  int get hashCode => Object.hash(runtimeType, tokens);

  /// Create a copy of OtpVerification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthenticatedOtpVerificationImplCopyWith<
          _$AuthenticatedOtpVerificationImpl>
      get copyWith => __$$AuthenticatedOtpVerificationImplCopyWithImpl<
          _$AuthenticatedOtpVerificationImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(SessionTokens tokens) authenticated,
    required TResult Function(String registrationToken) registrationRequired,
  }) {
    return authenticated(tokens);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(SessionTokens tokens)? authenticated,
    TResult? Function(String registrationToken)? registrationRequired,
  }) {
    return authenticated?.call(tokens);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(SessionTokens tokens)? authenticated,
    TResult Function(String registrationToken)? registrationRequired,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(tokens);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthenticatedOtpVerification value) authenticated,
    required TResult Function(RegistrationRequiredOtpVerification value)
        registrationRequired,
  }) {
    return authenticated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthenticatedOtpVerification value)? authenticated,
    TResult? Function(RegistrationRequiredOtpVerification value)?
        registrationRequired,
  }) {
    return authenticated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthenticatedOtpVerification value)? authenticated,
    TResult Function(RegistrationRequiredOtpVerification value)?
        registrationRequired,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(this);
    }
    return orElse();
  }
}

abstract class AuthenticatedOtpVerification implements OtpVerification {
  const factory AuthenticatedOtpVerification(final SessionTokens tokens) =
      _$AuthenticatedOtpVerificationImpl;

  SessionTokens get tokens;

  /// Create a copy of OtpVerification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthenticatedOtpVerificationImplCopyWith<
          _$AuthenticatedOtpVerificationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RegistrationRequiredOtpVerificationImplCopyWith<$Res> {
  factory _$$RegistrationRequiredOtpVerificationImplCopyWith(
          _$RegistrationRequiredOtpVerificationImpl value,
          $Res Function(_$RegistrationRequiredOtpVerificationImpl) then) =
      __$$RegistrationRequiredOtpVerificationImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String registrationToken});
}

/// @nodoc
class __$$RegistrationRequiredOtpVerificationImplCopyWithImpl<$Res>
    extends _$OtpVerificationCopyWithImpl<$Res,
        _$RegistrationRequiredOtpVerificationImpl>
    implements _$$RegistrationRequiredOtpVerificationImplCopyWith<$Res> {
  __$$RegistrationRequiredOtpVerificationImplCopyWithImpl(
      _$RegistrationRequiredOtpVerificationImpl _value,
      $Res Function(_$RegistrationRequiredOtpVerificationImpl) _then)
      : super(_value, _then);

  /// Create a copy of OtpVerification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? registrationToken = null,
  }) {
    return _then(_$RegistrationRequiredOtpVerificationImpl(
      null == registrationToken
          ? _value.registrationToken
          : registrationToken // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RegistrationRequiredOtpVerificationImpl
    implements RegistrationRequiredOtpVerification {
  const _$RegistrationRequiredOtpVerificationImpl(this.registrationToken);

  @override
  final String registrationToken;

  @override
  String toString() {
    return 'OtpVerification.registrationRequired(registrationToken: $registrationToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegistrationRequiredOtpVerificationImpl &&
            (identical(other.registrationToken, registrationToken) ||
                other.registrationToken == registrationToken));
  }

  @override
  int get hashCode => Object.hash(runtimeType, registrationToken);

  /// Create a copy of OtpVerification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegistrationRequiredOtpVerificationImplCopyWith<
          _$RegistrationRequiredOtpVerificationImpl>
      get copyWith => __$$RegistrationRequiredOtpVerificationImplCopyWithImpl<
          _$RegistrationRequiredOtpVerificationImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(SessionTokens tokens) authenticated,
    required TResult Function(String registrationToken) registrationRequired,
  }) {
    return registrationRequired(registrationToken);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(SessionTokens tokens)? authenticated,
    TResult? Function(String registrationToken)? registrationRequired,
  }) {
    return registrationRequired?.call(registrationToken);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(SessionTokens tokens)? authenticated,
    TResult Function(String registrationToken)? registrationRequired,
    required TResult orElse(),
  }) {
    if (registrationRequired != null) {
      return registrationRequired(registrationToken);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthenticatedOtpVerification value) authenticated,
    required TResult Function(RegistrationRequiredOtpVerification value)
        registrationRequired,
  }) {
    return registrationRequired(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthenticatedOtpVerification value)? authenticated,
    TResult? Function(RegistrationRequiredOtpVerification value)?
        registrationRequired,
  }) {
    return registrationRequired?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthenticatedOtpVerification value)? authenticated,
    TResult Function(RegistrationRequiredOtpVerification value)?
        registrationRequired,
    required TResult orElse(),
  }) {
    if (registrationRequired != null) {
      return registrationRequired(this);
    }
    return orElse();
  }
}

abstract class RegistrationRequiredOtpVerification implements OtpVerification {
  const factory RegistrationRequiredOtpVerification(
          final String registrationToken) =
      _$RegistrationRequiredOtpVerificationImpl;

  String get registrationToken;

  /// Create a copy of OtpVerification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegistrationRequiredOtpVerificationImplCopyWith<
          _$RegistrationRequiredOtpVerificationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ActiveSession {
  String get id => throw _privateConstructorUsedError;
  String get deviceLabel => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get lastUsedAt => throw _privateConstructorUsedError;
  bool get isCurrent => throw _privateConstructorUsedError;

  /// Create a copy of ActiveSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActiveSessionCopyWith<ActiveSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActiveSessionCopyWith<$Res> {
  factory $ActiveSessionCopyWith(
          ActiveSession value, $Res Function(ActiveSession) then) =
      _$ActiveSessionCopyWithImpl<$Res, ActiveSession>;
  @useResult
  $Res call(
      {String id,
      String deviceLabel,
      DateTime createdAt,
      DateTime lastUsedAt,
      bool isCurrent});
}

/// @nodoc
class _$ActiveSessionCopyWithImpl<$Res, $Val extends ActiveSession>
    implements $ActiveSessionCopyWith<$Res> {
  _$ActiveSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActiveSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceLabel = null,
    Object? createdAt = null,
    Object? lastUsedAt = null,
    Object? isCurrent = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deviceLabel: null == deviceLabel
          ? _value.deviceLabel
          : deviceLabel // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUsedAt: null == lastUsedAt
          ? _value.lastUsedAt
          : lastUsedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCurrent: null == isCurrent
          ? _value.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActiveSessionImplCopyWith<$Res>
    implements $ActiveSessionCopyWith<$Res> {
  factory _$$ActiveSessionImplCopyWith(
          _$ActiveSessionImpl value, $Res Function(_$ActiveSessionImpl) then) =
      __$$ActiveSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String deviceLabel,
      DateTime createdAt,
      DateTime lastUsedAt,
      bool isCurrent});
}

/// @nodoc
class __$$ActiveSessionImplCopyWithImpl<$Res>
    extends _$ActiveSessionCopyWithImpl<$Res, _$ActiveSessionImpl>
    implements _$$ActiveSessionImplCopyWith<$Res> {
  __$$ActiveSessionImplCopyWithImpl(
      _$ActiveSessionImpl _value, $Res Function(_$ActiveSessionImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActiveSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceLabel = null,
    Object? createdAt = null,
    Object? lastUsedAt = null,
    Object? isCurrent = null,
  }) {
    return _then(_$ActiveSessionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deviceLabel: null == deviceLabel
          ? _value.deviceLabel
          : deviceLabel // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUsedAt: null == lastUsedAt
          ? _value.lastUsedAt
          : lastUsedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCurrent: null == isCurrent
          ? _value.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ActiveSessionImpl implements _ActiveSession {
  const _$ActiveSessionImpl(
      {required this.id,
      required this.deviceLabel,
      required this.createdAt,
      required this.lastUsedAt,
      required this.isCurrent});

  @override
  final String id;
  @override
  final String deviceLabel;
  @override
  final DateTime createdAt;
  @override
  final DateTime lastUsedAt;
  @override
  final bool isCurrent;

  @override
  String toString() {
    return 'ActiveSession(id: $id, deviceLabel: $deviceLabel, createdAt: $createdAt, lastUsedAt: $lastUsedAt, isCurrent: $isCurrent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActiveSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deviceLabel, deviceLabel) ||
                other.deviceLabel == deviceLabel) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastUsedAt, lastUsedAt) ||
                other.lastUsedAt == lastUsedAt) &&
            (identical(other.isCurrent, isCurrent) ||
                other.isCurrent == isCurrent));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, deviceLabel, createdAt, lastUsedAt, isCurrent);

  /// Create a copy of ActiveSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActiveSessionImplCopyWith<_$ActiveSessionImpl> get copyWith =>
      __$$ActiveSessionImplCopyWithImpl<_$ActiveSessionImpl>(this, _$identity);
}

abstract class _ActiveSession implements ActiveSession {
  const factory _ActiveSession(
      {required final String id,
      required final String deviceLabel,
      required final DateTime createdAt,
      required final DateTime lastUsedAt,
      required final bool isCurrent}) = _$ActiveSessionImpl;

  @override
  String get id;
  @override
  String get deviceLabel;
  @override
  DateTime get createdAt;
  @override
  DateTime get lastUsedAt;
  @override
  bool get isCurrent;

  /// Create a copy of ActiveSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActiveSessionImplCopyWith<_$ActiveSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
