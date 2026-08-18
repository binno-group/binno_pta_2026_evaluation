// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const InvoiceStatusEnum _$invoiceStatusEnum_active =
    const InvoiceStatusEnum._('active');
const InvoiceStatusEnum _$invoiceStatusEnum_paid =
    const InvoiceStatusEnum._('paid');
const InvoiceStatusEnum _$invoiceStatusEnum_voided =
    const InvoiceStatusEnum._('voided');
const InvoiceStatusEnum _$invoiceStatusEnum_expired =
    const InvoiceStatusEnum._('expired');

InvoiceStatusEnum _$invoiceStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$invoiceStatusEnum_active;
    case 'paid':
      return _$invoiceStatusEnum_paid;
    case 'voided':
      return _$invoiceStatusEnum_voided;
    case 'expired':
      return _$invoiceStatusEnum_expired;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<InvoiceStatusEnum> _$invoiceStatusEnumValues =
    BuiltSet<InvoiceStatusEnum>(const <InvoiceStatusEnum>[
  _$invoiceStatusEnum_active,
  _$invoiceStatusEnum_paid,
  _$invoiceStatusEnum_voided,
  _$invoiceStatusEnum_expired,
]);

Serializer<InvoiceStatusEnum> _$invoiceStatusEnumSerializer =
    _$InvoiceStatusEnumSerializer();

class _$InvoiceStatusEnumSerializer
    implements PrimitiveSerializer<InvoiceStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'paid': 'paid',
    'voided': 'voided',
    'expired': 'expired',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'paid': 'paid',
    'voided': 'voided',
    'expired': 'expired',
  };

  @override
  final Iterable<Type> types = const <Type>[InvoiceStatusEnum];
  @override
  final String wireName = 'InvoiceStatusEnum';

  @override
  Object serialize(Serializers serializers, InvoiceStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  InvoiceStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      InvoiceStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Invoice extends Invoice {
  @override
  final String? invoiceNo;
  @override
  final int? version;
  @override
  final InvoiceStatusEnum? status;
  @override
  final int? amount;
  @override
  final String? pdfUrl;
  @override
  final DateTime? expiresAt;
  @override
  final BuiltList<InvoiceVersionsInner>? versions;

  factory _$Invoice([void Function(InvoiceBuilder)? updates]) =>
      (InvoiceBuilder()..update(updates))._build();

  _$Invoice._(
      {this.invoiceNo,
      this.version,
      this.status,
      this.amount,
      this.pdfUrl,
      this.expiresAt,
      this.versions})
      : super._();
  @override
  Invoice rebuild(void Function(InvoiceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InvoiceBuilder toBuilder() => InvoiceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Invoice &&
        invoiceNo == other.invoiceNo &&
        version == other.version &&
        status == other.status &&
        amount == other.amount &&
        pdfUrl == other.pdfUrl &&
        expiresAt == other.expiresAt &&
        versions == other.versions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, invoiceNo.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, pdfUrl.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, versions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Invoice')
          ..add('invoiceNo', invoiceNo)
          ..add('version', version)
          ..add('status', status)
          ..add('amount', amount)
          ..add('pdfUrl', pdfUrl)
          ..add('expiresAt', expiresAt)
          ..add('versions', versions))
        .toString();
  }
}

class InvoiceBuilder implements Builder<Invoice, InvoiceBuilder> {
  _$Invoice? _$v;

  String? _invoiceNo;
  String? get invoiceNo => _$this._invoiceNo;
  set invoiceNo(String? invoiceNo) => _$this._invoiceNo = invoiceNo;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  InvoiceStatusEnum? _status;
  InvoiceStatusEnum? get status => _$this._status;
  set status(InvoiceStatusEnum? status) => _$this._status = status;

  int? _amount;
  int? get amount => _$this._amount;
  set amount(int? amount) => _$this._amount = amount;

  String? _pdfUrl;
  String? get pdfUrl => _$this._pdfUrl;
  set pdfUrl(String? pdfUrl) => _$this._pdfUrl = pdfUrl;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  ListBuilder<InvoiceVersionsInner>? _versions;
  ListBuilder<InvoiceVersionsInner> get versions =>
      _$this._versions ??= ListBuilder<InvoiceVersionsInner>();
  set versions(ListBuilder<InvoiceVersionsInner>? versions) =>
      _$this._versions = versions;

  InvoiceBuilder() {
    Invoice._defaults(this);
  }

  InvoiceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _invoiceNo = $v.invoiceNo;
      _version = $v.version;
      _status = $v.status;
      _amount = $v.amount;
      _pdfUrl = $v.pdfUrl;
      _expiresAt = $v.expiresAt;
      _versions = $v.versions?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Invoice other) {
    _$v = other as _$Invoice;
  }

  @override
  void update(void Function(InvoiceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Invoice build() => _build();

  _$Invoice _build() {
    _$Invoice _$result;
    try {
      _$result = _$v ??
          _$Invoice._(
            invoiceNo: invoiceNo,
            version: version,
            status: status,
            amount: amount,
            pdfUrl: pdfUrl,
            expiresAt: expiresAt,
            versions: _versions?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'versions';
        _versions?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Invoice', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
