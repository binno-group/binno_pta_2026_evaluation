// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_products_post201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierProductsPost201Response
    extends SupplierProductsPost201Response {
  @override
  final String? productId;
  @override
  final String? status;

  factory _$SupplierProductsPost201Response(
          [void Function(SupplierProductsPost201ResponseBuilder)? updates]) =>
      (SupplierProductsPost201ResponseBuilder()..update(updates))._build();

  _$SupplierProductsPost201Response._({this.productId, this.status})
      : super._();
  @override
  SupplierProductsPost201Response rebuild(
          void Function(SupplierProductsPost201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierProductsPost201ResponseBuilder toBuilder() =>
      SupplierProductsPost201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierProductsPost201Response &&
        productId == other.productId &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SupplierProductsPost201Response')
          ..add('productId', productId)
          ..add('status', status))
        .toString();
  }
}

class SupplierProductsPost201ResponseBuilder
    implements
        Builder<SupplierProductsPost201Response,
            SupplierProductsPost201ResponseBuilder> {
  _$SupplierProductsPost201Response? _$v;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  SupplierProductsPost201ResponseBuilder() {
    SupplierProductsPost201Response._defaults(this);
  }

  SupplierProductsPost201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _productId = $v.productId;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierProductsPost201Response other) {
    _$v = other as _$SupplierProductsPost201Response;
  }

  @override
  void update(void Function(SupplierProductsPost201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierProductsPost201Response build() => _build();

  _$SupplierProductsPost201Response _build() {
    final _$result = _$v ??
        _$SupplierProductsPost201Response._(
          productId: productId,
          status: status,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
