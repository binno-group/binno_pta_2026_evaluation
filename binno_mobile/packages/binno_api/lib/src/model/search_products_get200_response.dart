//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:binno_api/src/model/product_card.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_products_get200_response.g.dart';

/// SearchProductsGet200Response
///
/// Properties:
/// * [items]
/// * [nextCursor]
/// * [totalEstimate]
@BuiltValue()
abstract class SearchProductsGet200Response
    implements
        Built<SearchProductsGet200Response,
            SearchProductsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ProductCard>? get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  @BuiltValueField(wireName: r'total_estimate')
  int? get totalEstimate;

  SearchProductsGet200Response._();

  factory SearchProductsGet200Response(
          [void updates(SearchProductsGet200ResponseBuilder b)]) =
      _$SearchProductsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchProductsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchProductsGet200Response> get serializer =>
      _$SearchProductsGet200ResponseSerializer();
}

class _$SearchProductsGet200ResponseSerializer
    implements PrimitiveSerializer<SearchProductsGet200Response> {
  @override
  final Iterable<Type> types = const [
    SearchProductsGet200Response,
    _$SearchProductsGet200Response
  ];

  @override
  final String wireName = r'SearchProductsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchProductsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.items != null) {
      yield r'items';
      yield serializers.serialize(
        object.items,
        specifiedType: const FullType(BuiltList, [FullType(ProductCard)]),
      );
    }
    if (object.nextCursor != null) {
      yield r'next_cursor';
      yield serializers.serialize(
        object.nextCursor,
        specifiedType: const FullType(String),
      );
    }
    if (object.totalEstimate != null) {
      yield r'total_estimate';
      yield serializers.serialize(
        object.totalEstimate,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SearchProductsGet200Response object, {
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
    required SearchProductsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ProductCard)]),
          ) as BuiltList<ProductCard>;
          result.items.replace(valueDes);
          break;
        case r'next_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nextCursor = valueDes;
          break;
        case r'total_estimate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalEstimate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SearchProductsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchProductsGet200ResponseBuilder();
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
