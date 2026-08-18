//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_billing_summary_get200_response.g.dart';

/// SupplierBillingSummaryGet200Response
///
/// Properties:
/// * [accruedTotal]
/// * [paidTotal]
/// * [outstanding]
/// * [creditLimit]
/// * [utilizationPct]
/// * [blocked]
@BuiltValue()
abstract class SupplierBillingSummaryGet200Response
    implements
        Built<SupplierBillingSummaryGet200Response,
            SupplierBillingSummaryGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'accrued_total')
  int? get accruedTotal;

  @BuiltValueField(wireName: r'paid_total')
  int? get paidTotal;

  @BuiltValueField(wireName: r'outstanding')
  int? get outstanding;

  @BuiltValueField(wireName: r'credit_limit')
  int? get creditLimit;

  @BuiltValueField(wireName: r'utilization_pct')
  num? get utilizationPct;

  @BuiltValueField(wireName: r'blocked')
  bool? get blocked;

  SupplierBillingSummaryGet200Response._();

  factory SupplierBillingSummaryGet200Response(
          [void updates(SupplierBillingSummaryGet200ResponseBuilder b)]) =
      _$SupplierBillingSummaryGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierBillingSummaryGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierBillingSummaryGet200Response> get serializer =>
      _$SupplierBillingSummaryGet200ResponseSerializer();
}

class _$SupplierBillingSummaryGet200ResponseSerializer
    implements PrimitiveSerializer<SupplierBillingSummaryGet200Response> {
  @override
  final Iterable<Type> types = const [
    SupplierBillingSummaryGet200Response,
    _$SupplierBillingSummaryGet200Response
  ];

  @override
  final String wireName = r'SupplierBillingSummaryGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierBillingSummaryGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.accruedTotal != null) {
      yield r'accrued_total';
      yield serializers.serialize(
        object.accruedTotal,
        specifiedType: const FullType(int),
      );
    }
    if (object.paidTotal != null) {
      yield r'paid_total';
      yield serializers.serialize(
        object.paidTotal,
        specifiedType: const FullType(int),
      );
    }
    if (object.outstanding != null) {
      yield r'outstanding';
      yield serializers.serialize(
        object.outstanding,
        specifiedType: const FullType(int),
      );
    }
    if (object.creditLimit != null) {
      yield r'credit_limit';
      yield serializers.serialize(
        object.creditLimit,
        specifiedType: const FullType(int),
      );
    }
    if (object.utilizationPct != null) {
      yield r'utilization_pct';
      yield serializers.serialize(
        object.utilizationPct,
        specifiedType: const FullType(num),
      );
    }
    if (object.blocked != null) {
      yield r'blocked';
      yield serializers.serialize(
        object.blocked,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierBillingSummaryGet200Response object, {
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
    required SupplierBillingSummaryGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accrued_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.accruedTotal = valueDes;
          break;
        case r'paid_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.paidTotal = valueDes;
          break;
        case r'outstanding':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.outstanding = valueDes;
          break;
        case r'credit_limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.creditLimit = valueDes;
          break;
        case r'utilization_pct':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.utilizationPct = valueDes;
          break;
        case r'blocked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.blocked = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierBillingSummaryGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierBillingSummaryGet200ResponseBuilder();
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
