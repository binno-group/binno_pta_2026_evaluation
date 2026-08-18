//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_detail_all_of_events.g.dart';

/// OrderDetailAllOfEvents
///
/// Properties:
/// * [fromStatus]
/// * [toStatus]
/// * [actorRole]
/// * [createdAt]
/// * [photoUrl]
@BuiltValue()
abstract class OrderDetailAllOfEvents
    implements Built<OrderDetailAllOfEvents, OrderDetailAllOfEventsBuilder> {
  @BuiltValueField(wireName: r'from_status')
  String? get fromStatus;

  @BuiltValueField(wireName: r'to_status')
  String? get toStatus;

  @BuiltValueField(wireName: r'actor_role')
  String? get actorRole;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'photo_url')
  String? get photoUrl;

  OrderDetailAllOfEvents._();

  factory OrderDetailAllOfEvents(
          [void updates(OrderDetailAllOfEventsBuilder b)]) =
      _$OrderDetailAllOfEvents;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderDetailAllOfEventsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderDetailAllOfEvents> get serializer =>
      _$OrderDetailAllOfEventsSerializer();
}

class _$OrderDetailAllOfEventsSerializer
    implements PrimitiveSerializer<OrderDetailAllOfEvents> {
  @override
  final Iterable<Type> types = const [
    OrderDetailAllOfEvents,
    _$OrderDetailAllOfEvents
  ];

  @override
  final String wireName = r'OrderDetailAllOfEvents';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderDetailAllOfEvents object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.fromStatus != null) {
      yield r'from_status';
      yield serializers.serialize(
        object.fromStatus,
        specifiedType: const FullType(String),
      );
    }
    if (object.toStatus != null) {
      yield r'to_status';
      yield serializers.serialize(
        object.toStatus,
        specifiedType: const FullType(String),
      );
    }
    if (object.actorRole != null) {
      yield r'actor_role';
      yield serializers.serialize(
        object.actorRole,
        specifiedType: const FullType(String),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.photoUrl != null) {
      yield r'photo_url';
      yield serializers.serialize(
        object.photoUrl,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderDetailAllOfEvents object, {
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
    required OrderDetailAllOfEventsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'from_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fromStatus = valueDes;
          break;
        case r'to_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.toStatus = valueDes;
          break;
        case r'actor_role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.actorRole = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'photo_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.photoUrl = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrderDetailAllOfEvents deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderDetailAllOfEventsBuilder();
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
