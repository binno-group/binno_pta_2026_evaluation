//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:binno_api/src/model/product_card.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_page.g.dart';

/// ProductPage
///
/// Properties:
/// * [items]
/// * [nextCursor]
@BuiltValue()
abstract class ProductPage implements Built<ProductPage, ProductPageBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ProductCard>? get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  ProductPage._();

  factory ProductPage([void updates(ProductPageBuilder b)]) = _$ProductPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductPage> get serializer => _$ProductPageSerializer();
}

class _$ProductPageSerializer implements PrimitiveSerializer<ProductPage> {
  @override
  final Iterable<Type> types = const [ProductPage, _$ProductPage];

  @override
  final String wireName = r'ProductPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.items != null) {
      yield r'items';
      yield serializers.serialize(
        object.items,
        specifiedType: const FullType(BuiltList, [FullType(ProductCard)]),
      );
    }
    if (object.nextCursor != null) {
      yield r'next_cursor';
      yield serializers.serialize(
        object.nextCursor,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductPage object, {
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
    required ProductPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ProductCard)]),
          ) as BuiltList<ProductCard>;
          result.items.replace(valueDes);
          break;
        case r'next_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nextCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductPageBuilder();
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
