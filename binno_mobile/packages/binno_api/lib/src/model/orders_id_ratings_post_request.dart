//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'orders_id_ratings_post_request.g.dart';

/// OrdersIdRatingsPostRequest
///
/// Properties:
/// * [target]
/// * [score]
/// * [comment]
/// * [reasonCategory] - mandatory for scores 1-2 (BR-20.3)
@BuiltValue()
abstract class OrdersIdRatingsPostRequest
    implements
        Built<OrdersIdRatingsPostRequest, OrdersIdRatingsPostRequestBuilder> {
  @BuiltValueField(wireName: r'target')
  OrdersIdRatingsPostRequestTargetEnum get target;
  // enum targetEnum {  supplier,  driver,  buyer,  };

  @BuiltValueField(wireName: r'score')
  int get score;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  /// mandatory for scores 1-2 (BR-20.3)
  @BuiltValueField(wireName: r'reason_category')
  OrdersIdRatingsPostRequestReasonCategoryEnum? get reasonCategory;
  // enum reasonCategoryEnum {  sifat,  muddat,  muomala,  narx,  };

  OrdersIdRatingsPostRequest._();

  factory OrdersIdRatingsPostRequest(
          [void updates(OrdersIdRatingsPostRequestBuilder b)]) =
      _$OrdersIdRatingsPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrdersIdRatingsPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrdersIdRatingsPostRequest> get serializer =>
      _$OrdersIdRatingsPostRequestSerializer();
}

class _$OrdersIdRatingsPostRequestSerializer
    implements PrimitiveSerializer<OrdersIdRatingsPostRequest> {
  @override
  final Iterable<Type> types = const [
    OrdersIdRatingsPostRequest,
    _$OrdersIdRatingsPostRequest
  ];

  @override
  final String wireName = r'OrdersIdRatingsPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrdersIdRatingsPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'target';
    yield serializers.serialize(
      object.target,
      specifiedType: const FullType(OrdersIdRatingsPostRequestTargetEnum),
    );
    yield r'score';
    yield serializers.serialize(
      object.score,
      specifiedType: const FullType(int),
    );
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType(String),
      );
    }
    if (object.reasonCategory != null) {
      yield r'reason_category';
      yield serializers.serialize(
        object.reasonCategory,
        specifiedType:
            const FullType(OrdersIdRatingsPostRequestReasonCategoryEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OrdersIdRatingsPostRequest object, {
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
    required OrdersIdRatingsPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'target':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OrdersIdRatingsPostRequestTargetEnum),
          ) as OrdersIdRatingsPostRequestTargetEnum;
          result.target = valueDes;
          break;
        case r'score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.score = valueDes;
          break;
        case r'comment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.comment = valueDes;
          break;
        case r'reason_category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(OrdersIdRatingsPostRequestReasonCategoryEnum),
          ) as OrdersIdRatingsPostRequestReasonCategoryEnum;
          result.reasonCategory = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrdersIdRatingsPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrdersIdRatingsPostRequestBuilder();
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

class OrdersIdRatingsPostRequestTargetEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'supplier')
  static const OrdersIdRatingsPostRequestTargetEnum supplier =
      _$ordersIdRatingsPostRequestTargetEnum_supplier;
  @BuiltValueEnumConst(wireName: r'driver')
  static const OrdersIdRatingsPostRequestTargetEnum driver =
      _$ordersIdRatingsPostRequestTargetEnum_driver;
  @BuiltValueEnumConst(wireName: r'buyer')
  static const OrdersIdRatingsPostRequestTargetEnum buyer =
      _$ordersIdRatingsPostRequestTargetEnum_buyer;

  static Serializer<OrdersIdRatingsPostRequestTargetEnum> get serializer =>
      _$ordersIdRatingsPostRequestTargetEnumSerializer;

  const OrdersIdRatingsPostRequestTargetEnum._(String name) : super(name);

  static BuiltSet<OrdersIdRatingsPostRequestTargetEnum> get values =>
      _$ordersIdRatingsPostRequestTargetEnumValues;
  static OrdersIdRatingsPostRequestTargetEnum valueOf(String name) =>
      _$ordersIdRatingsPostRequestTargetEnumValueOf(name);
}

class OrdersIdRatingsPostRequestReasonCategoryEnum extends EnumClass {
  /// mandatory for scores 1-2 (BR-20.3)
  @BuiltValueEnumConst(wireName: r'sifat')
  static const OrdersIdRatingsPostRequestReasonCategoryEnum sifat =
      _$ordersIdRatingsPostRequestReasonCategoryEnum_sifat;

  /// mandatory for scores 1-2 (BR-20.3)
  @BuiltValueEnumConst(wireName: r'muddat')
  static const OrdersIdRatingsPostRequestReasonCategoryEnum muddat =
      _$ordersIdRatingsPostRequestReasonCategoryEnum_muddat;

  /// mandatory for scores 1-2 (BR-20.3)
  @BuiltValueEnumConst(wireName: r'muomala')
  static const OrdersIdRatingsPostRequestReasonCategoryEnum muomala =
      _$ordersIdRatingsPostRequestReasonCategoryEnum_muomala;

  /// mandatory for scores 1-2 (BR-20.3)
  @BuiltValueEnumConst(wireName: r'narx')
  static const OrdersIdRatingsPostRequestReasonCategoryEnum narx =
      _$ordersIdRatingsPostRequestReasonCategoryEnum_narx;

  static Serializer<OrdersIdRatingsPostRequestReasonCategoryEnum>
      get serializer =>
          _$ordersIdRatingsPostRequestReasonCategoryEnumSerializer;

  const OrdersIdRatingsPostRequestReasonCategoryEnum._(String name)
      : super(name);

  static BuiltSet<OrdersIdRatingsPostRequestReasonCategoryEnum> get values =>
      _$ordersIdRatingsPostRequestReasonCategoryEnumValues;
  static OrdersIdRatingsPostRequestReasonCategoryEnum valueOf(String name) =>
      _$ordersIdRatingsPostRequestReasonCategoryEnumValueOf(name);
}
