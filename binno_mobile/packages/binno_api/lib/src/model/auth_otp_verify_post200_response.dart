//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:binno_api/src/model/user.dart';
import 'package:binno_api/src/model/auth_otp_verify_post200_response_one_of.dart';
import 'package:binno_api/src/model/token_pair.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'auth_otp_verify_post200_response.g.dart';

/// AuthOtpVerifyPost200Response
///
/// Properties:
/// * [accessToken]
/// * [refreshToken]
/// * [user]
/// * [registrationToken]
@BuiltValue()
abstract class AuthOtpVerifyPost200Response
    implements
        Built<AuthOtpVerifyPost200Response,
            AuthOtpVerifyPost200ResponseBuilder> {
  /// One Of [AuthOtpVerifyPost200ResponseOneOf], [TokenPair]
  OneOf get oneOf;

  AuthOtpVerifyPost200Response._();

  factory AuthOtpVerifyPost200Response(
          [void updates(AuthOtpVerifyPost200ResponseBuilder b)]) =
      _$AuthOtpVerifyPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthOtpVerifyPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthOtpVerifyPost200Response> get serializer =>
      _$AuthOtpVerifyPost200ResponseSerializer();
}

class _$AuthOtpVerifyPost200ResponseSerializer
    implements PrimitiveSerializer<AuthOtpVerifyPost200Response> {
  @override
  final Iterable<Type> types = const [
    AuthOtpVerifyPost200Response,
    _$AuthOtpVerifyPost200Response
  ];

  @override
  final String wireName = r'AuthOtpVerifyPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthOtpVerifyPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    AuthOtpVerifyPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value,
        specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  AuthOtpVerifyPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthOtpVerifyPost200ResponseBuilder();
    Object? oneOfDataSrc;
    final targetType = const FullType(OneOf, [
      FullType(TokenPair),
      FullType(AuthOtpVerifyPost200ResponseOneOf),
    ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc,
        specifiedType: targetType) as OneOf;
    return result.build();
  }
}
