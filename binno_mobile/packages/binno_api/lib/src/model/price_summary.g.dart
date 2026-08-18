// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PriceSummary extends PriceSummary {
  @override
  final int? itemsTotal;
  @override
  final int? logisticsFee;
  @override
  final int? totalEstimate;
  @override
  final bool? isEstimate;

  factory _$PriceSummary([void Function(PriceSummaryBuilder)? updates]) =>
      (PriceSummaryBuilder()..update(updates))._build();

  _$PriceSummary._(
      {this.itemsTotal, this.logisticsFee, this.totalEstimate, this.isEstimate})
      : super._();
  @override
  PriceSummary rebuild(void Function(PriceSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PriceSummaryBuilder toBuilder() => PriceSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PriceSummary &&
        itemsTotal == other.itemsTotal &&
        logisticsFee == other.logisticsFee &&
        totalEstimate == other.totalEstimate &&
        isEstimate == other.isEstimate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, itemsTotal.hashCode);
    _$hash = $jc(_$hash, logisticsFee.hashCode);
    _$hash = $jc(_$hash, totalEstimate.hashCode);
    _$hash = $jc(_$hash, isEstimate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PriceSummary')
          ..add('itemsTotal', itemsTotal)
          ..add('logisticsFee', logisticsFee)
          ..add('totalEstimate', totalEstimate)
          ..add('isEstimate', isEstimate))
        .toString();
  }
}

class PriceSummaryBuilder
    implements Builder<PriceSummary, PriceSummaryBuilder> {
  _$PriceSummary? _$v;

  int? _itemsTotal;
  int? get itemsTotal => _$this._itemsTotal;
  set itemsTotal(int? itemsTotal) => _$this._itemsTotal = itemsTotal;

  int? _logisticsFee;
  int? get logisticsFee => _$this._logisticsFee;
  set logisticsFee(int? logisticsFee) => _$this._logisticsFee = logisticsFee;

  int? _totalEstimate;
  int? get totalEstimate => _$this._totalEstimate;
  set totalEstimate(int? totalEstimate) =>
      _$this._totalEstimate = totalEstimate;

  bool? _isEstimate;
  bool? get isEstimate => _$this._isEstimate;
  set isEstimate(bool? isEstimate) => _$this._isEstimate = isEstimate;

  PriceSummaryBuilder() {
    PriceSummary._defaults(this);
  }

  PriceSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _itemsTotal = $v.itemsTotal;
      _logisticsFee = $v.logisticsFee;
      _totalEstimate = $v.totalEstimate;
      _isEstimate = $v.isEstimate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PriceSummary other) {
    _$v = other as _$PriceSummary;
  }

  @override
  void update(void Function(PriceSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PriceSummary build() => _build();

  _$PriceSummary _build() {
    final _$result = _$v ??
        _$PriceSummary._(
          itemsTotal: itemsTotal,
          logisticsFee: logisticsFee,
          totalEstimate: totalEstimate,
          isEstimate: isEstimate,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
