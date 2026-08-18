// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_otp_request_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthOtpRequestPost200Response extends AuthOtpRequestPost200Response {
  @override
  final String? requestId;
  @override
  final int? expiresIn;
  @override
  final int? retryAfter;

  factory _$AuthOtpRequestPost200Response(
          [void Function(AuthOtpRequestPost200ResponseBuilder)? updates]) =>
      (AuthOtpRequestPost200ResponseBuilder()..update(updates))._build();

  _$AuthOtpRequestPost200Response._(
      {this.requestId, this.expiresIn, this.retryAfter})
      : super._();
  @override
  AuthOtpRequestPost200Response rebuild(
          void Function(AuthOtpRequestPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthOtpRequestPost200ResponseBuilder toBuilder() =>
      AuthOtpRequestPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthOtpRequestPost200Response &&
        requestId == other.requestId &&
        expiresIn == other.expiresIn &&
        retryAfter == other.retryAfter;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, expiresIn.hashCode);
    _$hash = $jc(_$hash, retryAfter.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthOtpRequestPost200Response')
          ..add('requestId', requestId)
          ..add('expiresIn', expiresIn)
          ..add('retryAfter', retryAfter))
        .toString();
  }
}

class AuthOtpRequestPost200ResponseBuilder
    implements
        Builder<AuthOtpRequestPost200Response,
            AuthOtpRequestPost200ResponseBuilder> {
  _$AuthOtpRequestPost200Response? _$v;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  int? _expiresIn;
  int? get expiresIn => _$this._expiresIn;
  set expiresIn(int? expiresIn) => _$this._expiresIn = expiresIn;

  int? _retryAfter;
  int? get retryAfter => _$this._retryAfter;
  set retryAfter(int? retryAfter) => _$this._retryAfter = retryAfter;

  AuthOtpRequestPost200ResponseBuilder() {
    AuthOtpRequestPost200Response._defaults(this);
  }

  AuthOtpRequestPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requestId = $v.requestId;
      _expiresIn = $v.expiresIn;
      _retryAfter = $v.retryAfter;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthOtpRequestPost200Response other) {
    _$v = other as _$AuthOtpRequestPost200Response;
  }

  @override
  void update(void Function(AuthOtpRequestPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthOtpRequestPost200Response build() => _build();

  _$AuthOtpRequestPost200Response _build() {
    final _$result = _$v ??
        _$AuthOtpRequestPost200Response._(
          requestId: requestId,
          expiresIn: expiresIn,
          retryAfter: retryAfter,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
