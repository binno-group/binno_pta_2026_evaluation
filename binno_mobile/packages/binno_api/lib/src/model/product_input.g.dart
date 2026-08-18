// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ProductInputPriceModelEnum _$productInputPriceModelEnum_fixed =
    const ProductInputPriceModelEnum._('fixed');
const ProductInputPriceModelEnum _$productInputPriceModelEnum_range =
    const ProductInputPriceModelEnum._('range');

ProductInputPriceModelEnum _$productInputPriceModelEnumValueOf(String name) {
  switch (name) {
    case 'fixed':
      return _$productInputPriceModelEnum_fixed;
    case 'range':
      return _$productInputPriceModelEnum_range;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ProductInputPriceModelEnum> _$productInputPriceModelEnumValues =
    BuiltSet<ProductInputPriceModelEnum>(const <ProductInputPriceModelEnum>[
  _$productInputPriceModelEnum_fixed,
  _$productInputPriceModelEnum_range,
]);

const ProductInputUnitEnum _$productInputUnitEnum_dona =
    const ProductInputUnitEnum._('dona');
const ProductInputUnitEnum _$productInputUnitEnum_m2 =
    const ProductInputUnitEnum._('m2');
const ProductInputUnitEnum _$productInputUnitEnum_pogm =
    const ProductInputUnitEnum._('pogm');
const ProductInputUnitEnum _$productInputUnitEnum_toplam =
    const ProductInputUnitEnum._('toplam');
const ProductInputUnitEnum _$productInputUnitEnum_kg =
    const ProductInputUnitEnum._('kg');

ProductInputUnitEnum _$productInputUnitEnumValueOf(String name) {
  switch (name) {
    case 'dona':
      return _$productInputUnitEnum_dona;
    case 'm2':
      return _$productInputUnitEnum_m2;
    case 'pogm':
      return _$productInputUnitEnum_pogm;
    case 'toplam':
      return _$productInputUnitEnum_toplam;
    case 'kg':
      return _$productInputUnitEnum_kg;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ProductInputUnitEnum> _$productInputUnitEnumValues =
    BuiltSet<ProductInputUnitEnum>(const <ProductInputUnitEnum>[
  _$productInputUnitEnum_dona,
  _$productInputUnitEnum_m2,
  _$productInputUnitEnum_pogm,
  _$productInputUnitEnum_toplam,
  _$productInputUnitEnum_kg,
]);

const ProductInputWeightClassEnum _$productInputWeightClassEnum_light =
    const ProductInputWeightClassEnum._('light');
const ProductInputWeightClassEnum _$productInputWeightClassEnum_heavy =
    const ProductInputWeightClassEnum._('heavy');
const ProductInputWeightClassEnum _$productInputWeightClassEnum_fragile =
    const ProductInputWeightClassEnum._('fragile');

ProductInputWeightClassEnum _$productInputWeightClassEnumValueOf(String name) {
  switch (name) {
    case 'light':
      return _$productInputWeightClassEnum_light;
    case 'heavy':
      return _$productInputWeightClassEnum_heavy;
    case 'fragile':
      return _$productInputWeightClassEnum_fragile;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ProductInputWeightClassEnum>
    _$productInputWeightClassEnumValues =
    BuiltSet<ProductInputWeightClassEnum>(const <ProductInputWeightClassEnum>[
  _$productInputWeightClassEnum_light,
  _$productInputWeightClassEnum_heavy,
  _$productInputWeightClassEnum_fragile,
]);

Serializer<ProductInputPriceModelEnum> _$productInputPriceModelEnumSerializer =
    _$ProductInputPriceModelEnumSerializer();
Serializer<ProductInputUnitEnum> _$productInputUnitEnumSerializer =
    _$ProductInputUnitEnumSerializer();
Serializer<ProductInputWeightClassEnum>
    _$productInputWeightClassEnumSerializer =
    _$ProductInputWeightClassEnumSerializer();

class _$ProductInputPriceModelEnumSerializer
    implements PrimitiveSerializer<ProductInputPriceModelEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fixed': 'fixed',
    'range': 'range',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fixed': 'fixed',
    'range': 'range',
  };

  @override
  final Iterable<Type> types = const <Type>[ProductInputPriceModelEnum];
  @override
  final String wireName = 'ProductInputPriceModelEnum';

  @override
  Object serialize(Serializers serializers, ProductInputPriceModelEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ProductInputPriceModelEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ProductInputPriceModelEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ProductInputUnitEnumSerializer
    implements PrimitiveSerializer<ProductInputUnitEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'dona': 'dona',
    'm2': 'm2',
    'pogm': 'pogm',
    'toplam': 'toplam',
    'kg': 'kg',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'dona': 'dona',
    'm2': 'm2',
    'pogm': 'pogm',
    'toplam': 'toplam',
    'kg': 'kg',
  };

  @override
  final Iterable<Type> types = const <Type>[ProductInputUnitEnum];
  @override
  final String wireName = 'ProductInputUnitEnum';

  @override
  Object serialize(Serializers serializers, ProductInputUnitEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ProductInputUnitEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ProductInputUnitEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ProductInputWeightClassEnumSerializer
    implements PrimitiveSerializer<ProductInputWeightClassEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'light': 'light',
    'heavy': 'heavy',
    'fragile': 'fragile',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'light': 'light',
    'heavy': 'heavy',
    'fragile': 'fragile',
  };

  @override
  final Iterable<Type> types = const <Type>[ProductInputWeightClassEnum];
  @override
  final String wireName = 'ProductInputWeightClassEnum';

  @override
  Object serialize(Serializers serializers, ProductInputWeightClassEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ProductInputWeightClassEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ProductInputWeightClassEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ProductInput extends ProductInput {
  @override
  final String title;
  @override
  final int categoryId;
  @override
  final String? description;
  @override
  final ProductInputPriceModelEnum priceModel;
  @override
  final int? priceFixed;
  @override
  final int? priceMin;
  @override
  final int? priceMax;
  @override
  final ProductInputUnitEnum unit;
  @override
  final ProductInputWeightClassEnum weightClass;

  factory _$ProductInput([void Function(ProductInputBuilder)? updates]) =>
      (ProductInputBuilder()..update(updates))._build();

  _$ProductInput._(
      {required this.title,
      required this.categoryId,
      this.description,
      required this.priceModel,
      this.priceFixed,
      this.priceMin,
      this.priceMax,
      required this.unit,
      required this.weightClass})
      : super._();
  @override
  ProductInput rebuild(void Function(ProductInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProductInputBuilder toBuilder() => ProductInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProductInput &&
        title == other.title &&
        categoryId == other.categoryId &&
        description == other.description &&
        priceModel == other.priceModel &&
        priceFixed == other.priceFixed &&
        priceMin == other.priceMin &&
        priceMax == other.priceMax &&
        unit == other.unit &&
        weightClass == other.weightClass;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, categoryId.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, priceModel.hashCode);
    _$hash = $jc(_$hash, priceFixed.hashCode);
    _$hash = $jc(_$hash, priceMin.hashCode);
    _$hash = $jc(_$hash, priceMax.hashCode);
    _$hash = $jc(_$hash, unit.hashCode);
    _$hash = $jc(_$hash, weightClass.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProductInput')
          ..add('title', title)
          ..add('categoryId', categoryId)
          ..add('description', description)
          ..add('priceModel', priceModel)
          ..add('priceFixed', priceFixed)
          ..add('priceMin', priceMin)
          ..add('priceMax', priceMax)
          ..add('unit', unit)
          ..add('weightClass', weightClass))
        .toString();
  }
}

class ProductInputBuilder
    implements Builder<ProductInput, ProductInputBuilder> {
  _$ProductInput? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  int? _categoryId;
  int? get categoryId => _$this._categoryId;
  set categoryId(int? categoryId) => _$this._categoryId = categoryId;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  ProductInputPriceModelEnum? _priceModel;
  ProductInputPriceModelEnum? get priceModel => _$this._priceModel;
  set priceModel(ProductInputPriceModelEnum? priceModel) =>
      _$this._priceModel = priceModel;

  int? _priceFixed;
  int? get priceFixed => _$this._priceFixed;
  set priceFixed(int? priceFixed) => _$this._priceFixed = priceFixed;

  int? _priceMin;
  int? get priceMin => _$this._priceMin;
  set priceMin(int? priceMin) => _$this._priceMin = priceMin;

  int? _priceMax;
  int? get priceMax => _$this._priceMax;
  set priceMax(int? priceMax) => _$this._priceMax = priceMax;

  ProductInputUnitEnum? _unit;
  ProductInputUnitEnum? get unit => _$this._unit;
  set unit(ProductInputUnitEnum? unit) => _$this._unit = unit;

  ProductInputWeightClassEnum? _weightClass;
  ProductInputWeightClassEnum? get weightClass => _$this._weightClass;
  set weightClass(ProductInputWeightClassEnum? weightClass) =>
      _$this._weightClass = weightClass;

  ProductInputBuilder() {
    ProductInput._defaults(this);
  }

  ProductInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _categoryId = $v.categoryId;
      _description = $v.description;
      _priceModel = $v.priceModel;
      _priceFixed = $v.priceFixed;
      _priceMin = $v.priceMin;
      _priceMax = $v.priceMax;
      _unit = $v.unit;
      _weightClass = $v.weightClass;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProductInput other) {
    _$v = other as _$ProductInput;
  }

  @override
  void update(void Function(ProductInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProductInput build() => _build();

  _$ProductInput _build() {
    final _$result = _$v ??
        _$ProductInput._(
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'ProductInput', 'title'),
          categoryId: BuiltValueNullFieldError.checkNotNull(
              categoryId, r'ProductInput', 'categoryId'),
          description: description,
          priceModel: BuiltValueNullFieldError.checkNotNull(
              priceModel, r'ProductInput', 'priceModel'),
          priceFixed: priceFixed,
          priceMin: priceMin,
          priceMax: priceMax,
          unit: BuiltValueNullFieldError.checkNotNull(
              unit, r'ProductInput', 'unit'),
          weightClass: BuiltValueNullFieldError.checkNotNull(
              weightClass, r'ProductInput', 'weightClass'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
