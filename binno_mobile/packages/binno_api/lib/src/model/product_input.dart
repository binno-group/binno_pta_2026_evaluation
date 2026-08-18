//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_input.g.dart';

/// ProductInput
///
/// Properties:
/// * [title]
/// * [categoryId] - leaf categories only (BR-06.1)
/// * [description]
/// * [priceModel]
/// * [priceFixed] - Integer tiyin (UZS). Floats are forbidden.
/// * [priceMin] - Integer tiyin (UZS). Floats are forbidden.
/// * [priceMax] - Integer tiyin (UZS). Floats are forbidden.
/// * [unit]
/// * [weightClass]
@BuiltValue()
abstract class ProductInput
    implements Built<ProductInput, ProductInputBuilder> {
  @BuiltValueField(wireName: r'title')
  String get title;

  /// leaf categories only (BR-06.1)
  @BuiltValueField(wireName: r'category_id')
  int get categoryId;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'price_model')
  ProductInputPriceModelEnum get priceModel;
  // enum priceModelEnum {  fixed,  range,  };

  /// Integer tiyin (UZS). Floats are forbidden.
  @BuiltValueField(wireName: r'price_fixed')
  int? get priceFixed;

  /// Integer tiyin (UZS). Floats are forbidden.
  @BuiltValueField(wireName: r'price_min')
  int? get priceMin;

  /// Integer tiyin (UZS). Floats are forbidden.
  @BuiltValueField(wireName: r'price_max')
  int? get priceMax;

  @BuiltValueField(wireName: r'unit')
  ProductInputUnitEnum get unit;
  // enum unitEnum {  dona,  m2,  pogm,  toplam,  kg,  };

  @BuiltValueField(wireName: r'weight_class')
  ProductInputWeightClassEnum get weightClass;
  // enum weightClassEnum {  light,  heavy,  fragile,  };

  ProductInput._();

  factory ProductInput([void updates(ProductInputBuilder b)]) = _$ProductInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductInput> get serializer => _$ProductInputSerializer();
}

class _$ProductInputSerializer implements PrimitiveSerializer<ProductInput> {
  @override
  final Iterable<Type> types = const [ProductInput, _$ProductInput];

  @override
  final String wireName = r'ProductInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'category_id';
    yield serializers.serialize(
      object.categoryId,
      specifiedType: const FullType(int),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    yield r'price_model';
    yield serializers.serialize(
      object.priceModel,
      specifiedType: const FullType(ProductInputPriceModelEnum),
    );
    if (object.priceFixed != null) {
      yield r'price_fixed';
      yield serializers.serialize(
        object.priceFixed,
        specifiedType: const FullType(int),
      );
    }
    if (object.priceMin != null) {
      yield r'price_min';
      yield serializers.serialize(
        object.priceMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.priceMax != null) {
      yield r'price_max';
      yield serializers.serialize(
        object.priceMax,
        specifiedType: const FullType(int),
      );
    }
    yield r'unit';
    yield serializers.serialize(
      object.unit,
      specifiedType: const FullType(ProductInputUnitEnum),
    );
    yield r'weight_class';
    yield serializers.serialize(
      object.weightClass,
      specifiedType: const FullType(ProductInputWeightClassEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductInput object, {
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
    required ProductInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'category_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.categoryId = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'price_model':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProductInputPriceModelEnum),
          ) as ProductInputPriceModelEnum;
          result.priceModel = valueDes;
          break;
        case r'price_fixed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.priceFixed = valueDes;
          break;
        case r'price_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.priceMin = valueDes;
          break;
        case r'price_max':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.priceMax = valueDes;
          break;
        case r'unit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProductInputUnitEnum),
          ) as ProductInputUnitEnum;
          result.unit = valueDes;
          break;
        case r'weight_class':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProductInputWeightClassEnum),
          ) as ProductInputWeightClassEnum;
          result.weightClass = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductInputBuilder();
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

class ProductInputPriceModelEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fixed')
  static const ProductInputPriceModelEnum fixed =
      _$productInputPriceModelEnum_fixed;
  @BuiltValueEnumConst(wireName: r'range')
  static const ProductInputPriceModelEnum range =
      _$productInputPriceModelEnum_range;

  static Serializer<ProductInputPriceModelEnum> get serializer =>
      _$productInputPriceModelEnumSerializer;

  const ProductInputPriceModelEnum._(String name) : super(name);

  static BuiltSet<ProductInputPriceModelEnum> get values =>
      _$productInputPriceModelEnumValues;
  static ProductInputPriceModelEnum valueOf(String name) =>
      _$productInputPriceModelEnumValueOf(name);
}

class ProductInputUnitEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'dona')
  static const ProductInputUnitEnum dona = _$productInputUnitEnum_dona;
  @BuiltValueEnumConst(wireName: r'm2')
  static const ProductInputUnitEnum m2 = _$productInputUnitEnum_m2;
  @BuiltValueEnumConst(wireName: r'pogm')
  static const ProductInputUnitEnum pogm = _$productInputUnitEnum_pogm;
  @BuiltValueEnumConst(wireName: r'toplam')
  static const ProductInputUnitEnum toplam = _$productInputUnitEnum_toplam;
  @BuiltValueEnumConst(wireName: r'kg')
  static const ProductInputUnitEnum kg = _$productInputUnitEnum_kg;

  static Serializer<ProductInputUnitEnum> get serializer =>
      _$productInputUnitEnumSerializer;

  const ProductInputUnitEnum._(String name) : super(name);

  static BuiltSet<ProductInputUnitEnum> get values =>
      _$productInputUnitEnumValues;
  static ProductInputUnitEnum valueOf(String name) =>
      _$productInputUnitEnumValueOf(name);
}

class ProductInputWeightClassEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'light')
  static const ProductInputWeightClassEnum light =
      _$productInputWeightClassEnum_light;
  @BuiltValueEnumConst(wireName: r'heavy')
  static const ProductInputWeightClassEnum heavy =
      _$productInputWeightClassEnum_heavy;
  @BuiltValueEnumConst(wireName: r'fragile')
  static const ProductInputWeightClassEnum fragile =
      _$productInputWeightClassEnum_fragile;

  static Serializer<ProductInputWeightClassEnum> get serializer =>
      _$productInputWeightClassEnumSerializer;

  const ProductInputWeightClassEnum._(String name) : super(name);

  static BuiltSet<ProductInputWeightClassEnum> get values =>
      _$productInputWeightClassEnumValues;
  static ProductInputWeightClassEnum valueOf(String name) =>
      _$productInputWeightClassEnumValueOf(name);
}
