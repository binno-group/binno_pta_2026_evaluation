// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_card_supplier.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ProductCardSupplierVerificationLevelEnum
    _$productCardSupplierVerificationLevelEnum_basic =
    const ProductCardSupplierVerificationLevelEnum._('basic');
const ProductCardSupplierVerificationLevelEnum
    _$productCardSupplierVerificationLevelEnum_advanced =
    const ProductCardSupplierVerificationLevelEnum._('advanced');

ProductCardSupplierVerificationLevelEnum
    _$productCardSupplierVerificationLevelEnumValueOf(String name) {
  switch (name) {
    case 'basic':
      return _$productCardSupplierVerificationLevelEnum_basic;
    case 'advanced':
      return _$productCardSupplierVerificationLevelEnum_advanced;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ProductCardSupplierVerificationLevelEnum>
    _$productCardSupplierVerificationLevelEnumValues = BuiltSet<
        ProductCardSupplierVerificationLevelEnum>(const <ProductCardSupplierVerificationLevelEnum>[
  _$productCardSupplierVerificationLevelEnum_basic,
  _$productCardSupplierVerificationLevelEnum_advanced,
]);

Serializer<ProductCardSupplierVerificationLevelEnum>
    _$productCardSupplierVerificationLevelEnumSerializer =
    _$ProductCardSupplierVerificationLevelEnumSerializer();

class _$ProductCardSupplierVerificationLevelEnumSerializer
    implements PrimitiveSerializer<ProductCardSupplierVerificationLevelEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'basic': 'basic',
    'advanced': 'advanced',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'basic': 'basic',
    'advanced': 'advanced',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ProductCardSupplierVerificationLevelEnum
  ];
  @override
  final String wireName = 'ProductCardSupplierVerificationLevelEnum';

  @override
  Object serialize(Serializers serializers,
          ProductCardSupplierVerificationLevelEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ProductCardSupplierVerificationLevelEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ProductCardSupplierVerificationLevelEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ProductCardSupplier extends ProductCardSupplier {
  @override
  final String? id;
  @override
  final String? name;
  @override
  final num? rating;
  @override
  final bool? isVerified;
  @override
  final ProductCardSupplierVerificationLevelEnum? verificationLevel;

  factory _$ProductCardSupplier(
          [void Function(ProductCardSupplierBuilder)? updates]) =>
      (ProductCardSupplierBuilder()..update(updates))._build();

  _$ProductCardSupplier._(
      {this.id,
      this.name,
      this.rating,
      this.isVerified,
      this.verificationLevel})
      : super._();
  @override
  ProductCardSupplier rebuild(
          void Function(ProductCardSupplierBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProductCardSupplierBuilder toBuilder() =>
      ProductCardSupplierBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProductCardSupplier &&
        id == other.id &&
        name == other.name &&
        rating == other.rating &&
        isVerified == other.isVerified &&
        verificationLevel == other.verificationLevel;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, rating.hashCode);
    _$hash = $jc(_$hash, isVerified.hashCode);
    _$hash = $jc(_$hash, verificationLevel.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProductCardSupplier')
          ..add('id', id)
          ..add('name', name)
          ..add('rating', rating)
          ..add('isVerified', isVerified)
          ..add('verificationLevel', verificationLevel))
        .toString();
  }
}

class ProductCardSupplierBuilder
    implements Builder<ProductCardSupplier, ProductCardSupplierBuilder> {
  _$ProductCardSupplier? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  num? _rating;
  num? get rating => _$this._rating;
  set rating(num? rating) => _$this._rating = rating;

  bool? _isVerified;
  bool? get isVerified => _$this._isVerified;
  set isVerified(bool? isVerified) => _$this._isVerified = isVerified;

  ProductCardSupplierVerificationLevelEnum? _verificationLevel;
  ProductCardSupplierVerificationLevelEnum? get verificationLevel =>
      _$this._verificationLevel;
  set verificationLevel(
          ProductCardSupplierVerificationLevelEnum? verificationLevel) =>
      _$this._verificationLevel = verificationLevel;

  ProductCardSupplierBuilder() {
    ProductCardSupplier._defaults(this);
  }

  ProductCardSupplierBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _rating = $v.rating;
      _isVerified = $v.isVerified;
      _verificationLevel = $v.verificationLevel;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProductCardSupplier other) {
    _$v = other as _$ProductCardSupplier;
  }

  @override
  void update(void Function(ProductCardSupplierBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProductCardSupplier build() => _build();

  _$ProductCardSupplier _build() {
    final _$result = _$v ??
        _$ProductCardSupplier._(
          id: id,
          name: name,
          rating: rating,
          isVerified: isVerified,
          verificationLevel: verificationLevel,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
