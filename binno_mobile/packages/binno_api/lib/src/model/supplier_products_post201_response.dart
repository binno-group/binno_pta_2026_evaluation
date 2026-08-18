//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_products_post201_response.g.dart';

/// SupplierProductsPost201Response
///
/// Properties:
/// * [productId]
/// * [status]
@BuiltValue()
abstract class SupplierProductsPost201Response
    implements
        Built<SupplierProductsPost201Response,
            SupplierProductsPost201ResponseBuilder> {
  @BuiltValueField(wireName: r'product_id')
  String? get productId;

  @BuiltValueField(wireName: r'status')
  String? get status;

  SupplierProductsPost201Response._();

  factory SupplierProductsPost201Response(
          [void updates(SupplierProductsPost201ResponseBuilder b)]) =
      _$SupplierProductsPost201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierProductsPost201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierProductsPost201Response> get serializer =>
      _$SupplierProductsPost201ResponseSerializer();
}

class _$SupplierProductsPost201ResponseSerializer
    implements PrimitiveSerializer<SupplierProductsPost201Response> {
  @override
  final Iterable<Type> types = const [
    SupplierProductsPost201Response,
    _$SupplierProductsPost201Response
  ];

  @override
  final String wireName = r'SupplierProductsPost201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierProductsPost201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.productId != null) {
      yield r'product_id';
      yield serializers.serialize(
        object.productId,
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
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierProductsPost201Response object, {
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
    required SupplierProductsPost201ResponseBuilder result,
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
  SupplierProductsPost201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierProductsPost201ResponseBuilder();
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
