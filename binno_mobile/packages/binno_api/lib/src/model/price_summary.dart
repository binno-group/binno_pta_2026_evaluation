//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'price_summary.g.dart';

/// PriceSummary
///
/// Properties:
/// * [itemsTotal] - Integer tiyin (UZS). Floats are forbidden.
/// * [logisticsFee] - Integer tiyin (UZS). Floats are forbidden.
/// * [totalEstimate] - Integer tiyin (UZS). Floats are forbidden.
/// * [isEstimate] - true for a range product — the UI shows \"Taxminiy summa\"
@BuiltValue()
abstract class PriceSummary
    implements Built<PriceSummary, PriceSummaryBuilder> {
  /// Integer tiyin (UZS). Floats are forbidden.
  @BuiltValueField(wireName: r'items_total')
  int? get itemsTotal;

  /// Integer tiyin (UZS). Floats are forbidden.
  @BuiltValueField(wireName: r'logistics_fee')
  int? get logisticsFee;

  /// Integer tiyin (UZS). Floats are forbidden.
  @BuiltValueField(wireName: r'total_estimate')
  int? get totalEstimate;

  /// true for a range product — the UI shows \"Taxminiy summa\"
  @BuiltValueField(wireName: r'is_estimate')
  bool? get isEstimate;

  PriceSummary._();

  factory PriceSummary([void updates(PriceSummaryBuilder b)]) = _$PriceSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PriceSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PriceSummary> get serializer => _$PriceSummarySerializer();
}

class _$PriceSummarySerializer implements PrimitiveSerializer<PriceSummary> {
  @override
  final Iterable<Type> types = const [PriceSummary, _$PriceSummary];

  @override
  final String wireName = r'PriceSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PriceSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.itemsTotal != null) {
      yield r'items_total';
      yield serializers.serialize(
        object.itemsTotal,
        specifiedType: const FullType(int),
      );
    }
    if (object.logisticsFee != null) {
      yield r'logistics_fee';
      yield serializers.serialize(
        object.logisticsFee,
        specifiedType: const FullType(int),
      );
    }
    if (object.totalEstimate != null) {
      yield r'total_estimate';
      yield serializers.serialize(
        object.totalEstimate,
        specifiedType: const FullType(int),
      );
    }
    if (object.isEstimate != null) {
      yield r'is_estimate';
      yield serializers.serialize(
        object.isEstimate,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PriceSummary object, {
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
    required PriceSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.itemsTotal = valueDes;
          break;
        case r'logistics_fee':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.logisticsFee = valueDes;
          break;
        case r'total_estimate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalEstimate = valueDes;
          break;
        case r'is_estimate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isEstimate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PriceSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PriceSummaryBuilder();
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
