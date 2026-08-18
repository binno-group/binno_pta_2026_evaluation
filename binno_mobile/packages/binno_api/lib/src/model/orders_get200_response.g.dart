// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrdersGet200Response extends OrdersGet200Response {
  @override
  final BuiltList<OrderSummary>? items;
  @override
  final String? nextCursor;

  factory _$OrdersGet200Response(
          [void Function(OrdersGet200ResponseBuilder)? updates]) =>
      (OrdersGet200ResponseBuilder()..update(updates))._build();

  _$OrdersGet200Response._({this.items, this.nextCursor}) : super._();
  @override
  OrdersGet200Response rebuild(
          void Function(OrdersGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrdersGet200ResponseBuilder toBuilder() =>
      OrdersGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrdersGet200Response &&
        items == other.items &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrdersGet200Response')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class OrdersGet200ResponseBuilder
    implements Builder<OrdersGet200Response, OrdersGet200ResponseBuilder> {
  _$OrdersGet200Response? _$v;

  ListBuilder<OrderSummary>? _items;
  ListBuilder<OrderSummary> get items =>
      _$this._items ??= ListBuilder<OrderSummary>();
  set items(ListBuilder<OrderSummary>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  OrdersGet200ResponseBuilder() {
    OrdersGet200Response._defaults(this);
  }

  OrdersGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items?.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrdersGet200Response other) {
    _$v = other as _$OrdersGet200Response;
  }

  @override
  void update(void Function(OrdersGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrdersGet200Response build() => _build();

  _$OrdersGet200Response _build() {
    _$OrdersGet200Response _$result;
    try {
      _$result = _$v ??
          _$OrdersGet200Response._(
            items: _items?.build(),
            nextCursor: nextCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        _items?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OrdersGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
