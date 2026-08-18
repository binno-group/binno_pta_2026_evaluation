//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:binno_api/src/model/order_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'orders_get200_response.g.dart';

/// OrdersGet200Response
///
/// Properties:
/// * [items]
/// * [nextCursor]
@BuiltValue()
abstract class OrdersGet200Response
    implements Built<OrdersGet200Response, OrdersGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<OrderSummary>? get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  OrdersGet200Response._();

  factory OrdersGet200Response([void updates(OrdersGet200ResponseBuilder b)]) =
      _$OrdersGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrdersGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrdersGet200Response> get serializer =>
      _$OrdersGet200ResponseSerializer();
}

class _$OrdersGet200ResponseSerializer
    implements PrimitiveSerializer<OrdersGet200Response> {
  @override
  final Iterable<Type> types = const [
    OrdersGet200Response,
    _$OrdersGet200Response
  ];

  @override
  final String wireName = r'OrdersGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrdersGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.items != null) {
      yield r'items';
      yield serializers.serialize(
        object.items,
        specifiedType: const FullType(BuiltList, [FullType(OrderSummary)]),
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
    OrdersGet200Response object, {
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
    required OrdersGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OrderSummary)]),
          ) as BuiltList<OrderSummary>;
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
  OrdersGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrdersGet200ResponseBuilder();
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
