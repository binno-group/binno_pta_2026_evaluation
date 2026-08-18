//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_otp_request_post200_response.g.dart';

/// AuthOtpRequestPost200Response
///
/// Properties:
/// * [requestId]
/// * [expiresIn]
/// * [retryAfter]
@BuiltValue()
abstract class AuthOtpRequestPost200Response
    implements
        Built<AuthOtpRequestPost200Response,
            AuthOtpRequestPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'request_id')
  String? get requestId;

  @BuiltValueField(wireName: r'expires_in')
  int? get expiresIn;

  @BuiltValueField(wireName: r'retry_after')
  int? get retryAfter;

  AuthOtpRequestPost200Response._();

  factory AuthOtpRequestPost200Response(
          [void updates(AuthOtpRequestPost200ResponseBuilder b)]) =
      _$AuthOtpRequestPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthOtpRequestPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthOtpRequestPost200Response> get serializer =>
      _$AuthOtpRequestPost200ResponseSerializer();
}

class _$AuthOtpRequestPost200ResponseSerializer
    implements PrimitiveSerializer<AuthOtpRequestPost200Response> {
  @override
  final Iterable<Type> types = const [
    AuthOtpRequestPost200Response,
    _$AuthOtpRequestPost200Response
  ];

  @override
  final String wireName = r'AuthOtpRequestPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthOtpRequestPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.requestId != null) {
      yield r'request_id';
      yield serializers.serialize(
        object.requestId,
        specifiedType: const FullType(String),
      );
    }
    if (object.expiresIn != null) {
      yield r'expires_in';
      yield serializers.serialize(
        object.expiresIn,
        specifiedType: const FullType(int),
      );
    }
    if (object.retryAfter != null) {
      yield r'retry_after';
      yield serializers.serialize(
        object.retryAfter,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthOtpRequestPost200Response object, {
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
    required AuthOtpRequestPost200ResponseBuilder result,
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
        case r'expires_in':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expiresIn = valueDes;
          break;
        case r'retry_after':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.retryAfter = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthOtpRequestPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthOtpRequestPost200ResponseBuilder();
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
