// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_id_disputes_post201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrdersIdDisputesPost201Response
    extends OrdersIdDisputesPost201Response {
  @override
  final String? disputeId;

  factory _$OrdersIdDisputesPost201Response(
          [void Function(OrdersIdDisputesPost201ResponseBuilder)? updates]) =>
      (OrdersIdDisputesPost201ResponseBuilder()..update(updates))._build();

  _$OrdersIdDisputesPost201Response._({this.disputeId}) : super._();
  @override
  OrdersIdDisputesPost201Response rebuild(
          void Function(OrdersIdDisputesPost201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrdersIdDisputesPost201ResponseBuilder toBuilder() =>
      OrdersIdDisputesPost201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrdersIdDisputesPost201Response &&
        disputeId == other.disputeId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, disputeId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrdersIdDisputesPost201Response')
          ..add('disputeId', disputeId))
        .toString();
  }
}

class OrdersIdDisputesPost201ResponseBuilder
    implements
        Builder<OrdersIdDisputesPost201Response,
            OrdersIdDisputesPost201ResponseBuilder> {
  _$OrdersIdDisputesPost201Response? _$v;

  String? _disputeId;
  String? get disputeId => _$this._disputeId;
  set disputeId(String? disputeId) => _$this._disputeId = disputeId;

  OrdersIdDisputesPost201ResponseBuilder() {
    OrdersIdDisputesPost201Response._defaults(this);
  }

  OrdersIdDisputesPost201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _disputeId = $v.disputeId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrdersIdDisputesPost201Response other) {
    _$v = other as _$OrdersIdDisputesPost201Response;
  }

  @override
  void update(void Function(OrdersIdDisputesPost201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrdersIdDisputesPost201Response build() => _build();

  _$OrdersIdDisputesPost201Response _build() {
    final _$result = _$v ??
        _$OrdersIdDisputesPost201Response._(
          disputeId: disputeId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
