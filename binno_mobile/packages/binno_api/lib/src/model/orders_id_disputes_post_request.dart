//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'orders_id_disputes_post_request.g.dart';

/// OrdersIdDisputesPostRequest
///
/// Properties:
/// * [type]
/// * [statement]
/// * [photos]
@BuiltValue()
abstract class OrdersIdDisputesPostRequest
    implements
        Built<OrdersIdDisputesPostRequest, OrdersIdDisputesPostRequestBuilder> {
  @BuiltValueField(wireName: r'type')
  OrdersIdDisputesPostRequestTypeEnum get type;
  // enum typeEnum {  payment_not_received,  goods_damaged,  wrong_items,  not_delivered,  quality_claim,  other,  };

  @BuiltValueField(wireName: r'statement')
  String get statement;

  @BuiltValueField(wireName: r'photos')
  BuiltList<String>? get photos;

  OrdersIdDisputesPostRequest._();

  factory OrdersIdDisputesPostRequest(
          [void updates(OrdersIdDisputesPostRequestBuilder b)]) =
      _$OrdersIdDisputesPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrdersIdDisputesPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrdersIdDisputesPostRequest> get serializer =>
      _$OrdersIdDisputesPostRequestSerializer();
}

class _$OrdersIdDisputesPostRequestSerializer
    implements PrimitiveSerializer<OrdersIdDisputesPostRequest> {
  @override
  final Iterable<Type> types = const [
    OrdersIdDisputesPostRequest,
    _$OrdersIdDisputesPostRequest
  ];

  @override
  final String wireName = r'OrdersIdDisputesPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrdersIdDisputesPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(OrdersIdDisputesPostRequestTypeEnum),
    );
    yield r'statement';
    yield serializers.serialize(
      object.statement,
      specifiedType: const FullType(String),
    );
    if (object.photos != null) {
      yield r'photos';
      yield serializers.serialize(
        object.photos,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OrdersIdDisputesPostRequest object, {
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
    required OrdersIdDisputesPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OrdersIdDisputesPostRequestTypeEnum),
          ) as OrdersIdDisputesPostRequestTypeEnum;
          result.type = valueDes;
          break;
        case r'statement':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.statement = valueDes;
          break;
        case r'photos':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.photos.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrdersIdDisputesPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrdersIdDisputesPostRequestBuilder();
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

class OrdersIdDisputesPostRequestTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'payment_not_received')
  static const OrdersIdDisputesPostRequestTypeEnum paymentNotReceived =
      _$ordersIdDisputesPostRequestTypeEnum_paymentNotReceived;
  @BuiltValueEnumConst(wireName: r'goods_damaged')
  static const OrdersIdDisputesPostRequestTypeEnum goodsDamaged =
      _$ordersIdDisputesPostRequestTypeEnum_goodsDamaged;
  @BuiltValueEnumConst(wireName: r'wrong_items')
  static const OrdersIdDisputesPostRequestTypeEnum wrongItems =
      _$ordersIdDisputesPostRequestTypeEnum_wrongItems;
  @BuiltValueEnumConst(wireName: r'not_delivered')
  static const OrdersIdDisputesPostRequestTypeEnum notDelivered =
      _$ordersIdDisputesPostRequestTypeEnum_notDelivered;
  @BuiltValueEnumConst(wireName: r'quality_claim')
  static const OrdersIdDisputesPostRequestTypeEnum qualityClaim =
      _$ordersIdDisputesPostRequestTypeEnum_qualityClaim;
  @BuiltValueEnumConst(wireName: r'other')
  static const OrdersIdDisputesPostRequestTypeEnum other =
      _$ordersIdDisputesPostRequestTypeEnum_other;

  static Serializer<OrdersIdDisputesPostRequestTypeEnum> get serializer =>
      _$ordersIdDisputesPostRequestTypeEnumSerializer;

  const OrdersIdDisputesPostRequestTypeEnum._(String name) : super(name);

  static BuiltSet<OrdersIdDisputesPostRequestTypeEnum> get values =>
      _$ordersIdDisputesPostRequestTypeEnumValues;
  static OrdersIdDisputesPostRequestTypeEnum valueOf(String name) =>
      _$ordersIdDisputesPostRequestTypeEnumValueOf(name);
}
