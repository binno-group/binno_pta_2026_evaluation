//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'proposal_input_items_inner.g.dart';

/// ProposalInputItemsInner
///
/// Properties:
/// * [productId]
/// * [unitPrice] - Integer tiyin (UZS). Floats are forbidden.
@BuiltValue()
abstract class ProposalInputItemsInner
    implements Built<ProposalInputItemsInner, ProposalInputItemsInnerBuilder> {
  @BuiltValueField(wireName: r'product_id')
  String get productId;

  /// Integer tiyin (UZS). Floats are forbidden.
  @BuiltValueField(wireName: r'unit_price')
  int get unitPrice;

  ProposalInputItemsInner._();

  factory ProposalInputItemsInner(
          [void updates(ProposalInputItemsInnerBuilder b)]) =
      _$ProposalInputItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProposalInputItemsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProposalInputItemsInner> get serializer =>
      _$ProposalInputItemsInnerSerializer();
}

class _$ProposalInputItemsInnerSerializer
    implements PrimitiveSerializer<ProposalInputItemsInner> {
  @override
  final Iterable<Type> types = const [
    ProposalInputItemsInner,
    _$ProposalInputItemsInner
  ];

  @override
  final String wireName = r'ProposalInputItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProposalInputItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product_id';
    yield serializers.serialize(
      object.productId,
      specifiedType: const FullType(String),
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
    ProposalInputItemsInner object, {
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
    required ProposalInputItemsInnerBuilder result,
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
  ProposalInputItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProposalInputItemsInnerBuilder();
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
