//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'inline_object2_all_of_errors_inner.g.dart';

/// InlineObject2AllOfErrorsInner
///
/// Properties:
/// * [field]
/// * [message]
@BuiltValue()
abstract class InlineObject2AllOfErrorsInner
    implements
        Built<InlineObject2AllOfErrorsInner,
            InlineObject2AllOfErrorsInnerBuilder> {
  @BuiltValueField(wireName: r'field')
  String? get field;

  @BuiltValueField(wireName: r'message')
  String? get message;

  InlineObject2AllOfErrorsInner._();

  factory InlineObject2AllOfErrorsInner(
          [void updates(InlineObject2AllOfErrorsInnerBuilder b)]) =
      _$InlineObject2AllOfErrorsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InlineObject2AllOfErrorsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InlineObject2AllOfErrorsInner> get serializer =>
      _$InlineObject2AllOfErrorsInnerSerializer();
}

class _$InlineObject2AllOfErrorsInnerSerializer
    implements PrimitiveSerializer<InlineObject2AllOfErrorsInner> {
  @override
  final Iterable<Type> types = const [
    InlineObject2AllOfErrorsInner,
    _$InlineObject2AllOfErrorsInner
  ];

  @override
  final String wireName = r'InlineObject2AllOfErrorsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InlineObject2AllOfErrorsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.field != null) {
      yield r'field';
      yield serializers.serialize(
        object.field,
        specifiedType: const FullType(String),
      );
    }
    if (object.message != null) {
      yield r'message';
      yield serializers.serialize(
        object.message,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    InlineObject2AllOfErrorsInner object, {
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
    required InlineObject2AllOfErrorsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'field':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.field = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InlineObject2AllOfErrorsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InlineObject2AllOfErrorsInnerBuilder();
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
