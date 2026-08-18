//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_detail_all_of_items.g.dart';

/// OrderDetailAllOfItems
///
/// Properties:
/// * [productSnapshot] - product card snapshot (BR-08 DB)
/// * [qty]
/// * [unitPrice] - Integer tiyin (UZS). Floats are forbidden.
/// * [lineTotal] - Integer tiyin (UZS). Floats are forbidden.
@BuiltValue()
abstract class OrderDetailAllOfItems
    implements Built<OrderDetailAllOfItems, OrderDetailAllOfItemsBuilder> {
  /// product card snapshot (BR-08 DB)
  @BuiltValueField(wireName: r'product_snapshot')
  JsonObject? get productSnapshot;

  @BuiltValueField(wireName: r'qty')
  num? get qty;

  /// Integer tiyin (UZS). Floats are forbidden.
  @BuiltValueField(wireName: r'unit_price')
  int? get unitPrice;

  /// Integer tiyin (UZS). Floats are forbidden.
  @BuiltValueField(wireName: r'line_total')
  int? get lineTotal;

  OrderDetailAllOfItems._();

  factory OrderDetailAllOfItems(
      [void updates(OrderDetailAllOfItemsBuilder b)]) = _$OrderDetailAllOfItems;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderDetailAllOfItemsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderDetailAllOfItems> get serializer =>
      _$OrderDetailAllOfItemsSerializer();
}

class _$OrderDetailAllOfItemsSerializer
    implements PrimitiveSerializer<OrderDetailAllOfItems> {
  @override
  final Iterable<Type> types = const [
    OrderDetailAllOfItems,
    _$OrderDetailAllOfItems
  ];

  @override
  final String wireName = r'OrderDetailAllOfItems';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderDetailAllOfItems object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.productSnapshot != null) {
      yield r'product_snapshot';
      yield serializers.serialize(
        object.productSnapshot,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.qty != null) {
      yield r'qty';
      yield serializers.serialize(
        object.qty,
        specifiedType: const FullType(num),
      );
    }
    if (object.unitPrice != null) {
      yield r'unit_price';
      yield serializers.serialize(
        object.unitPrice,
        specifiedType: const FullType(int),
      );
    }
    if (object.lineTotal != null) {
      yield r'line_total';
      yield serializers.serialize(
        object.lineTotal,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderDetailAllOfItems object, {
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
    required OrderDetailAllOfItemsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'product_snapshot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.productSnapshot = valueDes;
          break;
        case r'qty':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.qty = valueDes;
          break;
        case r'unit_price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.unitPrice = valueDes;
          break;
        case r'line_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.lineTotal = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrderDetailAllOfItems deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderDetailAllOfItemsBuilder();
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
