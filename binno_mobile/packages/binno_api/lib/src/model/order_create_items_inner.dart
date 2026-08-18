//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_create_items_inner.g.dart';

/// OrderCreateItemsInner
///
/// Properties:
/// * [productId]
/// * [qty]
/// * [note]
@BuiltValue()
abstract class OrderCreateItemsInner
    implements Built<OrderCreateItemsInner, OrderCreateItemsInnerBuilder> {
  @BuiltValueField(wireName: r'product_id')
  String get productId;

  @BuiltValueField(wireName: r'qty')
  num get qty;

  @BuiltValueField(wireName: r'note')
  String? get note;

  OrderCreateItemsInner._();

  factory OrderCreateItemsInner(
      [void updates(OrderCreateItemsInnerBuilder b)]) = _$OrderCreateItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderCreateItemsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderCreateItemsInner> get serializer =>
      _$OrderCreateItemsInnerSerializer();
}

class _$OrderCreateItemsInnerSerializer
    implements PrimitiveSerializer<OrderCreateItemsInner> {
  @override
  final Iterable<Type> types = const [
    OrderCreateItemsInner,
    _$OrderCreateItemsInner
  ];

  @override
  final String wireName = r'OrderCreateItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderCreateItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product_id';
    yield serializers.serialize(
      object.productId,
      specifiedType: const FullType(String),
    );
    yield r'qty';
    yield serializers.serialize(
      object.qty,
      specifiedType: const FullType(num),
    );
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderCreateItemsInner object, {
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
    required OrderCreateItemsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'product_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.productId = valueDes;
          break;
        case r'qty':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.qty = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrderCreateItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderCreateItemsInnerBuilder();
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
