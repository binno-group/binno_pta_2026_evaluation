//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:binno_api/src/model/problem.dart';
import 'package:built_collection/built_collection.dart';
import 'package:binno_api/src/model/inline_object2_all_of_errors_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'inline_object2.g.dart';

/// InlineObject2
///
/// Properties:
/// * [type]
/// * [title]
/// * [status]
/// * [detail]
/// * [instance]
/// * [errors]
@BuiltValue()
abstract class InlineObject2
    implements Problem, Built<InlineObject2, InlineObject2Builder> {
  @BuiltValueField(wireName: r'errors')
  BuiltList<InlineObject2AllOfErrorsInner>? get errors;

  InlineObject2._();

  factory InlineObject2([void updates(InlineObject2Builder b)]) =
      _$InlineObject2;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InlineObject2Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InlineObject2> get serializer =>
      _$InlineObject2Serializer();
}

class _$InlineObject2Serializer implements PrimitiveSerializer<InlineObject2> {
  @override
  final Iterable<Type> types = const [InlineObject2, _$InlineObject2];

  @override
  final String wireName = r'InlineObject2';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InlineObject2 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.instance != null) {
      yield r'instance';
      yield serializers.serialize(
        object.instance,
        specifiedType: const FullType(String),
      );
    }
    if (object.detail != null) {
      yield r'detail';
      yield serializers.serialize(
        object.detail,
        specifiedType: const FullType(String),
      );
    }
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(String),
      );
    }
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    if (object.errors != null) {
      yield r'errors';
      yield serializers.serialize(
        object.errors,
        specifiedType: const FullType(
            BuiltList, [FullType(InlineObject2AllOfErrorsInner)]),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    InlineObject2 object, {
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
    required InlineObject2Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'instance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.instance = valueDes;
          break;
        case r'detail':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.detail = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.type = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'errors':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(InlineObject2AllOfErrorsInner)]),
          ) as BuiltList<InlineObject2AllOfErrorsInner>;
          result.errors.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InlineObject2 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InlineObject2Builder();
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
