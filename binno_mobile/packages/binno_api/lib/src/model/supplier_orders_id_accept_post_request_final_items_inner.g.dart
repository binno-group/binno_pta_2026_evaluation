// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_orders_id_accept_post_request_final_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierOrdersIdAcceptPostRequestFinalItemsInner
    extends SupplierOrdersIdAcceptPostRequestFinalItemsInner {
  @override
  final String productId;
  @override
  final num qty;
  @override
  final int unitPrice;

  factory _$SupplierOrdersIdAcceptPostRequestFinalItemsInner(
          [void Function(
                  SupplierOrdersIdAcceptPostRequestFinalItemsInnerBuilder)?
              updates]) =>
      (SupplierOrdersIdAcceptPostRequestFinalItemsInnerBuilder()
            ..update(updates))
          ._build();

  _$SupplierOrdersIdAcceptPostRequestFinalItemsInner._(
      {required this.productId, required this.qty, required this.unitPrice})
      : super._();
  @override
  SupplierOrdersIdAcceptPostRequestFinalItemsInner rebuild(
          void Function(SupplierOrdersIdAcceptPostRequestFinalItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierOrdersIdAcceptPostRequestFinalItemsInnerBuilder toBuilder() =>
      SupplierOrdersIdAcceptPostRequestFinalItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierOrdersIdAcceptPostRequestFinalItemsInner &&
        productId == other.productId &&
        qty == other.qty &&
        unitPrice == other.unitPrice;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, qty.hashCode);
    _$hash = $jc(_$hash, unitPrice.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SupplierOrdersIdAcceptPostRequestFinalItemsInner')
          ..add('productId', productId)
          ..add('qty', qty)
          ..add('unitPrice', unitPrice))
        .toString();
  }
}

class SupplierOrdersIdAcceptPostRequestFinalItemsInnerBuilder
    implements
        Builder<SupplierOrdersIdAcceptPostRequestFinalItemsInner,
            SupplierOrdersIdAcceptPostRequestFinalItemsInnerBuilder> {
  _$SupplierOrdersIdAcceptPostRequestFinalItemsInner? _$v;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  num? _qty;
  num? get qty => _$this._qty;
  set qty(num? qty) => _$this._qty = qty;

  int? _unitPrice;
  int? get unitPrice => _$this._unitPrice;
  set unitPrice(int? unitPrice) => _$this._unitPrice = unitPrice;

  SupplierOrdersIdAcceptPostRequestFinalItemsInnerBuilder() {
    SupplierOrdersIdAcceptPostRequestFinalItemsInner._defaults(this);
  }

  SupplierOrdersIdAcceptPostRequestFinalItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _productId = $v.productId;
      _qty = $v.qty;
      _unitPrice = $v.unitPrice;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierOrdersIdAcceptPostRequestFinalItemsInner other) {
    _$v = other as _$SupplierOrdersIdAcceptPostRequestFinalItemsInner;
  }

  @override
  void update(
      void Function(SupplierOrdersIdAcceptPostRequestFinalItemsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierOrdersIdAcceptPostRequestFinalItemsInner build() => _build();

  _$SupplierOrdersIdAcceptPostRequestFinalItemsInner _build() {
    final _$result = _$v ??
        _$SupplierOrdersIdAcceptPostRequestFinalItemsInner._(
          productId: BuiltValueNullFieldError.checkNotNull(productId,
              r'SupplierOrdersIdAcceptPostRequestFinalItemsInner', 'productId'),
          qty: BuiltValueNullFieldError.checkNotNull(
              qty, r'SupplierOrdersIdAcceptPostRequestFinalItemsInner', 'qty'),
          unitPrice: BuiltValueNullFieldError.checkNotNull(unitPrice,
              r'SupplierOrdersIdAcceptPostRequestFinalItemsInner', 'unitPrice'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
