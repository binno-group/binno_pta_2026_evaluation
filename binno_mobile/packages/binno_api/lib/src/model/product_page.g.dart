// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProductPage extends ProductPage {
  @override
  final BuiltList<ProductCard>? items;
  @override
  final String? nextCursor;

  factory _$ProductPage([void Function(ProductPageBuilder)? updates]) =>
      (ProductPageBuilder()..update(updates))._build();

  _$ProductPage._({this.items, this.nextCursor}) : super._();
  @override
  ProductPage rebuild(void Function(ProductPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProductPageBuilder toBuilder() => ProductPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProductPage &&
        items == other.items &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProductPage')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class ProductPageBuilder implements Builder<ProductPage, ProductPageBuilder> {
  _$ProductPage? _$v;

  ListBuilder<ProductCard>? _items;
  ListBuilder<ProductCard> get items =>
      _$this._items ??= ListBuilder<ProductCard>();
  set items(ListBuilder<ProductCard>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  ProductPageBuilder() {
    ProductPage._defaults(this);
  }

  ProductPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items?.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProductPage other) {
    _$v = other as _$ProductPage;
  }

  @override
  void update(void Function(ProductPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProductPage build() => _build();

  _$ProductPage _build() {
    _$ProductPage _$result;
    try {
      _$result = _$v ??
          _$ProductPage._(
            items: _items?.build(),
            nextCursor: nextCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        _items?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProductPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
