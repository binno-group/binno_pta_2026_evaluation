//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_card_supplier.g.dart';

/// ProductCardSupplier
///
/// Properties:
/// * [id]
/// * [name]
/// * [rating] - null when there are <3 ratings — the UI shows \"Yangi\"
/// * [isVerified]
/// * [verificationLevel]
@BuiltValue()
abstract class ProductCardSupplier
    implements Built<ProductCardSupplier, ProductCardSupplierBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'name')
  String? get name;

  /// null when there are <3 ratings — the UI shows \"Yangi\"
  @BuiltValueField(wireName: r'rating')
  num? get rating;

  @BuiltValueField(wireName: r'is_verified')
  bool? get isVerified;

  @BuiltValueField(wireName: r'verification_level')
  ProductCardSupplierVerificationLevelEnum? get verificationLevel;
  // enum verificationLevelEnum {  basic,  advanced,  };

  ProductCardSupplier._();

  factory ProductCardSupplier([void updates(ProductCardSupplierBuilder b)]) =
      _$ProductCardSupplier;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductCardSupplierBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductCardSupplier> get serializer =>
      _$ProductCardSupplierSerializer();
}

class _$ProductCardSupplierSerializer
    implements PrimitiveSerializer<ProductCardSupplier> {
  @override
  final Iterable<Type> types = const [
    ProductCardSupplier,
    _$ProductCardSupplier
  ];

  @override
  final String wireName = r'ProductCardSupplier';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductCardSupplier object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.rating != null) {
      yield r'rating';
      yield serializers.serialize(
        object.rating,
        specifiedType: const FullType(num),
      );
    }
    if (object.isVerified != null) {
      yield r'is_verified';
      yield serializers.serialize(
        object.isVerified,
        specifiedType: const FullType(bool),
      );
    }
    if (object.verificationLevel != null) {
      yield r'verification_level';
      yield serializers.serialize(
        object.verificationLevel,
        specifiedType: const FullType(ProductCardSupplierVerificationLevelEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductCardSupplier object, {
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
    required ProductCardSupplierBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'rating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.rating = valueDes;
          break;
        case r'is_verified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isVerified = valueDes;
          break;
        case r'verification_level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(ProductCardSupplierVerificationLevelEnum),
          ) as ProductCardSupplierVerificationLevelEnum;
          result.verificationLevel = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductCardSupplier deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductCardSupplierBuilder();
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

class ProductCardSupplierVerificationLevelEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'basic')
  static const ProductCardSupplierVerificationLevelEnum basic =
      _$productCardSupplierVerificationLevelEnum_basic;
  @BuiltValueEnumConst(wireName: r'advanced')
  static const ProductCardSupplierVerificationLevelEnum advanced =
      _$productCardSupplierVerificationLevelEnum_advanced;

  static Serializer<ProductCardSupplierVerificationLevelEnum> get serializer =>
      _$productCardSupplierVerificationLevelEnumSerializer;

  const ProductCardSupplierVerificationLevelEnum._(String name) : super(name);

  static BuiltSet<ProductCardSupplierVerificationLevelEnum> get values =>
      _$productCardSupplierVerificationLevelEnumValues;
  static ProductCardSupplierVerificationLevelEnum valueOf(String name) =>
      _$productCardSupplierVerificationLevelEnumValueOf(name);
}
