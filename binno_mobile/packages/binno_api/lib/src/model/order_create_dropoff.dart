//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_create_dropoff.g.dart';

/// OrderCreateDropoff
///
/// Properties:
/// * [lat]
/// * [lng]
/// * [address]
@BuiltValue()
abstract class OrderCreateDropoff
    implements Built<OrderCreateDropoff, OrderCreateDropoffBuilder> {
  @BuiltValueField(wireName: r'lat')
  num get lat;

  @BuiltValueField(wireName: r'lng')
  num get lng;

  @BuiltValueField(wireName: r'address')
  String get address;

  OrderCreateDropoff._();

  factory OrderCreateDropoff([void updates(OrderCreateDropoffBuilder b)]) =
      _$OrderCreateDropoff;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderCreateDropoffBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderCreateDropoff> get serializer =>
      _$OrderCreateDropoffSerializer();
}

class _$OrderCreateDropoffSerializer
    implements PrimitiveSerializer<OrderCreateDropoff> {
  @override
  final Iterable<Type> types = const [OrderCreateDropoff, _$OrderCreateDropoff];

  @override
  final String wireName = r'OrderCreateDropoff';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderCreateDropoff object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'lat';
    yield serializers.serialize(
      object.lat,
      specifiedType: const FullType(num),
    );
    yield r'lng';
    yield serializers.serialize(
      object.lng,
      specifiedType: const FullType(num),
    );
    yield r'address';
    yield serializers.serialize(
      object.address,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderCreateDropoff object, {
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
    required OrderCreateDropoffBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.lat = valueDes;
          break;
        case r'lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.lng = valueDes;
          break;
        case r'address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.address = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrderCreateDropoff deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderCreateDropoffBuilder();
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
