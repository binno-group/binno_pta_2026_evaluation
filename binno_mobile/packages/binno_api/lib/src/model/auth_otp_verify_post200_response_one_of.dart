//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_otp_verify_post200_response_one_of.g.dart';

/// AuthOtpVerifyPost200ResponseOneOf
///
/// Properties:
/// * [registrationToken]
@BuiltValue()
abstract class AuthOtpVerifyPost200ResponseOneOf
    implements
        Built<AuthOtpVerifyPost200ResponseOneOf,
            AuthOtpVerifyPost200ResponseOneOfBuilder> {
  @BuiltValueField(wireName: r'registration_token')
  String? get registrationToken;

  AuthOtpVerifyPost200ResponseOneOf._();

  factory AuthOtpVerifyPost200ResponseOneOf(
          [void updates(AuthOtpVerifyPost200ResponseOneOfBuilder b)]) =
      _$AuthOtpVerifyPost200ResponseOneOf;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthOtpVerifyPost200ResponseOneOfBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthOtpVerifyPost200ResponseOneOf> get serializer =>
      _$AuthOtpVerifyPost200ResponseOneOfSerializer();
}

class _$AuthOtpVerifyPost200ResponseOneOfSerializer
    implements PrimitiveSerializer<AuthOtpVerifyPost200ResponseOneOf> {
  @override
  final Iterable<Type> types = const [
    AuthOtpVerifyPost200ResponseOneOf,
    _$AuthOtpVerifyPost200ResponseOneOf
  ];

  @override
  final String wireName = r'AuthOtpVerifyPost200ResponseOneOf';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthOtpVerifyPost200ResponseOneOf object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.registrationToken != null) {
      yield r'registration_token';
      yield serializers.serialize(
        object.registrationToken,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthOtpVerifyPost200ResponseOneOf object, {
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
    required AuthOtpVerifyPost200ResponseOneOfBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'registration_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.registrationToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthOtpVerifyPost200ResponseOneOf deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthOtpVerifyPost200ResponseOneOfBuilder();
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
