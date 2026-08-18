// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_billing_payment_intent_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierBillingPaymentIntentPost200Response
    extends SupplierBillingPaymentIntentPost200Response {
  @override
  final int? amount;
  @override
  final JsonObject? binnoRequisites;
  @override
  final String? referenceCode;

  factory _$SupplierBillingPaymentIntentPost200Response(
          [void Function(SupplierBillingPaymentIntentPost200ResponseBuilder)?
              updates]) =>
      (SupplierBillingPaymentIntentPost200ResponseBuilder()..update(updates))
          ._build();

  _$SupplierBillingPaymentIntentPost200Response._(
      {this.amount, this.binnoRequisites, this.referenceCode})
      : super._();
  @override
  SupplierBillingPaymentIntentPost200Response rebuild(
          void Function(SupplierBillingPaymentIntentPost200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierBillingPaymentIntentPost200ResponseBuilder toBuilder() =>
      SupplierBillingPaymentIntentPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierBillingPaymentIntentPost200Response &&
        amount == other.amount &&
        binnoRequisites == other.binnoRequisites &&
        referenceCode == other.referenceCode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, binnoRequisites.hashCode);
    _$hash = $jc(_$hash, referenceCode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SupplierBillingPaymentIntentPost200Response')
          ..add('amount', amount)
          ..add('binnoRequisites', binnoRequisites)
          ..add('referenceCode', referenceCode))
        .toString();
  }
}

class SupplierBillingPaymentIntentPost200ResponseBuilder
    implements
        Builder<SupplierBillingPaymentIntentPost200Response,
            SupplierBillingPaymentIntentPost200ResponseBuilder> {
  _$SupplierBillingPaymentIntentPost200Response? _$v;

  int? _amount;
  int? get amount => _$this._amount;
  set amount(int? amount) => _$this._amount = amount;

  JsonObject? _binnoRequisites;
  JsonObject? get binnoRequisites => _$this._binnoRequisites;
  set binnoRequisites(JsonObject? binnoRequisites) =>
      _$this._binnoRequisites = binnoRequisites;

  String? _referenceCode;
  String? get referenceCode => _$this._referenceCode;
  set referenceCode(String? referenceCode) =>
      _$this._referenceCode = referenceCode;

  SupplierBillingPaymentIntentPost200ResponseBuilder() {
    SupplierBillingPaymentIntentPost200Response._defaults(this);
  }

  SupplierBillingPaymentIntentPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _amount = $v.amount;
      _binnoRequisites = $v.binnoRequisites;
      _referenceCode = $v.referenceCode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierBillingPaymentIntentPost200Response other) {
    _$v = other as _$SupplierBillingPaymentIntentPost200Response;
  }

  @override
  void update(
      void Function(SupplierBillingPaymentIntentPost200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierBillingPaymentIntentPost200Response build() => _build();

  _$SupplierBillingPaymentIntentPost200Response _build() {
    final _$result = _$v ??
        _$SupplierBillingPaymentIntentPost200Response._(
          amount: amount,
          binnoRequisites: binnoRequisites,
          referenceCode: referenceCode,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
