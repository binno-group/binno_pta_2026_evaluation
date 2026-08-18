//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invoice_versions_inner.g.dart';

/// InvoiceVersionsInner
///
/// Properties:
/// * [version]
/// * [status]
@BuiltValue()
abstract class InvoiceVersionsInner
    implements Built<InvoiceVersionsInner, InvoiceVersionsInnerBuilder> {
  @BuiltValueField(wireName: r'version')
  int? get version;

  @BuiltValueField(wireName: r'status')
  String? get status;

  InvoiceVersionsInner._();

  factory InvoiceVersionsInner([void updates(InvoiceVersionsInnerBuilder b)]) =
      _$InvoiceVersionsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InvoiceVersionsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InvoiceVersionsInner> get serializer =>
      _$InvoiceVersionsInnerSerializer();
}

class _$InvoiceVersionsInnerSerializer
    implements PrimitiveSerializer<InvoiceVersionsInner> {
  @override
  final Iterable<Type> types = const [
    InvoiceVersionsInner,
    _$InvoiceVersionsInner
  ];

  @override
  final String wireName = r'InvoiceVersionsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InvoiceVersionsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.version != null) {
      yield r'version';
      yield serializers.serialize(
        object.version,
        specifiedType: const FullType(int),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    InvoiceVersionsInner object, {
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
    required InvoiceVersionsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  InvoiceVersionsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InvoiceVersionsInnerBuilder();
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
