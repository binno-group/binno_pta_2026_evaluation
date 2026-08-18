// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_otp_verify_post200_response_one_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthOtpVerifyPost200ResponseOneOf
    extends AuthOtpVerifyPost200ResponseOneOf {
  @override
  final String? registrationToken;

  factory _$AuthOtpVerifyPost200ResponseOneOf(
          [void Function(AuthOtpVerifyPost200ResponseOneOfBuilder)? updates]) =>
      (AuthOtpVerifyPost200ResponseOneOfBuilder()..update(updates))._build();

  _$AuthOtpVerifyPost200ResponseOneOf._({this.registrationToken}) : super._();
  @override
  AuthOtpVerifyPost200ResponseOneOf rebuild(
          void Function(AuthOtpVerifyPost200ResponseOneOfBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthOtpVerifyPost200ResponseOneOfBuilder toBuilder() =>
      AuthOtpVerifyPost200ResponseOneOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthOtpVerifyPost200ResponseOneOf &&
        registrationToken == other.registrationToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, registrationToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthOtpVerifyPost200ResponseOneOf')
          ..add('registrationToken', registrationToken))
        .toString();
  }
}

class AuthOtpVerifyPost200ResponseOneOfBuilder
    implements
        Builder<AuthOtpVerifyPost200ResponseOneOf,
            AuthOtpVerifyPost200ResponseOneOfBuilder> {
  _$AuthOtpVerifyPost200ResponseOneOf? _$v;

  String? _registrationToken;
  String? get registrationToken => _$this._registrationToken;
  set registrationToken(String? registrationToken) =>
      _$this._registrationToken = registrationToken;

  AuthOtpVerifyPost200ResponseOneOfBuilder() {
    AuthOtpVerifyPost200ResponseOneOf._defaults(this);
  }

  AuthOtpVerifyPost200ResponseOneOfBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _registrationToken = $v.registrationToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthOtpVerifyPost200ResponseOneOf other) {
    _$v = other as _$AuthOtpVerifyPost200ResponseOneOf;
  }

  @override
  void update(
      void Function(AuthOtpVerifyPost200ResponseOneOfBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthOtpVerifyPost200ResponseOneOf build() => _build();

  _$AuthOtpVerifyPost200ResponseOneOf _build() {
    final _$result = _$v ??
        _$AuthOtpVerifyPost200ResponseOneOf._(
          registrationToken: registrationToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
