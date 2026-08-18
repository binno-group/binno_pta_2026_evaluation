// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_create_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderCreateItemsInner extends OrderCreateItemsInner {
  @override
  final String productId;
  @override
  final num qty;
  @override
  final String? note;

  factory _$OrderCreateItemsInner(
          [void Function(OrderCreateItemsInnerBuilder)? updates]) =>
      (OrderCreateItemsInnerBuilder()..update(updates))._build();

  _$OrderCreateItemsInner._(
      {required this.productId, required this.qty, this.note})
      : super._();
  @override
  OrderCreateItemsInner rebuild(
          void Function(OrderCreateItemsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderCreateItemsInnerBuilder toBuilder() =>
      OrderCreateItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderCreateItemsInner &&
        productId == other.productId &&
        qty == other.qty &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, qty.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrderCreateItemsInner')
          ..add('productId', productId)
          ..add('qty', qty)
          ..add('note', note))
        .toString();
  }
}

class OrderCreateItemsInnerBuilder
    implements Builder<OrderCreateItemsInner, OrderCreateItemsInnerBuilder> {
  _$OrderCreateItemsInner? _$v;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  num? _qty;
  num? get qty => _$this._qty;
  set qty(num? qty) => _$this._qty = qty;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  OrderCreateItemsInnerBuilder() {
    OrderCreateItemsInner._defaults(this);
  }

  OrderCreateItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _productId = $v.productId;
      _qty = $v.qty;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderCreateItemsInner other) {
    _$v = other as _$OrderCreateItemsInner;
  }

  @override
  void update(void Function(OrderCreateItemsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderCreateItemsInner build() => _build();

  _$OrderCreateItemsInner _build() {
    final _$result = _$v ??
        _$OrderCreateItemsInner._(
          productId: BuiltValueNullFieldError.checkNotNull(
              productId, r'OrderCreateItemsInner', 'productId'),
          qty: BuiltValueNullFieldError.checkNotNull(
              qty, r'OrderCreateItemsInner', 'qty'),
          note: note,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
