// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_id_cancel_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrdersIdCancelPostRequest extends OrdersIdCancelPostRequest {
  @override
  final String reason;

  factory _$OrdersIdCancelPostRequest(
          [void Function(OrdersIdCancelPostRequestBuilder)? updates]) =>
      (OrdersIdCancelPostRequestBuilder()..update(updates))._build();

  _$OrdersIdCancelPostRequest._({required this.reason}) : super._();
  @override
  OrdersIdCancelPostRequest rebuild(
          void Function(OrdersIdCancelPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrdersIdCancelPostRequestBuilder toBuilder() =>
      OrdersIdCancelPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrdersIdCancelPostRequest && reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrdersIdCancelPostRequest')
          ..add('reason', reason))
        .toString();
  }
}

class OrdersIdCancelPostRequestBuilder
    implements
        Builder<OrdersIdCancelPostRequest, OrdersIdCancelPostRequestBuilder> {
  _$OrdersIdCancelPostRequest? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  OrdersIdCancelPostRequestBuilder() {
    OrdersIdCancelPostRequest._defaults(this);
  }

  OrdersIdCancelPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrdersIdCancelPostRequest other) {
    _$v = other as _$OrdersIdCancelPostRequest;
  }

  @override
  void update(void Function(OrdersIdCancelPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrdersIdCancelPostRequest build() => _build();

  _$OrdersIdCancelPostRequest _build() {
    final _$result = _$v ??
        _$OrdersIdCancelPostRequest._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'OrdersIdCancelPostRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
