//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:binno_api/src/model/product_card_supplier.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_card.g.dart';

/// ProductCard
///
/// Properties:
/// * [id]
/// * [title]
/// * [priceDisplay]
/// * [unit]
/// * [mainPhoto]
/// * [supplier]
/// * [categoryPath]
@BuiltValue()
abstract class ProductCard implements Built<ProductCard, ProductCardBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'title')
  String? get title;

  @BuiltValueField(wireName: r'price_display')
  String? get priceDisplay;

  @BuiltValueField(wireName: r'unit')
  String? get unit;

  @BuiltValueField(wireName: r'main_photo')
  String? get mainPhoto;

  @BuiltValueField(wireName: r'supplier')
  ProductCardSupplier? get supplier;

  @BuiltValueField(wireName: r'category_path')
  String? get categoryPath;

  ProductCard._();

  factory ProductCard([void updates(ProductCardBuilder b)]) = _$ProductCard;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductCardBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductCard> get serializer => _$ProductCardSerializer();
}

class _$ProductCardSerializer implements PrimitiveSerializer<ProductCard> {
  @override
  final Iterable<Type> types = const [ProductCard, _$ProductCard];

  @override
  final String wireName = r'ProductCard';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductCard object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    if (object.priceDisplay != null) {
      yield r'price_display';
      yield serializers.serialize(
        object.priceDisplay,
        specifiedType: const FullType(String),
      );
    }
    if (object.unit != null) {
      yield r'unit';
      yield serializers.serialize(
        object.unit,
        specifiedType: const FullType(String),
      );
    }
    if (object.mainPhoto != null) {
      yield r'main_photo';
      yield serializers.serialize(
        object.mainPhoto,
        specifiedType: const FullType(String),
      );
    }
    if (object.supplier != null) {
      yield r'supplier';
      yield serializers.serialize(
        object.supplier,
        specifiedType: const FullType(ProductCardSupplier),
      );
    }
    if (object.categoryPath != null) {
      yield r'category_path';
      yield serializers.serialize(
        object.categoryPath,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductCard object, {
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
    required ProductCardBuilder result,
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
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'price_display':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.priceDisplay = valueDes;
          break;
        case r'unit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.unit = valueDes;
          break;
        case r'main_photo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mainPhoto = valueDes;
          break;
        case r'supplier':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProductCardSupplier),
          ) as ProductCardSupplier;
          result.supplier.replace(valueDes);
          break;
        case r'category_path':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.categoryPath = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductCard deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductCardBuilder();
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
