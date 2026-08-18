// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_point.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GeoPoint extends GeoPoint {
  @override
  final num lat;
  @override
  final num lng;

  factory _$GeoPoint([void Function(GeoPointBuilder)? updates]) =>
      (GeoPointBuilder()..update(updates))._build();

  _$GeoPoint._({required this.lat, required this.lng}) : super._();
  @override
  GeoPoint rebuild(void Function(GeoPointBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GeoPointBuilder toBuilder() => GeoPointBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GeoPoint && lat == other.lat && lng == other.lng;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GeoPoint')
          ..add('lat', lat)
          ..add('lng', lng))
        .toString();
  }
}

class GeoPointBuilder implements Builder<GeoPoint, GeoPointBuilder> {
  _$GeoPoint? _$v;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  GeoPointBuilder() {
    GeoPoint._defaults(this);
  }

  GeoPointBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _lat = $v.lat;
      _lng = $v.lng;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GeoPoint other) {
    _$v = other as _$GeoPoint;
  }

  @override
  void update(void Function(GeoPointBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GeoPoint build() => _build();

  _$GeoPoint _build() {
    final _$result = _$v ??
        _$GeoPoint._(
          lat: BuiltValueNullFieldError.checkNotNull(lat, r'GeoPoint', 'lat'),
          lng: BuiltValueNullFieldError.checkNotNull(lng, r'GeoPoint', 'lng'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
