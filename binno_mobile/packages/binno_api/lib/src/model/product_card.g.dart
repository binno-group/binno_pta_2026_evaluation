// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_card.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProductCard extends ProductCard {
  @override
  final String? id;
  @override
  final String? title;
  @override
  final String? priceDisplay;
  @override
  final String? unit;
  @override
  final String? mainPhoto;
  @override
  final ProductCardSupplier? supplier;
  @override
  final String? categoryPath;

  factory _$ProductCard([void Function(ProductCardBuilder)? updates]) =>
      (ProductCardBuilder()..update(updates))._build();

  _$ProductCard._(
      {this.id,
      this.title,
      this.priceDisplay,
      this.unit,
      this.mainPhoto,
      this.supplier,
      this.categoryPath})
      : super._();
  @override
  ProductCard rebuild(void Function(ProductCardBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProductCardBuilder toBuilder() => ProductCardBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProductCard &&
        id == other.id &&
        title == other.title &&
        priceDisplay == other.priceDisplay &&
        unit == other.unit &&
        mainPhoto == other.mainPhoto &&
        supplier == other.supplier &&
        categoryPath == other.categoryPath;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, priceDisplay.hashCode);
    _$hash = $jc(_$hash, unit.hashCode);
    _$hash = $jc(_$hash, mainPhoto.hashCode);
    _$hash = $jc(_$hash, supplier.hashCode);
    _$hash = $jc(_$hash, categoryPath.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProductCard')
          ..add('id', id)
          ..add('title', title)
          ..add('priceDisplay', priceDisplay)
          ..add('unit', unit)
          ..add('mainPhoto', mainPhoto)
          ..add('supplier', supplier)
          ..add('categoryPath', categoryPath))
        .toString();
  }
}

class ProductCardBuilder implements Builder<ProductCard, ProductCardBuilder> {
  _$ProductCard? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _priceDisplay;
  String? get priceDisplay => _$this._priceDisplay;
  set priceDisplay(String? priceDisplay) => _$this._priceDisplay = priceDisplay;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  String? _mainPhoto;
  String? get mainPhoto => _$this._mainPhoto;
  set mainPhoto(String? mainPhoto) => _$this._mainPhoto = mainPhoto;

  ProductCardSupplierBuilder? _supplier;
  ProductCardSupplierBuilder get supplier =>
      _$this._supplier ??= ProductCardSupplierBuilder();
  set supplier(ProductCardSupplierBuilder? supplier) =>
      _$this._supplier = supplier;

  String? _categoryPath;
  String? get categoryPath => _$this._categoryPath;
  set categoryPath(String? categoryPath) => _$this._categoryPath = categoryPath;

  ProductCardBuilder() {
    ProductCard._defaults(this);
  }

  ProductCardBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _priceDisplay = $v.priceDisplay;
      _unit = $v.unit;
      _mainPhoto = $v.mainPhoto;
      _supplier = $v.supplier?.toBuilder();
      _categoryPath = $v.categoryPath;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProductCard other) {
    _$v = other as _$ProductCard;
  }

  @override
  void update(void Function(ProductCardBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProductCard build() => _build();

  _$ProductCard _build() {
    _$ProductCard _$result;
    try {
      _$result = _$v ??
          _$ProductCard._(
            id: id,
            title: title,
            priceDisplay: priceDisplay,
            unit: unit,
            mainPhoto: mainPhoto,
            supplier: _supplier?.build(),
            categoryPath: categoryPath,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'supplier';
        _supplier?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProductCard', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
