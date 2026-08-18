//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_billing_payment_intent_post200_response.g.dart';

/// SupplierBillingPaymentIntentPost200Response
///
/// Properties:
/// * [amount]
/// * [binnoRequisites]
/// * [referenceCode]
@BuiltValue()
abstract class SupplierBillingPaymentIntentPost200Response
    implements
        Built<SupplierBillingPaymentIntentPost200Response,
            SupplierBillingPaymentIntentPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'amount')
  int? get amount;

  @BuiltValueField(wireName: r'binno_requisites')
  JsonObject? get binnoRequisites;

  @BuiltValueField(wireName: r'reference_code')
  String? get referenceCode;

  SupplierBillingPaymentIntentPost200Response._();

  factory SupplierBillingPaymentIntentPost200Response(
          [void updates(
              SupplierBillingPaymentIntentPost200ResponseBuilder b)]) =
      _$SupplierBillingPaymentIntentPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierBillingPaymentIntentPost200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierBillingPaymentIntentPost200Response>
      get serializer =>
          _$SupplierBillingPaymentIntentPost200ResponseSerializer();
}

class _$SupplierBillingPaymentIntentPost200ResponseSerializer
    implements
        PrimitiveSerializer<SupplierBillingPaymentIntentPost200Response> {
  @override
  final Iterable<Type> types = const [
    SupplierBillingPaymentIntentPost200Response,
    _$SupplierBillingPaymentIntentPost200Response
  ];

  @override
  final String wireName = r'SupplierBillingPaymentIntentPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierBillingPaymentIntentPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.amount != null) {
      yield r'amount';
      yield serializers.serialize(
        object.amount,
        specifiedType: const FullType(int),
      );
    }
    if (object.binnoRequisites != null) {
      yield r'binno_requisites';
      yield serializers.serialize(
        object.binnoRequisites,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.referenceCode != null) {
      yield r'reference_code';
      yield serializers.serialize(
        object.referenceCode,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierBillingPaymentIntentPost200Response object, {
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
    required SupplierBillingPaymentIntentPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.amount = valueDes;
          break;
        case r'binno_requisites':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.binnoRequisites = valueDes;
          break;
        case r'reference_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.referenceCode = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierBillingPaymentIntentPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierBillingPaymentIntentPost200ResponseBuilder();
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
