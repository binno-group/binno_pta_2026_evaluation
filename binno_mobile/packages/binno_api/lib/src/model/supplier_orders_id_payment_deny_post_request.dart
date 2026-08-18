//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_orders_id_payment_deny_post_request.g.dart';

/// SupplierOrdersIdPaymentDenyPostRequest
///
/// Properties:
/// * [note]
@BuiltValue()
abstract class SupplierOrdersIdPaymentDenyPostRequest
    implements
        Built<SupplierOrdersIdPaymentDenyPostRequest,
            SupplierOrdersIdPaymentDenyPostRequestBuilder> {
  @BuiltValueField(wireName: r'note')
  String get note;

  SupplierOrdersIdPaymentDenyPostRequest._();

  factory SupplierOrdersIdPaymentDenyPostRequest(
          [void updates(SupplierOrdersIdPaymentDenyPostRequestBuilder b)]) =
      _$SupplierOrdersIdPaymentDenyPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierOrdersIdPaymentDenyPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierOrdersIdPaymentDenyPostRequest> get serializer =>
      _$SupplierOrdersIdPaymentDenyPostRequestSerializer();
}

class _$SupplierOrdersIdPaymentDenyPostRequestSerializer
    implements PrimitiveSerializer<SupplierOrdersIdPaymentDenyPostRequest> {
  @override
  final Iterable<Type> types = const [
    SupplierOrdersIdPaymentDenyPostRequest,
    _$SupplierOrdersIdPaymentDenyPostRequest
  ];

  @override
  final String wireName = r'SupplierOrdersIdPaymentDenyPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierOrdersIdPaymentDenyPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'note';
    yield serializers.serialize(
      object.note,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierOrdersIdPaymentDenyPostRequest object, {
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
    required SupplierOrdersIdPaymentDenyPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierOrdersIdPaymentDenyPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierOrdersIdPaymentDenyPostRequestBuilder();
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
