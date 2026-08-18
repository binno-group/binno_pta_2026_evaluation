// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_billing_summary_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierBillingSummaryGet200Response
    extends SupplierBillingSummaryGet200Response {
  @override
  final int? accruedTotal;
  @override
  final int? paidTotal;
  @override
  final int? outstanding;
  @override
  final int? creditLimit;
  @override
  final num? utilizationPct;
  @override
  final bool? blocked;

  factory _$SupplierBillingSummaryGet200Response(
          [void Function(SupplierBillingSummaryGet200ResponseBuilder)?
              updates]) =>
      (SupplierBillingSummaryGet200ResponseBuilder()..update(updates))._build();

  _$SupplierBillingSummaryGet200Response._(
      {this.accruedTotal,
      this.paidTotal,
      this.outstanding,
      this.creditLimit,
      this.utilizationPct,
      this.blocked})
      : super._();
  @override
  SupplierBillingSummaryGet200Response rebuild(
          void Function(SupplierBillingSummaryGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierBillingSummaryGet200ResponseBuilder toBuilder() =>
      SupplierBillingSummaryGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierBillingSummaryGet200Response &&
        accruedTotal == other.accruedTotal &&
        paidTotal == other.paidTotal &&
        outstanding == other.outstanding &&
        creditLimit == other.creditLimit &&
        utilizationPct == other.utilizationPct &&
        blocked == other.blocked;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accruedTotal.hashCode);
    _$hash = $jc(_$hash, paidTotal.hashCode);
    _$hash = $jc(_$hash, outstanding.hashCode);
    _$hash = $jc(_$hash, creditLimit.hashCode);
    _$hash = $jc(_$hash, utilizationPct.hashCode);
    _$hash = $jc(_$hash, blocked.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SupplierBillingSummaryGet200Response')
          ..add('accruedTotal', accruedTotal)
          ..add('paidTotal', paidTotal)
          ..add('outstanding', outstanding)
          ..add('creditLimit', creditLimit)
          ..add('utilizationPct', utilizationPct)
          ..add('blocked', blocked))
        .toString();
  }
}

class SupplierBillingSummaryGet200ResponseBuilder
    implements
        Builder<SupplierBillingSummaryGet200Response,
            SupplierBillingSummaryGet200ResponseBuilder> {
  _$SupplierBillingSummaryGet200Response? _$v;

  int? _accruedTotal;
  int? get accruedTotal => _$this._accruedTotal;
  set accruedTotal(int? accruedTotal) => _$this._accruedTotal = accruedTotal;

  int? _paidTotal;
  int? get paidTotal => _$this._paidTotal;
  set paidTotal(int? paidTotal) => _$this._paidTotal = paidTotal;

  int? _outstanding;
  int? get outstanding => _$this._outstanding;
  set outstanding(int? outstanding) => _$this._outstanding = outstanding;

  int? _creditLimit;
  int? get creditLimit => _$this._creditLimit;
  set creditLimit(int? creditLimit) => _$this._creditLimit = creditLimit;

  num? _utilizationPct;
  num? get utilizationPct => _$this._utilizationPct;
  set utilizationPct(num? utilizationPct) =>
      _$this._utilizationPct = utilizationPct;

  bool? _blocked;
  bool? get blocked => _$this._blocked;
  set blocked(bool? blocked) => _$this._blocked = blocked;

  SupplierBillingSummaryGet200ResponseBuilder() {
    SupplierBillingSummaryGet200Response._defaults(this);
  }

  SupplierBillingSummaryGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accruedTotal = $v.accruedTotal;
      _paidTotal = $v.paidTotal;
      _outstanding = $v.outstanding;
      _creditLimit = $v.creditLimit;
      _utilizationPct = $v.utilizationPct;
      _blocked = $v.blocked;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierBillingSummaryGet200Response other) {
    _$v = other as _$SupplierBillingSummaryGet200Response;
  }

  @override
  void update(
      void Function(SupplierBillingSummaryGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierBillingSummaryGet200Response build() => _build();

  _$SupplierBillingSummaryGet200Response _build() {
    final _$result = _$v ??
        _$SupplierBillingSummaryGet200Response._(
          accruedTotal: accruedTotal,
          paidTotal: paidTotal,
          outstanding: outstanding,
          creditLimit: creditLimit,
          utilizationPct: utilizationPct,
          blocked: blocked,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
