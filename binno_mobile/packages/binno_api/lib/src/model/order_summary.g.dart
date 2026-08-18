// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

abstract class OrderSummaryBuilder {
  void replace(OrderSummary other);
  void update(void Function(OrderSummaryBuilder) updates);
  String? get id;
  set id(String? id);

  String? get reference;
  set reference(String? reference);

  String? get status;
  set status(String? status);

  String? get supplierName;
  set supplierName(String? supplierName);

  String? get itemSummary;
  set itemSummary(String? itemSummary);

  int? get totalAmount;
  set totalAmount(int? totalAmount);

  bool? get isUrgent;
  set isUrgent(bool? isUrgent);

  DateTime? get updatedAt;
  set updatedAt(DateTime? updatedAt);
}

class _$$OrderSummary extends $OrderSummary {
  @override
  final String? id;
  @override
  final String? reference;
  @override
  final String? status;
  @override
  final String? supplierName;
  @override
  final String? itemSummary;
  @override
  final int? totalAmount;
  @override
  final bool? isUrgent;
  @override
  final DateTime? updatedAt;

  factory _$$OrderSummary([void Function($OrderSummaryBuilder)? updates]) =>
      ($OrderSummaryBuilder()..update(updates))._build();

  _$$OrderSummary._(
      {this.id,
      this.reference,
      this.status,
      this.supplierName,
      this.itemSummary,
      this.totalAmount,
      this.isUrgent,
      this.updatedAt})
      : super._();
  @override
  $OrderSummary rebuild(void Function($OrderSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $OrderSummaryBuilder toBuilder() => $OrderSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $OrderSummary &&
        id == other.id &&
        reference == other.reference &&
        status == other.status &&
        supplierName == other.supplierName &&
        itemSummary == other.itemSummary &&
        totalAmount == other.totalAmount &&
        isUrgent == other.isUrgent &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, reference.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, supplierName.hashCode);
    _$hash = $jc(_$hash, itemSummary.hashCode);
    _$hash = $jc(_$hash, totalAmount.hashCode);
    _$hash = $jc(_$hash, isUrgent.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'$OrderSummary')
          ..add('id', id)
          ..add('reference', reference)
          ..add('status', status)
          ..add('supplierName', supplierName)
          ..add('itemSummary', itemSummary)
          ..add('totalAmount', totalAmount)
          ..add('isUrgent', isUrgent)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class $OrderSummaryBuilder
    implements
        Builder<$OrderSummary, $OrderSummaryBuilder>,
        OrderSummaryBuilder {
  _$$OrderSummary? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  String? _reference;
  String? get reference => _$this._reference;
  set reference(covariant String? reference) => _$this._reference = reference;

  String? _status;
  String? get status => _$this._status;
  set status(covariant String? status) => _$this._status = status;

  String? _supplierName;
  String? get supplierName => _$this._supplierName;
  set supplierName(covariant String? supplierName) =>
      _$this._supplierName = supplierName;

  String? _itemSummary;
  String? get itemSummary => _$this._itemSummary;
  set itemSummary(covariant String? itemSummary) =>
      _$this._itemSummary = itemSummary;

  int? _totalAmount;
  int? get totalAmount => _$this._totalAmount;
  set totalAmount(covariant int? totalAmount) =>
      _$this._totalAmount = totalAmount;

  bool? _isUrgent;
  bool? get isUrgent => _$this._isUrgent;
  set isUrgent(covariant bool? isUrgent) => _$this._isUrgent = isUrgent;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(covariant DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  $OrderSummaryBuilder() {
    $OrderSummary._defaults(this);
  }

  $OrderSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _reference = $v.reference;
      _status = $v.status;
      _supplierName = $v.supplierName;
      _itemSummary = $v.itemSummary;
      _totalAmount = $v.totalAmount;
      _isUrgent = $v.isUrgent;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant $OrderSummary other) {
    _$v = other as _$$OrderSummary;
  }

  @override
  void update(void Function($OrderSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $OrderSummary build() => _build();

  _$$OrderSummary _build() {
    final _$result = _$v ??
        _$$OrderSummary._(
          id: id,
          reference: reference,
          status: status,
          supplierName: supplierName,
          itemSummary: itemSummary,
          totalAmount: totalAmount,
          isUrgent: isUrgent,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
