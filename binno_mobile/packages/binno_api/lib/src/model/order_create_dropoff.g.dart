// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_create_dropoff.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderCreateDropoff extends OrderCreateDropoff {
  @override
  final num lat;
  @override
  final num lng;
  @override
  final String address;

  factory _$OrderCreateDropoff(
          [void Function(OrderCreateDropoffBuilder)? updates]) =>
      (OrderCreateDropoffBuilder()..update(updates))._build();

  _$OrderCreateDropoff._(
      {required this.lat, required this.lng, required this.address})
      : super._();
  @override
  OrderCreateDropoff rebuild(
          void Function(OrderCreateDropoffBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderCreateDropoffBuilder toBuilder() =>
      OrderCreateDropoffBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderCreateDropoff &&
        lat == other.lat &&
        lng == other.lng &&
        address == other.address;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrderCreateDropoff')
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('address', address))
        .toString();
  }
}

class OrderCreateDropoffBuilder
    implements Builder<OrderCreateDropoff, OrderCreateDropoffBuilder> {
  _$OrderCreateDropoff? _$v;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  OrderCreateDropoffBuilder() {
    OrderCreateDropoff._defaults(this);
  }

  OrderCreateDropoffBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _lat = $v.lat;
      _lng = $v.lng;
      _address = $v.address;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderCreateDropoff other) {
    _$v = other as _$OrderCreateDropoff;
  }

  @override
  void update(void Function(OrderCreateDropoffBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderCreateDropoff build() => _build();

  _$OrderCreateDropoff _build() {
    final _$result = _$v ??
        _$OrderCreateDropoff._(
          lat: BuiltValueNullFieldError.checkNotNull(
              lat, r'OrderCreateDropoff', 'lat'),
          lng: BuiltValueNullFieldError.checkNotNull(
              lng, r'OrderCreateDropoff', 'lng'),
          address: BuiltValueNullFieldError.checkNotNull(
              address, r'OrderCreateDropoff', 'address'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
