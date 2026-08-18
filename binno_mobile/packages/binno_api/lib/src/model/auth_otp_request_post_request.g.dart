// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_otp_request_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthOtpRequestPostRequestPurposeEnum
    _$authOtpRequestPostRequestPurposeEnum_register =
    const AuthOtpRequestPostRequestPurposeEnum._('register');
const AuthOtpRequestPostRequestPurposeEnum
    _$authOtpRequestPostRequestPurposeEnum_login =
    const AuthOtpRequestPostRequestPurposeEnum._('login');

AuthOtpRequestPostRequestPurposeEnum
    _$authOtpRequestPostRequestPurposeEnumValueOf(String name) {
  switch (name) {
    case 'register':
      return _$authOtpRequestPostRequestPurposeEnum_register;
    case 'login':
      return _$authOtpRequestPostRequestPurposeEnum_login;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AuthOtpRequestPostRequestPurposeEnum>
    _$authOtpRequestPostRequestPurposeEnumValues = BuiltSet<
        AuthOtpRequestPostRequestPurposeEnum>(const <AuthOtpRequestPostRequestPurposeEnum>[
  _$authOtpRequestPostRequestPurposeEnum_register,
  _$authOtpRequestPostRequestPurposeEnum_login,
]);

Serializer<AuthOtpRequestPostRequestPurposeEnum>
    _$authOtpRequestPostRequestPurposeEnumSerializer =
    _$AuthOtpRequestPostRequestPurposeEnumSerializer();

class _$AuthOtpRequestPostRequestPurposeEnumSerializer
    implements PrimitiveSerializer<AuthOtpRequestPostRequestPurposeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'register': 'register',
    'login': 'login',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'register': 'register',
    'login': 'login',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AuthOtpRequestPostRequestPurposeEnum
  ];
  @override
  final String wireName = 'AuthOtpRequestPostRequestPurposeEnum';

  @override
  Object serialize(
          Serializers serializers, AuthOtpRequestPostRequestPurposeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AuthOtpRequestPostRequestPurposeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AuthOtpRequestPostRequestPurposeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AuthOtpRequestPostRequest extends AuthOtpRequestPostRequest {
  @override
  final String phone;
  @override
  final AuthOtpRequestPostRequestPurposeEnum purpose;

  factory _$AuthOtpRequestPostRequest(
          [void Function(AuthOtpRequestPostRequestBuilder)? updates]) =>
      (AuthOtpRequestPostRequestBuilder()..update(updates))._build();

  _$AuthOtpRequestPostRequest._({required this.phone, required this.purpose})
      : super._();
  @override
  AuthOtpRequestPostRequest rebuild(
          void Function(AuthOtpRequestPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthOtpRequestPostRequestBuilder toBuilder() =>
      AuthOtpRequestPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthOtpRequestPostRequest &&
        phone == other.phone &&
        purpose == other.purpose;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, purpose.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthOtpRequestPostRequest')
          ..add('phone', phone)
          ..add('purpose', purpose))
        .toString();
  }
}

class AuthOtpRequestPostRequestBuilder
    implements
        Builder<AuthOtpRequestPostRequest, AuthOtpRequestPostRequestBuilder> {
  _$AuthOtpRequestPostRequest? _$v;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  AuthOtpRequestPostRequestPurposeEnum? _purpose;
  AuthOtpRequestPostRequestPurposeEnum? get purpose => _$this._purpose;
  set purpose(AuthOtpRequestPostRequestPurposeEnum? purpose) =>
      _$this._purpose = purpose;

  AuthOtpRequestPostRequestBuilder() {
    AuthOtpRequestPostRequest._defaults(this);
  }

  AuthOtpRequestPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _phone = $v.phone;
      _purpose = $v.purpose;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthOtpRequestPostRequest other) {
    _$v = other as _$AuthOtpRequestPostRequest;
  }

  @override
  void update(void Function(AuthOtpRequestPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthOtpRequestPostRequest build() => _build();

  _$AuthOtpRequestPostRequest _build() {
    final _$result = _$v ??
        _$AuthOtpRequestPostRequest._(
          phone: BuiltValueNullFieldError.checkNotNull(
              phone, r'AuthOtpRequestPostRequest', 'phone'),
          purpose: BuiltValueNullFieldError.checkNotNull(
              purpose, r'AuthOtpRequestPostRequest', 'purpose'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
