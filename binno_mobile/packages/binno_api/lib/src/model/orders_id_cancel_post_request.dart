//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'orders_id_cancel_post_request.g.dart';

/// OrdersIdCancelPostRequest
///
/// Properties:
/// * [reason]
@BuiltValue()
abstract class OrdersIdCancelPostRequest
    implements
        Built<OrdersIdCancelPostRequest, OrdersIdCancelPostRequestBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  OrdersIdCancelPostRequest._();

  factory OrdersIdCancelPostRequest(
          [void updates(OrdersIdCancelPostRequestBuilder b)]) =
      _$OrdersIdCancelPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrdersIdCancelPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrdersIdCancelPostRequest> get serializer =>
      _$OrdersIdCancelPostRequestSerializer();
}

class _$OrdersIdCancelPostRequestSerializer
    implements PrimitiveSerializer<OrdersIdCancelPostRequest> {
  @override
  final Iterable<Type> types = const [
    OrdersIdCancelPostRequest,
    _$OrdersIdCancelPostRequest
  ];

  @override
  final String wireName = r'OrdersIdCancelPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrdersIdCancelPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OrdersIdCancelPostRequest object, {
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
    required OrdersIdCancelPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrdersIdCancelPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrdersIdCancelPostRequestBuilder();
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
