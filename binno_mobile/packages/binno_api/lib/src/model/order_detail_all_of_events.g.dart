// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_detail_all_of_events.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderDetailAllOfEvents extends OrderDetailAllOfEvents {
  @override
  final String? fromStatus;
  @override
  final String? toStatus;
  @override
  final String? actorRole;
  @override
  final DateTime? createdAt;
  @override
  final String? photoUrl;

  factory _$OrderDetailAllOfEvents(
          [void Function(OrderDetailAllOfEventsBuilder)? updates]) =>
      (OrderDetailAllOfEventsBuilder()..update(updates))._build();

  _$OrderDetailAllOfEvents._(
      {this.fromStatus,
      this.toStatus,
      this.actorRole,
      this.createdAt,
      this.photoUrl})
      : super._();
  @override
  OrderDetailAllOfEvents rebuild(
          void Function(OrderDetailAllOfEventsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderDetailAllOfEventsBuilder toBuilder() =>
      OrderDetailAllOfEventsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderDetailAllOfEvents &&
        fromStatus == other.fromStatus &&
        toStatus == other.toStatus &&
        actorRole == other.actorRole &&
        createdAt == other.createdAt &&
        photoUrl == other.photoUrl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fromStatus.hashCode);
    _$hash = $jc(_$hash, toStatus.hashCode);
    _$hash = $jc(_$hash, actorRole.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, photoUrl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrderDetailAllOfEvents')
          ..add('fromStatus', fromStatus)
          ..add('toStatus', toStatus)
          ..add('actorRole', actorRole)
          ..add('createdAt', createdAt)
          ..add('photoUrl', photoUrl))
        .toString();
  }
}

class OrderDetailAllOfEventsBuilder
    implements Builder<OrderDetailAllOfEvents, OrderDetailAllOfEventsBuilder> {
  _$OrderDetailAllOfEvents? _$v;

  String? _fromStatus;
  String? get fromStatus => _$this._fromStatus;
  set fromStatus(String? fromStatus) => _$this._fromStatus = fromStatus;

  String? _toStatus;
  String? get toStatus => _$this._toStatus;
  set toStatus(String? toStatus) => _$this._toStatus = toStatus;

  String? _actorRole;
  String? get actorRole => _$this._actorRole;
  set actorRole(String? actorRole) => _$this._actorRole = actorRole;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _photoUrl;
  String? get photoUrl => _$this._photoUrl;
  set photoUrl(String? photoUrl) => _$this._photoUrl = photoUrl;

  OrderDetailAllOfEventsBuilder() {
    OrderDetailAllOfEvents._defaults(this);
  }

  OrderDetailAllOfEventsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fromStatus = $v.fromStatus;
      _toStatus = $v.toStatus;
      _actorRole = $v.actorRole;
      _createdAt = $v.createdAt;
      _photoUrl = $v.photoUrl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderDetailAllOfEvents other) {
    _$v = other as _$OrderDetailAllOfEvents;
  }

  @override
  void update(void Function(OrderDetailAllOfEventsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderDetailAllOfEvents build() => _build();

  _$OrderDetailAllOfEvents _build() {
    final _$result = _$v ??
        _$OrderDetailAllOfEvents._(
          fromStatus: fromStatus,
          toStatus: toStatus,
          actorRole: actorRole,
          createdAt: createdAt,
          photoUrl: photoUrl,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
