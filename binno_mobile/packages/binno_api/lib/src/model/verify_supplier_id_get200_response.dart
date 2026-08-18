//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'verify_supplier_id_get200_response.g.dart';

/// VerifySupplierIdGet200Response
///
/// Properties:
/// * [legalName]
/// * [stirMasked]
/// * [level]
/// * [verifiedAt]
/// * [validUntil]
@BuiltValue()
abstract class VerifySupplierIdGet200Response
    implements
        Built<VerifySupplierIdGet200Response,
            VerifySupplierIdGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'legal_name')
  String? get legalName;

  @BuiltValueField(wireName: r'stir_masked')
  String? get stirMasked;

  @BuiltValueField(wireName: r'level')
  VerifySupplierIdGet200ResponseLevelEnum? get level;
  // enum levelEnum {  basic,  advanced,  };

  @BuiltValueField(wireName: r'verified_at')
  DateTime? get verifiedAt;

  @BuiltValueField(wireName: r'valid_until')
  DateTime? get validUntil;

  VerifySupplierIdGet200Response._();

  factory VerifySupplierIdGet200Response(
          [void updates(VerifySupplierIdGet200ResponseBuilder b)]) =
      _$VerifySupplierIdGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VerifySupplierIdGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VerifySupplierIdGet200Response> get serializer =>
      _$VerifySupplierIdGet200ResponseSerializer();
}

class _$VerifySupplierIdGet200ResponseSerializer
    implements PrimitiveSerializer<VerifySupplierIdGet200Response> {
  @override
  final Iterable<Type> types = const [
    VerifySupplierIdGet200Response,
    _$VerifySupplierIdGet200Response
  ];

  @override
  final String wireName = r'VerifySupplierIdGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VerifySupplierIdGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.legalName != null) {
      yield r'legal_name';
      yield serializers.serialize(
        object.legalName,
        specifiedType: const FullType(String),
      );
    }
    if (object.stirMasked != null) {
      yield r'stir_masked';
      yield serializers.serialize(
        object.stirMasked,
        specifiedType: const FullType(String),
      );
    }
    if (object.level != null) {
      yield r'level';
      yield serializers.serialize(
        object.level,
        specifiedType: const FullType(VerifySupplierIdGet200ResponseLevelEnum),
      );
    }
    if (object.verifiedAt != null) {
      yield r'verified_at';
      yield serializers.serialize(
        object.verifiedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.validUntil != null) {
      yield r'valid_until';
      yield serializers.serialize(
        object.validUntil,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    VerifySupplierIdGet200Response object, {
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
    required VerifySupplierIdGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'legal_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.legalName = valueDes;
          break;
        case r'stir_masked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.stirMasked = valueDes;
          break;
        case r'level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(VerifySupplierIdGet200ResponseLevelEnum),
          ) as VerifySupplierIdGet200ResponseLevelEnum;
          result.level = valueDes;
          break;
        case r'verified_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.verifiedAt = valueDes;
          break;
        case r'valid_until':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.validUntil = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VerifySupplierIdGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VerifySupplierIdGet200ResponseBuilder();
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

class VerifySupplierIdGet200ResponseLevelEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'basic')
  static const VerifySupplierIdGet200ResponseLevelEnum basic =
      _$verifySupplierIdGet200ResponseLevelEnum_basic;
  @BuiltValueEnumConst(wireName: r'advanced')
  static const VerifySupplierIdGet200ResponseLevelEnum advanced =
      _$verifySupplierIdGet200ResponseLevelEnum_advanced;

  static Serializer<VerifySupplierIdGet200ResponseLevelEnum> get serializer =>
      _$verifySupplierIdGet200ResponseLevelEnumSerializer;

  const VerifySupplierIdGet200ResponseLevelEnum._(String name) : super(name);

  static BuiltSet<VerifySupplierIdGet200ResponseLevelEnum> get values =>
      _$verifySupplierIdGet200ResponseLevelEnumValues;
  static VerifySupplierIdGet200ResponseLevelEnum valueOf(String name) =>
      _$verifySupplierIdGet200ResponseLevelEnumValueOf(name);
}
