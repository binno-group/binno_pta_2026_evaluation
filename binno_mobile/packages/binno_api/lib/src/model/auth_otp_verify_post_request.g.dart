// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_otp_verify_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthOtpVerifyPostRequest extends AuthOtpVerifyPostRequest {
  @override
  final String requestId;
  @override
  final String code;

  factory _$AuthOtpVerifyPostRequest(
          [void Function(AuthOtpVerifyPostRequestBuilder)? updates]) =>
      (AuthOtpVerifyPostRequestBuilder()..update(updates))._build();

  _$AuthOtpVerifyPostRequest._({required this.requestId, required this.code})
      : super._();
  @override
  AuthOtpVerifyPostRequest rebuild(
          void Function(AuthOtpVerifyPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthOtpVerifyPostRequestBuilder toBuilder() =>
      AuthOtpVerifyPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthOtpVerifyPostRequest &&
        requestId == other.requestId &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthOtpVerifyPostRequest')
          ..add('requestId', requestId)
          ..add('code', code))
        .toString();
  }
}

class AuthOtpVerifyPostRequestBuilder
    implements
        Builder<AuthOtpVerifyPostRequest, AuthOtpVerifyPostRequestBuilder> {
  _$AuthOtpVerifyPostRequest? _$v;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  AuthOtpVerifyPostRequestBuilder() {
    AuthOtpVerifyPostRequest._defaults(this);
  }

  AuthOtpVerifyPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requestId = $v.requestId;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthOtpVerifyPostRequest other) {
    _$v = other as _$AuthOtpVerifyPostRequest;
  }

  @override
  void update(void Function(AuthOtpVerifyPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthOtpVerifyPostRequest build() => _build();

  _$AuthOtpVerifyPostRequest _build() {
    final _$result = _$v ??
        _$AuthOtpVerifyPostRequest._(
          requestId: BuiltValueNullFieldError.checkNotNull(
              requestId, r'AuthOtpVerifyPostRequest', 'requestId'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'AuthOtpVerifyPostRequest', 'code'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
