//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:binno_api/src/model/supplier_orders_id_accept_post_request_final_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_orders_id_accept_post_request.g.dart';

/// SupplierOrdersIdAcceptPostRequest
///
/// Properties:
/// * [finalItems]
/// * [prepTimeEstimate] - days
@BuiltValue()
abstract class SupplierOrdersIdAcceptPostRequest
    implements
        Built<SupplierOrdersIdAcceptPostRequest,
            SupplierOrdersIdAcceptPostRequestBuilder> {
  @BuiltValueField(wireName: r'final_items')
  BuiltList<SupplierOrdersIdAcceptPostRequestFinalItemsInner> get finalItems;

  /// days
  @BuiltValueField(wireName: r'prep_time_estimate')
  int? get prepTimeEstimate;

  SupplierOrdersIdAcceptPostRequest._();

  factory SupplierOrdersIdAcceptPostRequest(
          [void updates(SupplierOrdersIdAcceptPostRequestBuilder b)]) =
      _$SupplierOrdersIdAcceptPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierOrdersIdAcceptPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierOrdersIdAcceptPostRequest> get serializer =>
      _$SupplierOrdersIdAcceptPostRequestSerializer();
}

class _$SupplierOrdersIdAcceptPostRequestSerializer
    implements PrimitiveSerializer<SupplierOrdersIdAcceptPostRequest> {
  @override
  final Iterable<Type> types = const [
    SupplierOrdersIdAcceptPostRequest,
    _$SupplierOrdersIdAcceptPostRequest
  ];

  @override
  final String wireName = r'SupplierOrdersIdAcceptPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierOrdersIdAcceptPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'final_items';
    yield serializers.serialize(
      object.finalItems,
      specifiedType: const FullType(BuiltList,
          [FullType(SupplierOrdersIdAcceptPostRequestFinalItemsInner)]),
    );
    if (object.prepTimeEstimate != null) {
      yield r'prep_time_estimate';
      yield serializers.serialize(
        object.prepTimeEstimate,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierOrdersIdAcceptPostRequest object, {
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
    required SupplierOrdersIdAcceptPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'final_items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(SupplierOrdersIdAcceptPostRequestFinalItemsInner)]),
          ) as BuiltList<SupplierOrdersIdAcceptPostRequestFinalItemsInner>;
          result.finalItems.replace(valueDes);
          break;
        case r'prep_time_estimate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.prepTimeEstimate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierOrdersIdAcceptPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierOrdersIdAcceptPostRequestBuilder();
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
