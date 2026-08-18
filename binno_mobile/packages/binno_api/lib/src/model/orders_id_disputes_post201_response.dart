//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'orders_id_disputes_post201_response.g.dart';

/// OrdersIdDisputesPost201Response
///
/// Properties:
/// * [disputeId]
@BuiltValue()
abstract class OrdersIdDisputesPost201Response
    implements
        Built<OrdersIdDisputesPost201Response,
            OrdersIdDisputesPost201ResponseBuilder> {
  @BuiltValueField(wireName: r'dispute_id')
  String? get disputeId;

  OrdersIdDisputesPost201Response._();

  factory OrdersIdDisputesPost201Response(
          [void updates(OrdersIdDisputesPost201ResponseBuilder b)]) =
      _$OrdersIdDisputesPost201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrdersIdDisputesPost201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrdersIdDisputesPost201Response> get serializer =>
      _$OrdersIdDisputesPost201ResponseSerializer();
}

class _$OrdersIdDisputesPost201ResponseSerializer
    implements PrimitiveSerializer<OrdersIdDisputesPost201Response> {
  @override
  final Iterable<Type> types = const [
    OrdersIdDisputesPost201Response,
    _$OrdersIdDisputesPost201Response
  ];

  @override
  final String wireName = r'OrdersIdDisputesPost201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrdersIdDisputesPost201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.disputeId != null) {
      yield r'dispute_id';
      yield serializers.serialize(
        object.disputeId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OrdersIdDisputesPost201Response object, {
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
    required OrdersIdDisputesPost201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'dispute_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.disputeId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrdersIdDisputesPost201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrdersIdDisputesPost201ResponseBuilder();
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
