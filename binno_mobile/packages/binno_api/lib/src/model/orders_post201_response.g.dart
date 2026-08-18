// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_post201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrdersPost201Response extends OrdersPost201Response {
  @override
  final String? orderId;
  @override
  final String? status;
  @override
  final PriceSummary? priceSummary;

  factory _$OrdersPost201Response(
          [void Function(OrdersPost201ResponseBuilder)? updates]) =>
      (OrdersPost201ResponseBuilder()..update(updates))._build();

  _$OrdersPost201Response._({this.orderId, this.status, this.priceSummary})
      : super._();
  @override
  OrdersPost201Response rebuild(
          void Function(OrdersPost201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrdersPost201ResponseBuilder toBuilder() =>
      OrdersPost201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrdersPost201Response &&
        orderId == other.orderId &&
        status == other.status &&
        priceSummary == other.priceSummary;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, orderId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, priceSummary.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrdersPost201Response')
          ..add('orderId', orderId)
          ..add('status', status)
          ..add('priceSummary', priceSummary))
        .toString();
  }
}

class OrdersPost201ResponseBuilder
    implements Builder<OrdersPost201Response, OrdersPost201ResponseBuilder> {
  _$OrdersPost201Response? _$v;

  String? _orderId;
  String? get orderId => _$this._orderId;
  set orderId(String? orderId) => _$this._orderId = orderId;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  PriceSummaryBuilder? _priceSummary;
  PriceSummaryBuilder get priceSummary =>
      _$this._priceSummary ??= PriceSummaryBuilder();
  set priceSummary(PriceSummaryBuilder? priceSummary) =>
      _$this._priceSummary = priceSummary;

  OrdersPost201ResponseBuilder() {
    OrdersPost201Response._defaults(this);
  }

  OrdersPost201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _orderId = $v.orderId;
      _status = $v.status;
      _priceSummary = $v.priceSummary?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrdersPost201Response other) {
    _$v = other as _$OrdersPost201Response;
  }

  @override
  void update(void Function(OrdersPost201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrdersPost201Response build() => _build();

  _$OrdersPost201Response _build() {
    _$OrdersPost201Response _$result;
    try {
      _$result = _$v ??
          _$OrdersPost201Response._(
            orderId: orderId,
            status: status,
            priceSummary: _priceSummary?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'priceSummary';
        _priceSummary?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OrdersPost201Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
