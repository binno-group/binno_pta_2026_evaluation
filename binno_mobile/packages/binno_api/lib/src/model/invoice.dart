//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:binno_api/src/model/invoice_versions_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invoice.g.dart';

/// Invoice
///
/// Properties:
/// * [invoiceNo]
/// * [version]
/// * [status]
/// * [amount] - Integer tiyin (UZS). Floats are forbidden.
/// * [pdfUrl]
/// * [expiresAt]
/// * [versions]
@BuiltValue()
abstract class Invoice implements Built<Invoice, InvoiceBuilder> {
  @BuiltValueField(wireName: r'invoice_no')
  String? get invoiceNo;

  @BuiltValueField(wireName: r'version')
  int? get version;

  @BuiltValueField(wireName: r'status')
  InvoiceStatusEnum? get status;
  // enum statusEnum {  active,  paid,  voided,  expired,  };

  /// Integer tiyin (UZS). Floats are forbidden.
  @BuiltValueField(wireName: r'amount')
  int? get amount;

  @BuiltValueField(wireName: r'pdf_url')
  String? get pdfUrl;

  @BuiltValueField(wireName: r'expires_at')
  DateTime? get expiresAt;

  @BuiltValueField(wireName: r'versions')
  BuiltList<InvoiceVersionsInner>? get versions;

  Invoice._();

  factory Invoice([void updates(InvoiceBuilder b)]) = _$Invoice;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InvoiceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Invoice> get serializer => _$InvoiceSerializer();
}

class _$InvoiceSerializer implements PrimitiveSerializer<Invoice> {
  @override
  final Iterable<Type> types = const [Invoice, _$Invoice];

  @override
  final String wireName = r'Invoice';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Invoice object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.invoiceNo != null) {
      yield r'invoice_no';
      yield serializers.serialize(
        object.invoiceNo,
        specifiedType: const FullType(String),
      );
    }
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
        specifiedType: const FullType(InvoiceStatusEnum),
      );
    }
    if (object.amount != null) {
      yield r'amount';
      yield serializers.serialize(
        object.amount,
        specifiedType: const FullType(int),
      );
    }
    if (object.pdfUrl != null) {
      yield r'pdf_url';
      yield serializers.serialize(
        object.pdfUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.expiresAt != null) {
      yield r'expires_at';
      yield serializers.serialize(
        object.expiresAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.versions != null) {
      yield r'versions';
      yield serializers.serialize(
        object.versions,
        specifiedType:
            const FullType(BuiltList, [FullType(InvoiceVersionsInner)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Invoice object, {
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
    required InvoiceBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'invoice_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.invoiceNo = valueDes;
          break;
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
            specifiedType: const FullType(InvoiceStatusEnum),
          ) as InvoiceStatusEnum;
          result.status = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.amount = valueDes;
          break;
        case r'pdf_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pdfUrl = valueDes;
          break;
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'versions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(InvoiceVersionsInner)]),
          ) as BuiltList<InvoiceVersionsInner>;
          result.versions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Invoice deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InvoiceBuilder();
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

class InvoiceStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const InvoiceStatusEnum active = _$invoiceStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'paid')
  static const InvoiceStatusEnum paid = _$invoiceStatusEnum_paid;
  @BuiltValueEnumConst(wireName: r'voided')
  static const InvoiceStatusEnum voided = _$invoiceStatusEnum_voided;
  @BuiltValueEnumConst(wireName: r'expired')
  static const InvoiceStatusEnum expired = _$invoiceStatusEnum_expired;

  static Serializer<InvoiceStatusEnum> get serializer =>
      _$invoiceStatusEnumSerializer;

  const InvoiceStatusEnum._(String name) : super(name);

  static BuiltSet<InvoiceStatusEnum> get values => _$invoiceStatusEnumValues;
  static InvoiceStatusEnum valueOf(String name) =>
      _$invoiceStatusEnumValueOf(name);
}
