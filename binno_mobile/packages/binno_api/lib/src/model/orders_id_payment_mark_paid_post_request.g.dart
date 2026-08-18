// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_id_payment_mark_paid_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrdersIdPaymentMarkPaidPostRequest
    extends OrdersIdPaymentMarkPaidPostRequest {
  @override
  final String? receiptPhoto;

  factory _$OrdersIdPaymentMarkPaidPostRequest(
          [void Function(OrdersIdPaymentMarkPaidPostRequestBuilder)?
              updates]) =>
      (OrdersIdPaymentMarkPaidPostRequestBuilder()..update(updates))._build();

  _$OrdersIdPaymentMarkPaidPostRequest._({this.receiptPhoto}) : super._();
  @override
  OrdersIdPaymentMarkPaidPostRequest rebuild(
          void Function(OrdersIdPaymentMarkPaidPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrdersIdPaymentMarkPaidPostRequestBuilder toBuilder() =>
      OrdersIdPaymentMarkPaidPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrdersIdPaymentMarkPaidPostRequest &&
        receiptPhoto == other.receiptPhoto;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, receiptPhoto.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrdersIdPaymentMarkPaidPostRequest')
          ..add('receiptPhoto', receiptPhoto))
        .toString();
  }
}

class OrdersIdPaymentMarkPaidPostRequestBuilder
    implements
        Builder<OrdersIdPaymentMarkPaidPostRequest,
            OrdersIdPaymentMarkPaidPostRequestBuilder> {
  _$OrdersIdPaymentMarkPaidPostRequest? _$v;

  String? _receiptPhoto;
  String? get receiptPhoto => _$this._receiptPhoto;
  set receiptPhoto(String? receiptPhoto) => _$this._receiptPhoto = receiptPhoto;

  OrdersIdPaymentMarkPaidPostRequestBuilder() {
    OrdersIdPaymentMarkPaidPostRequest._defaults(this);
  }

  OrdersIdPaymentMarkPaidPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _receiptPhoto = $v.receiptPhoto;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrdersIdPaymentMarkPaidPostRequest other) {
    _$v = other as _$OrdersIdPaymentMarkPaidPostRequest;
  }

  @override
  void update(
      void Function(OrdersIdPaymentMarkPaidPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrdersIdPaymentMarkPaidPostRequest build() => _build();

  _$OrdersIdPaymentMarkPaidPostRequest _build() {
    final _$result = _$v ??
        _$OrdersIdPaymentMarkPaidPostRequest._(
          receiptPhoto: receiptPhoto,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
