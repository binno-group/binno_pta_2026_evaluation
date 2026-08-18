// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_detail_all_of_items.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderDetailAllOfItems extends OrderDetailAllOfItems {
  @override
  final JsonObject? productSnapshot;
  @override
  final num? qty;
  @override
  final int? unitPrice;
  @override
  final int? lineTotal;

  factory _$OrderDetailAllOfItems(
          [void Function(OrderDetailAllOfItemsBuilder)? updates]) =>
      (OrderDetailAllOfItemsBuilder()..update(updates))._build();

  _$OrderDetailAllOfItems._(
      {this.productSnapshot, this.qty, this.unitPrice, this.lineTotal})
      : super._();
  @override
  OrderDetailAllOfItems rebuild(
          void Function(OrderDetailAllOfItemsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderDetailAllOfItemsBuilder toBuilder() =>
      OrderDetailAllOfItemsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderDetailAllOfItems &&
        productSnapshot == other.productSnapshot &&
        qty == other.qty &&
        unitPrice == other.unitPrice &&
        lineTotal == other.lineTotal;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, productSnapshot.hashCode);
    _$hash = $jc(_$hash, qty.hashCode);
    _$hash = $jc(_$hash, unitPrice.hashCode);
    _$hash = $jc(_$hash, lineTotal.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrderDetailAllOfItems')
          ..add('productSnapshot', productSnapshot)
          ..add('qty', qty)
          ..add('unitPrice', unitPrice)
          ..add('lineTotal', lineTotal))
        .toString();
  }
}

class OrderDetailAllOfItemsBuilder
    implements Builder<OrderDetailAllOfItems, OrderDetailAllOfItemsBuilder> {
  _$OrderDetailAllOfItems? _$v;

  JsonObject? _productSnapshot;
  JsonObject? get productSnapshot => _$this._productSnapshot;
  set productSnapshot(JsonObject? productSnapshot) =>
      _$this._productSnapshot = productSnapshot;

  num? _qty;
  num? get qty => _$this._qty;
  set qty(num? qty) => _$this._qty = qty;

  int? _unitPrice;
  int? get unitPrice => _$this._unitPrice;
  set unitPrice(int? unitPrice) => _$this._unitPrice = unitPrice;

  int? _lineTotal;
  int? get lineTotal => _$this._lineTotal;
  set lineTotal(int? lineTotal) => _$this._lineTotal = lineTotal;

  OrderDetailAllOfItemsBuilder() {
    OrderDetailAllOfItems._defaults(this);
  }

  OrderDetailAllOfItemsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _productSnapshot = $v.productSnapshot;
      _qty = $v.qty;
      _unitPrice = $v.unitPrice;
      _lineTotal = $v.lineTotal;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderDetailAllOfItems other) {
    _$v = other as _$OrderDetailAllOfItems;
  }

  @override
  void update(void Function(OrderDetailAllOfItemsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderDetailAllOfItems build() => _build();

  _$OrderDetailAllOfItems _build() {
    final _$result = _$v ??
        _$OrderDetailAllOfItems._(
          productSnapshot: productSnapshot,
          qty: qty,
          unitPrice: unitPrice,
          lineTotal: lineTotal,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
