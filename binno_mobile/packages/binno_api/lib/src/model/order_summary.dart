//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_summary.g.dart';

/// OrderSummary
///
/// Properties:
/// * [id]
/// * [reference]
/// * [status]
/// * [supplierName]
/// * [itemSummary]
/// * [totalAmount] - Integer tiyin (UZS). Floats are forbidden.
/// * [isUrgent]
/// * [updatedAt]
@BuiltValue(instantiable: false)
abstract class OrderSummary {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'reference')
  String? get reference;

  @BuiltValueField(wireName: r'status')
  String? get status;

  @BuiltValueField(wireName: r'supplier_name')
  String? get supplierName;

  @BuiltValueField(wireName: r'item_summary')
  String? get itemSummary;

  /// Integer tiyin (UZS). Floats are forbidden.
  @BuiltValueField(wireName: r'total_amount')
  int? get totalAmount;

  @BuiltValueField(wireName: r'is_urgent')
  bool? get isUrgent;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderSummary> get serializer => _$OrderSummarySerializer();
}

class _$OrderSummarySerializer implements PrimitiveSerializer<OrderSummary> {
  @override
  final Iterable<Type> types = const [OrderSummary];

  @override
  final String wireName = r'OrderSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.reference != null) {
      yield r'reference';
      yield serializers.serialize(
        object.reference,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(String),
      );
    }
    if (object.supplierName != null) {
      yield r'supplier_name';
      yield serializers.serialize(
        object.supplierName,
        specifiedType: const FullType(String),
      );
    }
    if (object.itemSummary != null) {
      yield r'item_summary';
      yield serializers.serialize(
        object.itemSummary,
        specifiedType: const FullType(String),
      );
    }
    if (object.totalAmount != null) {
      yield r'total_amount';
      yield serializers.serialize(
        object.totalAmount,
        specifiedType: const FullType(int),
      );
    }
    if (object.isUrgent != null) {
      yield r'is_urgent';
      yield serializers.serialize(
        object.isUrgent,
        specifiedType: const FullType(bool),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  @override
  OrderSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized,
        specifiedType: FullType($OrderSummary)) as $OrderSummary;
  }
}

/// a concrete implementation of [OrderSummary], since [OrderSummary] is not instantiable
@BuiltValue(instantiable: true)
abstract class $OrderSummary
    implements OrderSummary, Built<$OrderSummary, $OrderSummaryBuilder> {
  $OrderSummary._();

  factory $OrderSummary([void Function($OrderSummaryBuilder)? updates]) =
      _$$OrderSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($OrderSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$OrderSummary> get serializer =>
      _$$OrderSummarySerializer();
}

class _$$OrderSummarySerializer implements PrimitiveSerializer<$OrderSummary> {
  @override
  final Iterable<Type> types = const [$OrderSummary, _$$OrderSummary];

  @override
  final String wireName = r'$OrderSummary';

  @override
  Object serialize(
    Serializers serializers,
    $OrderSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object,
        specifiedType: FullType(OrderSummary))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OrderSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'reference':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reference = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'supplier_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.supplierName = valueDes;
          break;
        case r'item_summary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.itemSummary = valueDes;
          break;
        case r'total_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalAmount = valueDes;
          break;
        case r'is_urgent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isUrgent = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  $OrderSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $OrderSummaryBuilder();
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
