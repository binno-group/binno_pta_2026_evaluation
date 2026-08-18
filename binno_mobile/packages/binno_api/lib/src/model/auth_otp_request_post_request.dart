//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_otp_request_post_request.g.dart';

/// AuthOtpRequestPostRequest
///
/// Properties:
/// * [phone]
/// * [purpose]
@BuiltValue()
abstract class AuthOtpRequestPostRequest
    implements
        Built<AuthOtpRequestPostRequest, AuthOtpRequestPostRequestBuilder> {
  @BuiltValueField(wireName: r'phone')
  String get phone;

  @BuiltValueField(wireName: r'purpose')
  AuthOtpRequestPostRequestPurposeEnum get purpose;
  // enum purposeEnum {  register,  login,  };

  AuthOtpRequestPostRequest._();

  factory AuthOtpRequestPostRequest(
          [void updates(AuthOtpRequestPostRequestBuilder b)]) =
      _$AuthOtpRequestPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthOtpRequestPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthOtpRequestPostRequest> get serializer =>
      _$AuthOtpRequestPostRequestSerializer();
}

class _$AuthOtpRequestPostRequestSerializer
    implements PrimitiveSerializer<AuthOtpRequestPostRequest> {
  @override
  final Iterable<Type> types = const [
    AuthOtpRequestPostRequest,
    _$AuthOtpRequestPostRequest
  ];

  @override
  final String wireName = r'AuthOtpRequestPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthOtpRequestPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
    yield r'purpose';
    yield serializers.serialize(
      object.purpose,
      specifiedType: const FullType(AuthOtpRequestPostRequestPurposeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthOtpRequestPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthOtpRequestPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phone = valueDes;
          break;
        case r'purpose':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AuthOtpRequestPostRequestPurposeEnum),
          ) as AuthOtpRequestPostRequestPurposeEnum;
          result.purpose = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthOtpRequestPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthOtpRequestPostRequestBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class AuthOtpRequestPostRequestPurposeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'register')
  static const AuthOtpRequestPostRequestPurposeEnum register =
      _$authOtpRequestPostRequestPurposeEnum_register;
  @BuiltValueEnumConst(wireName: r'login')
  static const AuthOtpRequestPostRequestPurposeEnum login =
      _$authOtpRequestPostRequestPurposeEnum_login;

  static Serializer<AuthOtpRequestPostRequestPurposeEnum> get serializer =>
      _$authOtpRequestPostRequestPurposeEnumSerializer;

  const AuthOtpRequestPostRequestPurposeEnum._(String name) : super(name);

  static BuiltSet<AuthOtpRequestPostRequestPurposeEnum> get values =>
      _$authOtpRequestPostRequestPurposeEnumValues;
  static AuthOtpRequestPostRequestPurposeEnum valueOf(String name) =>
      _$authOtpRequestPostRequestPurposeEnumValueOf(name);
}
