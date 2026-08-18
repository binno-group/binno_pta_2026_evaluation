//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_orders_id_reject_post_request.g.dart';

/// SupplierOrdersIdRejectPostRequest
///
/// Properties:
/// * [reason]
@BuiltValue()
abstract class SupplierOrdersIdRejectPostRequest
    implements
        Built<SupplierOrdersIdRejectPostRequest,
            SupplierOrdersIdRejectPostRequestBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  SupplierOrdersIdRejectPostRequest._();

  factory SupplierOrdersIdRejectPostRequest(
          [void updates(SupplierOrdersIdRejectPostRequestBuilder b)]) =
      _$SupplierOrdersIdRejectPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierOrdersIdRejectPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierOrdersIdRejectPostRequest> get serializer =>
      _$SupplierOrdersIdRejectPostRequestSerializer();
}

class _$SupplierOrdersIdRejectPostRequestSerializer
    implements PrimitiveSerializer<SupplierOrdersIdRejectPostRequest> {
  @override
  final Iterable<Type> types = const [
    SupplierOrdersIdRejectPostRequest,
    _$SupplierOrdersIdRejectPostRequest
  ];

  @override
  final String wireName = r'SupplierOrdersIdRejectPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierOrdersIdRejectPostRequest object, {
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
    SupplierOrdersIdRejectPostRequest object, {
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
    required SupplierOrdersIdRejectPostRequestBuilder result,
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
  SupplierOrdersIdRejectPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierOrdersIdRejectPostRequestBuilder();
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
