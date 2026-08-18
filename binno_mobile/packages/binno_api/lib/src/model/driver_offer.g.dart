// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_offer.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DriverOfferModeEnum _$driverOfferModeEnum_classic =
    const DriverOfferModeEnum._('classic');
const DriverOfferModeEnum _$driverOfferModeEnum_urgent =
    const DriverOfferModeEnum._('urgent');

DriverOfferModeEnum _$driverOfferModeEnumValueOf(String name) {
  switch (name) {
    case 'classic':
      return _$driverOfferModeEnum_classic;
    case 'urgent':
      return _$driverOfferModeEnum_urgent;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DriverOfferModeEnum> _$driverOfferModeEnumValues =
    BuiltSet<DriverOfferModeEnum>(const <DriverOfferModeEnum>[
  _$driverOfferModeEnum_classic,
  _$driverOfferModeEnum_urgent,
]);

Serializer<DriverOfferModeEnum> _$driverOfferModeEnumSerializer =
    _$DriverOfferModeEnumSerializer();

class _$DriverOfferModeEnumSerializer
    implements PrimitiveSerializer<DriverOfferModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'classic': 'classic',
    'urgent': 'urgent',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'classic': 'classic',
    'urgent': 'urgent',
  };

  @override
  final Iterable<Type> types = const <Type>[DriverOfferModeEnum];
  @override
  final String wireName = 'DriverOfferModeEnum';

  @override
  Object serialize(Serializers serializers, DriverOfferModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DriverOfferModeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DriverOfferModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DriverOffer extends DriverOffer {
  @override
  final String? id;
  @override
  final DriverOfferModeEnum? mode;
  @override
  final String? pickupAddress;
  @override
  final String? dropoffAddress;
  @override
  final String? cargoClass;
  @override
  final int? deliveryFee;
  @override
  final int? driverShare;
  @override
  final DateTime? expiresAt;

  factory _$DriverOffer([void Function(DriverOfferBuilder)? updates]) =>
      (DriverOfferBuilder()..update(updates))._build();

  _$DriverOffer._(
      {this.id,
      this.mode,
      this.pickupAddress,
      this.dropoffAddress,
      this.cargoClass,
      this.deliveryFee,
      this.driverShare,
      this.expiresAt})
      : super._();
  @override
  DriverOffer rebuild(void Function(DriverOfferBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverOfferBuilder toBuilder() => DriverOfferBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverOffer &&
        id == other.id &&
        mode == other.mode &&
        pickupAddress == other.pickupAddress &&
        dropoffAddress == other.dropoffAddress &&
        cargoClass == other.cargoClass &&
        deliveryFee == other.deliveryFee &&
        driverShare == other.driverShare &&
        expiresAt == other.expiresAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, mode.hashCode);
    _$hash = $jc(_$hash, pickupAddress.hashCode);
    _$hash = $jc(_$hash, dropoffAddress.hashCode);
    _$hash = $jc(_$hash, cargoClass.hashCode);
    _$hash = $jc(_$hash, deliveryFee.hashCode);
    _$hash = $jc(_$hash, driverShare.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DriverOffer')
          ..add('id', id)
          ..add('mode', mode)
          ..add('pickupAddress', pickupAddress)
          ..add('dropoffAddress', dropoffAddress)
          ..add('cargoClass', cargoClass)
          ..add('deliveryFee', deliveryFee)
          ..add('driverShare', driverShare)
          ..add('expiresAt', expiresAt))
        .toString();
  }
}

class DriverOfferBuilder implements Builder<DriverOffer, DriverOfferBuilder> {
  _$DriverOffer? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DriverOfferModeEnum? _mode;
  DriverOfferModeEnum? get mode => _$this._mode;
  set mode(DriverOfferModeEnum? mode) => _$this._mode = mode;

  String? _pickupAddress;
  String? get pickupAddress => _$this._pickupAddress;
  set pickupAddress(String? pickupAddress) =>
      _$this._pickupAddress = pickupAddress;

  String? _dropoffAddress;
  String? get dropoffAddress => _$this._dropoffAddress;
  set dropoffAddress(String? dropoffAddress) =>
      _$this._dropoffAddress = dropoffAddress;

  String? _cargoClass;
  String? get cargoClass => _$this._cargoClass;
  set cargoClass(String? cargoClass) => _$this._cargoClass = cargoClass;

  int? _deliveryFee;
  int? get deliveryFee => _$this._deliveryFee;
  set deliveryFee(int? deliveryFee) => _$this._deliveryFee = deliveryFee;

  int? _driverShare;
  int? get driverShare => _$this._driverShare;
  set driverShare(int? driverShare) => _$this._driverShare = driverShare;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  DriverOfferBuilder() {
    DriverOffer._defaults(this);
  }

  DriverOfferBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _mode = $v.mode;
      _pickupAddress = $v.pickupAddress;
      _dropoffAddress = $v.dropoffAddress;
      _cargoClass = $v.cargoClass;
      _deliveryFee = $v.deliveryFee;
      _driverShare = $v.driverShare;
      _expiresAt = $v.expiresAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverOffer other) {
    _$v = other as _$DriverOffer;
  }

  @override
  void update(void Function(DriverOfferBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverOffer build() => _build();

  _$DriverOffer _build() {
    final _$result = _$v ??
        _$DriverOffer._(
          id: id,
          mode: mode,
          pickupAddress: pickupAddress,
          dropoffAddress: dropoffAddress,
          cargoClass: cargoClass,
          deliveryFee: deliveryFee,
          driverShare: driverShare,
          expiresAt: expiresAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
