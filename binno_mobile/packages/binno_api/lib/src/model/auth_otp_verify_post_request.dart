//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_otp_verify_post_request.g.dart';

/// AuthOtpVerifyPostRequest
///
/// Properties:
/// * [requestId]
/// * [code]
@BuiltValue()
abstract class AuthOtpVerifyPostRequest
    implements
        Built<AuthOtpVerifyPostRequest, AuthOtpVerifyPostRequestBuilder> {
  @BuiltValueField(wireName: r'request_id')
  String get requestId;

  @BuiltValueField(wireName: r'code')
  String get code;

  AuthOtpVerifyPostRequest._();

  factory AuthOtpVerifyPostRequest(
          [void updates(AuthOtpVerifyPostRequestBuilder b)]) =
      _$AuthOtpVerifyPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthOtpVerifyPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthOtpVerifyPostRequest> get serializer =>
      _$AuthOtpVerifyPostRequestSerializer();
}

class _$AuthOtpVerifyPostRequestSerializer
    implements PrimitiveSerializer<AuthOtpVerifyPostRequest> {
  @override
  final Iterable<Type> types = const [
    AuthOtpVerifyPostRequest,
    _$AuthOtpVerifyPostRequest
  ];

  @override
  final String wireName = r'AuthOtpVerifyPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthOtpVerifyPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'request_id';
    yield serializers.serialize(
      object.requestId,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthOtpVerifyPostRequest object, {
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
    required AuthOtpVerifyPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'request_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requestId = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthOtpVerifyPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthOtpVerifyPostRequestBuilder();
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
