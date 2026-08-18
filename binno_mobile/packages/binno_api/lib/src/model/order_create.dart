//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:binno_api/src/model/order_create_dropoff.dart';
import 'package:built_collection/built_collection.dart';
import 'package:binno_api/src/model/order_create_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_create.g.dart';

/// OrderCreate
///
/// Properties:
/// * [supplierId]
/// * [items]
/// * [dropoff]
/// * [isUrgent]
/// * [buyerNote]
@BuiltValue()
abstract class OrderCreate implements Built<OrderCreate, OrderCreateBuilder> {
  @BuiltValueField(wireName: r'supplier_id')
  String get supplierId;

  @BuiltValueField(wireName: r'items')
  BuiltList<OrderCreateItemsInner> get items;

  @BuiltValueField(wireName: r'dropoff')
  OrderCreateDropoff get dropoff;

  @BuiltValueField(wireName: r'is_urgent')
  bool? get isUrgent;

  @BuiltValueField(wireName: r'buyer_note')
  String? get buyerNote;

  OrderCreate._();

  factory OrderCreate([void updates(OrderCreateBuilder b)]) = _$OrderCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderCreateBuilder b) => b..isUrgent = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderCreate> get serializer => _$OrderCreateSerializer();
}

class _$OrderCreateSerializer implements PrimitiveSerializer<OrderCreate> {
  @override
  final Iterable<Type> types = const [OrderCreate, _$OrderCreate];

  @override
  final String wireName = r'OrderCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'supplier_id';
    yield serializers.serialize(
      object.supplierId,
      specifiedType: const FullType(String),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType:
          const FullType(BuiltList, [FullType(OrderCreateItemsInner)]),
    );
    yield r'dropoff';
    yield serializers.serialize(
      object.dropoff,
      specifiedType: const FullType(OrderCreateDropoff),
    );
    if (object.isUrgent != null) {
      yield r'is_urgent';
      yield serializers.serialize(
        object.isUrgent,
        specifiedType: const FullType(bool),
      );
    }
    if (object.buyerNote != null) {
      yield r'buyer_note';
      yield serializers.serialize(
        object.buyerNote,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderCreate object, {
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
    required OrderCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'supplier_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.supplierId = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(OrderCreateItemsInner)]),
          ) as BuiltList<OrderCreateItemsInner>;
          result.items.replace(valueDes);
          break;
        case r'dropoff':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OrderCreateDropoff),
          ) as OrderCreateDropoff;
          result.dropoff.replace(valueDes);
          break;
        case r'is_urgent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isUrgent = valueDes;
          break;
        case r'buyer_note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.buyerNote = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrderCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderCreateBuilder();
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
