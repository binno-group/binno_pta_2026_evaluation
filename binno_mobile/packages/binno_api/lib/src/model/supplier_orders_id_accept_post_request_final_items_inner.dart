//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_orders_id_accept_post_request_final_items_inner.g.dart';

/// SupplierOrdersIdAcceptPostRequestFinalItemsInner
///
/// Properties:
/// * [productId]
/// * [qty]
/// * [unitPrice] - tiyin
@BuiltValue()
abstract class SupplierOrdersIdAcceptPostRequestFinalItemsInner
    implements
        Built<SupplierOrdersIdAcceptPostRequestFinalItemsInner,
            SupplierOrdersIdAcceptPostRequestFinalItemsInnerBuilder> {
  @BuiltValueField(wireName: r'product_id')
  String get productId;

  @BuiltValueField(wireName: r'qty')
  num get qty;

  /// tiyin
  @BuiltValueField(wireName: r'unit_price')
  int get unitPrice;

  SupplierOrdersIdAcceptPostRequestFinalItemsInner._();

  factory SupplierOrdersIdAcceptPostRequestFinalItemsInner(
          [void updates(
              SupplierOrdersIdAcceptPostRequestFinalItemsInnerBuilder b)]) =
      _$SupplierOrdersIdAcceptPostRequestFinalItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          SupplierOrdersIdAcceptPostRequestFinalItemsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierOrdersIdAcceptPostRequestFinalItemsInner>
      get serializer =>
          _$SupplierOrdersIdAcceptPostRequestFinalItemsInnerSerializer();
}

class _$SupplierOrdersIdAcceptPostRequestFinalItemsInnerSerializer
    implements
        PrimitiveSerializer<SupplierOrdersIdAcceptPostRequestFinalItemsInner> {
  @override
  final Iterable<Type> types = const [
    SupplierOrdersIdAcceptPostRequestFinalItemsInner,
    _$SupplierOrdersIdAcceptPostRequestFinalItemsInner
  ];

  @override
  final String wireName = r'SupplierOrdersIdAcceptPostRequestFinalItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierOrdersIdAcceptPostRequestFinalItemsInner object, {
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
    yield r'unit_price';
    yield serializers.serialize(
      object.unitPrice,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierOrdersIdAcceptPostRequestFinalItemsInner object, {
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
    required SupplierOrdersIdAcceptPostRequestFinalItemsInnerBuilder result,
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
        case r'unit_price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.unitPrice = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierOrdersIdAcceptPostRequestFinalItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierOrdersIdAcceptPostRequestFinalItemsInnerBuilder();
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
