//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:binno_api/src/model/order_detail_all_of_events.dart';
import 'package:built_collection/built_collection.dart';
import 'package:binno_api/src/model/order_detail_all_of_items.dart';
import 'package:binno_api/src/model/order_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_detail.g.dart';

/// OrderDetail
///
/// Properties:
/// * [id]
/// * [reference]
/// * [status]
/// * [supplierName]
/// * [itemSummary]
/// * [totalAmount] - Integer tiyin (UZS). Floats are forbidden.
/// * [isUrgent]
/// * [updatedAt]
/// * [items]
/// * [events] - Append-only timeline (BR-08.2)
/// * [dropoffAddress]
/// * [invoiceNo]
@BuiltValue()
abstract class OrderDetail
    implements OrderSummary, Built<OrderDetail, OrderDetailBuilder> {
  @BuiltValueField(wireName: r'dropoff_address')
  String? get dropoffAddress;

  @BuiltValueField(wireName: r'invoice_no')
  String? get invoiceNo;

  @BuiltValueField(wireName: r'items')
  BuiltList<OrderDetailAllOfItems>? get items;

  /// Append-only timeline (BR-08.2)
  @BuiltValueField(wireName: r'events')
  BuiltList<OrderDetailAllOfEvents>? get events;

  OrderDetail._();

  factory OrderDetail([void updates(OrderDetailBuilder b)]) = _$OrderDetail;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderDetailBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderDetail> get serializer => _$OrderDetailSerializer();
}

class _$OrderDetailSerializer implements PrimitiveSerializer<OrderDetail> {
  @override
  final Iterable<Type> types = const [OrderDetail, _$OrderDetail];

  @override
  final String wireName = r'OrderDetail';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderDetail object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.dropoffAddress != null) {
      yield r'dropoff_address';
      yield serializers.serialize(
        object.dropoffAddress,
        specifiedType: const FullType(String),
      );
    }
    if (object.reference != null) {
      yield r'reference';
      yield serializers.serialize(
        object.reference,
        specifiedType: const FullType(String),
      );
    }
    if (object.supplierName != null) {
      yield r'supplier_name';
      yield serializers.serialize(
        object.supplierName,
        specifiedType: const FullType(String),
      );
    }
    if (object.itemSummary != null) {
      yield r'item_summary';
      yield serializers.serialize(
        object.itemSummary,
        specifiedType: const FullType(String),
      );
    }
    if (object.totalAmount != null) {
      yield r'total_amount';
      yield serializers.serialize(
        object.totalAmount,
        specifiedType: const FullType(int),
      );
    }
    if (object.isUrgent != null) {
      yield r'is_urgent';
      yield serializers.serialize(
        object.isUrgent,
        specifiedType: const FullType(bool),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.invoiceNo != null) {
      yield r'invoice_no';
      yield serializers.serialize(
        object.invoiceNo,
        specifiedType: const FullType(String),
      );
    }
    if (object.items != null) {
      yield r'items';
      yield serializers.serialize(
        object.items,
        specifiedType:
            const FullType(BuiltList, [FullType(OrderDetailAllOfItems)]),
      );
    }
    if (object.events != null) {
      yield r'events';
      yield serializers.serialize(
        object.events,
        specifiedType:
            const FullType(BuiltList, [FullType(OrderDetailAllOfEvents)]),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(String),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderDetail object, {
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
    required OrderDetailBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'dropoff_address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dropoffAddress = valueDes;
          break;
        case r'reference':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reference = valueDes;
          break;
        case r'supplier_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.supplierName = valueDes;
          break;
        case r'item_summary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.itemSummary = valueDes;
          break;
        case r'total_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalAmount = valueDes;
          break;
        case r'is_urgent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isUrgent = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'invoice_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.invoiceNo = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(OrderDetailAllOfItems)]),
          ) as BuiltList<OrderDetailAllOfItems>;
          result.items.replace(valueDes);
          break;
        case r'events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(OrderDetailAllOfEvents)]),
          ) as BuiltList<OrderDetailAllOfEvents>;
          result.events.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrderDetail deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderDetailBuilder();
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
