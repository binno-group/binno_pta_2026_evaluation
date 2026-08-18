//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_offer.g.dart';

/// DriverOffer
///
/// Properties:
/// * [id]
/// * [mode]
/// * [pickupAddress]
/// * [dropoffAddress]
/// * [cargoClass]
/// * [deliveryFee] - Integer tiyin (UZS). Floats are forbidden.
/// * [driverShare] - Integer tiyin (UZS). Floats are forbidden.
/// * [expiresAt]
@BuiltValue()
abstract class DriverOffer implements Built<DriverOffer, DriverOfferBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'mode')
  DriverOfferModeEnum? get mode;
  // enum modeEnum {  classic,  urgent,  };

  @BuiltValueField(wireName: r'pickup_address')
  String? get pickupAddress;

  @BuiltValueField(wireName: r'dropoff_address')
  String? get dropoffAddress;

  @BuiltValueField(wireName: r'cargo_class')
  String? get cargoClass;

  /// Integer tiyin (UZS). Floats are forbidden.
  @BuiltValueField(wireName: r'delivery_fee')
  int? get deliveryFee;

  /// Integer tiyin (UZS). Floats are forbidden.
  @BuiltValueField(wireName: r'driver_share')
  int? get driverShare;

  @BuiltValueField(wireName: r'expires_at')
  DateTime? get expiresAt;

  DriverOffer._();

  factory DriverOffer([void updates(DriverOfferBuilder b)]) = _$DriverOffer;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverOfferBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverOffer> get serializer => _$DriverOfferSerializer();
}

class _$DriverOfferSerializer implements PrimitiveSerializer<DriverOffer> {
  @override
  final Iterable<Type> types = const [DriverOffer, _$DriverOffer];

  @override
  final String wireName = r'DriverOffer';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverOffer object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.mode != null) {
      yield r'mode';
      yield serializers.serialize(
        object.mode,
        specifiedType: const FullType(DriverOfferModeEnum),
      );
    }
    if (object.pickupAddress != null) {
      yield r'pickup_address';
      yield serializers.serialize(
        object.pickupAddress,
        specifiedType: const FullType(String),
      );
    }
    if (object.dropoffAddress != null) {
      yield r'dropoff_address';
      yield serializers.serialize(
        object.dropoffAddress,
        specifiedType: const FullType(String),
      );
    }
    if (object.cargoClass != null) {
      yield r'cargo_class';
      yield serializers.serialize(
        object.cargoClass,
        specifiedType: const FullType(String),
      );
    }
    if (object.deliveryFee != null) {
      yield r'delivery_fee';
      yield serializers.serialize(
        object.deliveryFee,
        specifiedType: const FullType(int),
      );
    }
    if (object.driverShare != null) {
      yield r'driver_share';
      yield serializers.serialize(
        object.driverShare,
        specifiedType: const FullType(int),
      );
    }
    if (object.expiresAt != null) {
      yield r'expires_at';
      yield serializers.serialize(
        object.expiresAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverOffer object, {
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
    required DriverOfferBuilder result,
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
        case r'mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DriverOfferModeEnum),
          ) as DriverOfferModeEnum;
          result.mode = valueDes;
          break;
        case r'pickup_address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pickupAddress = valueDes;
          break;
        case r'dropoff_address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dropoffAddress = valueDes;
          break;
        case r'cargo_class':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cargoClass = valueDes;
          break;
        case r'delivery_fee':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.deliveryFee = valueDes;
          break;
        case r'driver_share':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.driverShare = valueDes;
          break;
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DriverOffer deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverOfferBuilder();
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

class DriverOfferModeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'classic')
  static const DriverOfferModeEnum classic = _$driverOfferModeEnum_classic;
  @BuiltValueEnumConst(wireName: r'urgent')
  static const DriverOfferModeEnum urgent = _$driverOfferModeEnum_urgent;

  static Serializer<DriverOfferModeEnum> get serializer =>
      _$driverOfferModeEnumSerializer;

  const DriverOfferModeEnum._(String name) : super(name);

  static BuiltSet<DriverOfferModeEnum> get values =>
      _$driverOfferModeEnumValues;
  static DriverOfferModeEnum valueOf(String name) =>
      _$driverOfferModeEnumValueOf(name);
}
