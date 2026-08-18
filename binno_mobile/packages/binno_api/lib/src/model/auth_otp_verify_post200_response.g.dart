// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_otp_verify_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthOtpVerifyPost200Response extends AuthOtpVerifyPost200Response {
  @override
  final OneOf oneOf;

  factory _$AuthOtpVerifyPost200Response(
          [void Function(AuthOtpVerifyPost200ResponseBuilder)? updates]) =>
      (AuthOtpVerifyPost200ResponseBuilder()..update(updates))._build();

  _$AuthOtpVerifyPost200Response._({required this.oneOf}) : super._();
  @override
  AuthOtpVerifyPost200Response rebuild(
          void Function(AuthOtpVerifyPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthOtpVerifyPost200ResponseBuilder toBuilder() =>
      AuthOtpVerifyPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthOtpVerifyPost200Response && oneOf == other.oneOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oneOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthOtpVerifyPost200Response')
          ..add('oneOf', oneOf))
        .toString();
  }
}

class AuthOtpVerifyPost200ResponseBuilder
    implements
        Builder<AuthOtpVerifyPost200Response,
            AuthOtpVerifyPost200ResponseBuilder> {
  _$AuthOtpVerifyPost200Response? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  AuthOtpVerifyPost200ResponseBuilder() {
    AuthOtpVerifyPost200Response._defaults(this);
  }

  AuthOtpVerifyPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthOtpVerifyPost200Response other) {
    _$v = other as _$AuthOtpVerifyPost200Response;
  }

  @override
  void update(void Function(AuthOtpVerifyPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthOtpVerifyPost200Response build() => _build();

  _$AuthOtpVerifyPost200Response _build() {
    final _$result = _$v ??
        _$AuthOtpVerifyPost200Response._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'AuthOtpVerifyPost200Response', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
