//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:binno_api/src/model/price_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'orders_post201_response.g.dart';

/// OrdersPost201Response
///
/// Properties:
/// * [orderId]
/// * [status]
/// * [priceSummary]
@BuiltValue()
abstract class OrdersPost201Response
    implements Built<OrdersPost201Response, OrdersPost201ResponseBuilder> {
  @BuiltValueField(wireName: r'order_id')
  String? get orderId;

  @BuiltValueField(wireName: r'status')
  String? get status;

  @BuiltValueField(wireName: r'price_summary')
  PriceSummary? get priceSummary;

  OrdersPost201Response._();

  factory OrdersPost201Response(
      [void updates(OrdersPost201ResponseBuilder b)]) = _$OrdersPost201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrdersPost201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrdersPost201Response> get serializer =>
      _$OrdersPost201ResponseSerializer();
}

class _$OrdersPost201ResponseSerializer
    implements PrimitiveSerializer<OrdersPost201Response> {
  @override
  final Iterable<Type> types = const [
    OrdersPost201Response,
    _$OrdersPost201Response
  ];

  @override
  final String wireName = r'OrdersPost201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrdersPost201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.orderId != null) {
      yield r'order_id';
      yield serializers.serialize(
        object.orderId,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(String),
      );
    }
    if (object.priceSummary != null) {
      yield r'price_summary';
      yield serializers.serialize(
        object.priceSummary,
        specifiedType: const FullType(PriceSummary),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OrdersPost201Response object, {
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
    required OrdersPost201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'order_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'price_summary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PriceSummary),
          ) as PriceSummary;
          result.priceSummary.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrdersPost201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrdersPost201ResponseBuilder();
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
