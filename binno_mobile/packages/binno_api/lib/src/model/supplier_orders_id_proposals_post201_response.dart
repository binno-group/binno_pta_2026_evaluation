//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_orders_id_proposals_post201_response.g.dart';

/// SupplierOrdersIdProposalsPost201Response
///
/// Properties:
/// * [proposalId]
/// * [round]
/// * [expiresAt]
@BuiltValue()
abstract class SupplierOrdersIdProposalsPost201Response
    implements
        Built<SupplierOrdersIdProposalsPost201Response,
            SupplierOrdersIdProposalsPost201ResponseBuilder> {
  @BuiltValueField(wireName: r'proposal_id')
  String? get proposalId;

  @BuiltValueField(wireName: r'round')
  int? get round;

  @BuiltValueField(wireName: r'expires_at')
  DateTime? get expiresAt;

  SupplierOrdersIdProposalsPost201Response._();

  factory SupplierOrdersIdProposalsPost201Response(
          [void updates(SupplierOrdersIdProposalsPost201ResponseBuilder b)]) =
      _$SupplierOrdersIdProposalsPost201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierOrdersIdProposalsPost201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierOrdersIdProposalsPost201Response> get serializer =>
      _$SupplierOrdersIdProposalsPost201ResponseSerializer();
}

class _$SupplierOrdersIdProposalsPost201ResponseSerializer
    implements PrimitiveSerializer<SupplierOrdersIdProposalsPost201Response> {
  @override
  final Iterable<Type> types = const [
    SupplierOrdersIdProposalsPost201Response,
    _$SupplierOrdersIdProposalsPost201Response
  ];

  @override
  final String wireName = r'SupplierOrdersIdProposalsPost201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierOrdersIdProposalsPost201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.proposalId != null) {
      yield r'proposal_id';
      yield serializers.serialize(
        object.proposalId,
        specifiedType: const FullType(String),
      );
    }
    if (object.round != null) {
      yield r'round';
      yield serializers.serialize(
        object.round,
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
    SupplierOrdersIdProposalsPost201Response object, {
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
    required SupplierOrdersIdProposalsPost201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'proposal_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.proposalId = valueDes;
          break;
        case r'round':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.round = valueDes;
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
  SupplierOrdersIdProposalsPost201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierOrdersIdProposalsPost201ResponseBuilder();
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
