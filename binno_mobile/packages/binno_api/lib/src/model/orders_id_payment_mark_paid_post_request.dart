//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'orders_id_payment_mark_paid_post_request.g.dart';

/// OrdersIdPaymentMarkPaidPostRequest
///
/// Properties:
/// * [receiptPhoto] - uploaded file URL/id
@BuiltValue()
abstract class OrdersIdPaymentMarkPaidPostRequest
    implements
        Built<OrdersIdPaymentMarkPaidPostRequest,
            OrdersIdPaymentMarkPaidPostRequestBuilder> {
  /// uploaded file URL/id
  @BuiltValueField(wireName: r'receipt_photo')
  String? get receiptPhoto;

  OrdersIdPaymentMarkPaidPostRequest._();

  factory OrdersIdPaymentMarkPaidPostRequest(
          [void updates(OrdersIdPaymentMarkPaidPostRequestBuilder b)]) =
      _$OrdersIdPaymentMarkPaidPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrdersIdPaymentMarkPaidPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrdersIdPaymentMarkPaidPostRequest> get serializer =>
      _$OrdersIdPaymentMarkPaidPostRequestSerializer();
}

class _$OrdersIdPaymentMarkPaidPostRequestSerializer
    implements PrimitiveSerializer<OrdersIdPaymentMarkPaidPostRequest> {
  @override
  final Iterable<Type> types = const [
    OrdersIdPaymentMarkPaidPostRequest,
    _$OrdersIdPaymentMarkPaidPostRequest
  ];

  @override
  final String wireName = r'OrdersIdPaymentMarkPaidPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrdersIdPaymentMarkPaidPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.receiptPhoto != null) {
      yield r'receipt_photo';
      yield serializers.serialize(
        object.receiptPhoto,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OrdersIdPaymentMarkPaidPostRequest object, {
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
    required OrdersIdPaymentMarkPaidPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'receipt_photo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.receiptPhoto = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrdersIdPaymentMarkPaidPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrdersIdPaymentMarkPaidPostRequestBuilder();
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
