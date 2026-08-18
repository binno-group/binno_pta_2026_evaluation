// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proposal_input_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProposalInputItemsInner extends ProposalInputItemsInner {
  @override
  final String productId;
  @override
  final int unitPrice;

  factory _$ProposalInputItemsInner(
          [void Function(ProposalInputItemsInnerBuilder)? updates]) =>
      (ProposalInputItemsInnerBuilder()..update(updates))._build();

  _$ProposalInputItemsInner._(
      {required this.productId, required this.unitPrice})
      : super._();
  @override
  ProposalInputItemsInner rebuild(
          void Function(ProposalInputItemsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProposalInputItemsInnerBuilder toBuilder() =>
      ProposalInputItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProposalInputItemsInner &&
        productId == other.productId &&
        unitPrice == other.unitPrice;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, unitPrice.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProposalInputItemsInner')
          ..add('productId', productId)
          ..add('unitPrice', unitPrice))
        .toString();
  }
}

class ProposalInputItemsInnerBuilder
    implements
        Builder<ProposalInputItemsInner, ProposalInputItemsInnerBuilder> {
  _$ProposalInputItemsInner? _$v;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  int? _unitPrice;
  int? get unitPrice => _$this._unitPrice;
  set unitPrice(int? unitPrice) => _$this._unitPrice = unitPrice;

  ProposalInputItemsInnerBuilder() {
    ProposalInputItemsInner._defaults(this);
  }

  ProposalInputItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _productId = $v.productId;
      _unitPrice = $v.unitPrice;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProposalInputItemsInner other) {
    _$v = other as _$ProposalInputItemsInner;
  }

  @override
  void update(void Function(ProposalInputItemsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProposalInputItemsInner build() => _build();

  _$ProposalInputItemsInner _build() {
    final _$result = _$v ??
        _$ProposalInputItemsInner._(
          productId: BuiltValueNullFieldError.checkNotNull(
              productId, r'ProposalInputItemsInner', 'productId'),
          unitPrice: BuiltValueNullFieldError.checkNotNull(
              unitPrice, r'ProposalInputItemsInner', 'unitPrice'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
