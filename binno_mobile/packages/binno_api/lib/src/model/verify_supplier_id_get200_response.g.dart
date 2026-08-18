// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_supplier_id_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const VerifySupplierIdGet200ResponseLevelEnum
    _$verifySupplierIdGet200ResponseLevelEnum_basic =
    const VerifySupplierIdGet200ResponseLevelEnum._('basic');
const VerifySupplierIdGet200ResponseLevelEnum
    _$verifySupplierIdGet200ResponseLevelEnum_advanced =
    const VerifySupplierIdGet200ResponseLevelEnum._('advanced');

VerifySupplierIdGet200ResponseLevelEnum
    _$verifySupplierIdGet200ResponseLevelEnumValueOf(String name) {
  switch (name) {
    case 'basic':
      return _$verifySupplierIdGet200ResponseLevelEnum_basic;
    case 'advanced':
      return _$verifySupplierIdGet200ResponseLevelEnum_advanced;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<VerifySupplierIdGet200ResponseLevelEnum>
    _$verifySupplierIdGet200ResponseLevelEnumValues = BuiltSet<
        VerifySupplierIdGet200ResponseLevelEnum>(const <VerifySupplierIdGet200ResponseLevelEnum>[
  _$verifySupplierIdGet200ResponseLevelEnum_basic,
  _$verifySupplierIdGet200ResponseLevelEnum_advanced,
]);

Serializer<VerifySupplierIdGet200ResponseLevelEnum>
    _$verifySupplierIdGet200ResponseLevelEnumSerializer =
    _$VerifySupplierIdGet200ResponseLevelEnumSerializer();

class _$VerifySupplierIdGet200ResponseLevelEnumSerializer
    implements PrimitiveSerializer<VerifySupplierIdGet200ResponseLevelEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'basic': 'basic',
    'advanced': 'advanced',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'basic': 'basic',
    'advanced': 'advanced',
  };

  @override
  final Iterable<Type> types = const <Type>[
    VerifySupplierIdGet200ResponseLevelEnum
  ];
  @override
  final String wireName = 'VerifySupplierIdGet200ResponseLevelEnum';

  @override
  Object serialize(Serializers serializers,
          VerifySupplierIdGet200ResponseLevelEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  VerifySupplierIdGet200ResponseLevelEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      VerifySupplierIdGet200ResponseLevelEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$VerifySupplierIdGet200Response extends VerifySupplierIdGet200Response {
  @override
  final String? legalName;
  @override
  final String? stirMasked;
  @override
  final VerifySupplierIdGet200ResponseLevelEnum? level;
  @override
  final DateTime? verifiedAt;
  @override
  final DateTime? validUntil;

  factory _$VerifySupplierIdGet200Response(
          [void Function(VerifySupplierIdGet200ResponseBuilder)? updates]) =>
      (VerifySupplierIdGet200ResponseBuilder()..update(updates))._build();

  _$VerifySupplierIdGet200Response._(
      {this.legalName,
      this.stirMasked,
      this.level,
      this.verifiedAt,
      this.validUntil})
      : super._();
  @override
  VerifySupplierIdGet200Response rebuild(
          void Function(VerifySupplierIdGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VerifySupplierIdGet200ResponseBuilder toBuilder() =>
      VerifySupplierIdGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VerifySupplierIdGet200Response &&
        legalName == other.legalName &&
        stirMasked == other.stirMasked &&
        level == other.level &&
        verifiedAt == other.verifiedAt &&
        validUntil == other.validUntil;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, legalName.hashCode);
    _$hash = $jc(_$hash, stirMasked.hashCode);
    _$hash = $jc(_$hash, level.hashCode);
    _$hash = $jc(_$hash, verifiedAt.hashCode);
    _$hash = $jc(_$hash, validUntil.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VerifySupplierIdGet200Response')
          ..add('legalName', legalName)
          ..add('stirMasked', stirMasked)
          ..add('level', level)
          ..add('verifiedAt', verifiedAt)
          ..add('validUntil', validUntil))
        .toString();
  }
}

class VerifySupplierIdGet200ResponseBuilder
    implements
        Builder<VerifySupplierIdGet200Response,
            VerifySupplierIdGet200ResponseBuilder> {
  _$VerifySupplierIdGet200Response? _$v;

  String? _legalName;
  String? get legalName => _$this._legalName;
  set legalName(String? legalName) => _$this._legalName = legalName;

  String? _stirMasked;
  String? get stirMasked => _$this._stirMasked;
  set stirMasked(String? stirMasked) => _$this._stirMasked = stirMasked;

  VerifySupplierIdGet200ResponseLevelEnum? _level;
  VerifySupplierIdGet200ResponseLevelEnum? get level => _$this._level;
  set level(VerifySupplierIdGet200ResponseLevelEnum? level) =>
      _$this._level = level;

  DateTime? _verifiedAt;
  DateTime? get verifiedAt => _$this._verifiedAt;
  set verifiedAt(DateTime? verifiedAt) => _$this._verifiedAt = verifiedAt;

  DateTime? _validUntil;
  DateTime? get validUntil => _$this._validUntil;
  set validUntil(DateTime? validUntil) => _$this._validUntil = validUntil;

  VerifySupplierIdGet200ResponseBuilder() {
    VerifySupplierIdGet200Response._defaults(this);
  }

  VerifySupplierIdGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _legalName = $v.legalName;
      _stirMasked = $v.stirMasked;
      _level = $v.level;
      _verifiedAt = $v.verifiedAt;
      _validUntil = $v.validUntil;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VerifySupplierIdGet200Response other) {
    _$v = other as _$VerifySupplierIdGet200Response;
  }

  @override
  void update(void Function(VerifySupplierIdGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VerifySupplierIdGet200Response build() => _build();

  _$VerifySupplierIdGet200Response _build() {
    final _$result = _$v ??
        _$VerifySupplierIdGet200Response._(
          legalName: legalName,
          stirMasked: stirMasked,
          level: level,
          verifiedAt: verifiedAt,
          validUntil: validUntil,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
