//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:binno_api/src/model/proposal_input_items_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'proposal_input.g.dart';

/// ProposalInput
///
/// Properties:
/// * [items]
/// * [prepDays]
/// * [note] - phone numbers are masked (BR-09.6)
@BuiltValue()
abstract class ProposalInput
    implements Built<ProposalInput, ProposalInputBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ProposalInputItemsInner> get items;

  @BuiltValueField(wireName: r'prep_days')
  int get prepDays;

  /// phone numbers are masked (BR-09.6)
  @BuiltValueField(wireName: r'note')
  String? get note;

  ProposalInput._();

  factory ProposalInput([void updates(ProposalInputBuilder b)]) =
      _$ProposalInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProposalInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProposalInput> get serializer =>
      _$ProposalInputSerializer();
}

class _$ProposalInputSerializer implements PrimitiveSerializer<ProposalInput> {
  @override
  final Iterable<Type> types = const [ProposalInput, _$ProposalInput];

  @override
  final String wireName = r'ProposalInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProposalInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType:
          const FullType(BuiltList, [FullType(ProposalInputItemsInner)]),
    );
    yield r'prep_days';
    yield serializers.serialize(
      object.prepDays,
      specifiedType: const FullType(int),
    );
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ProposalInput object, {
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
    required ProposalInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(ProposalInputItemsInner)]),
          ) as BuiltList<ProposalInputItemsInner>;
          result.items.replace(valueDes);
          break;
        case r'prep_days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.prepDays = valueDes;
          break;
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
  ProposalInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProposalInputBuilder();
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
