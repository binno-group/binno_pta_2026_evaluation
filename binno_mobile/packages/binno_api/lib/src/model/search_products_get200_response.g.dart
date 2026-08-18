// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_products_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SearchProductsGet200Response extends SearchProductsGet200Response {
  @override
  final BuiltList<ProductCard>? items;
  @override
  final String? nextCursor;
  @override
  final int? totalEstimate;

  factory _$SearchProductsGet200Response(
          [void Function(SearchProductsGet200ResponseBuilder)? updates]) =>
      (SearchProductsGet200ResponseBuilder()..update(updates))._build();

  _$SearchProductsGet200Response._(
      {this.items, this.nextCursor, this.totalEstimate})
      : super._();
  @override
  SearchProductsGet200Response rebuild(
          void Function(SearchProductsGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SearchProductsGet200ResponseBuilder toBuilder() =>
      SearchProductsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchProductsGet200Response &&
        items == other.items &&
        nextCursor == other.nextCursor &&
        totalEstimate == other.totalEstimate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jc(_$hash, totalEstimate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SearchProductsGet200Response')
          ..add('items', items)
          ..add('nextCursor', nextCursor)
          ..add('totalEstimate', totalEstimate))
        .toString();
  }
}

class SearchProductsGet200ResponseBuilder
    implements
        Builder<SearchProductsGet200Response,
            SearchProductsGet200ResponseBuilder> {
  _$SearchProductsGet200Response? _$v;

  ListBuilder<ProductCard>? _items;
  ListBuilder<ProductCard> get items =>
      _$this._items ??= ListBuilder<ProductCard>();
  set items(ListBuilder<ProductCard>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  int? _totalEstimate;
  int? get totalEstimate => _$this._totalEstimate;
  set totalEstimate(int? totalEstimate) =>
      _$this._totalEstimate = totalEstimate;

  SearchProductsGet200ResponseBuilder() {
    SearchProductsGet200Response._defaults(this);
  }

  SearchProductsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items?.toBuilder();
      _nextCursor = $v.nextCursor;
      _totalEstimate = $v.totalEstimate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SearchProductsGet200Response other) {
    _$v = other as _$SearchProductsGet200Response;
  }

  @override
  void update(void Function(SearchProductsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchProductsGet200Response build() => _build();

  _$SearchProductsGet200Response _build() {
    _$SearchProductsGet200Response _$result;
    try {
      _$result = _$v ??
          _$SearchProductsGet200Response._(
            items: _items?.build(),
            nextCursor: nextCursor,
            totalEstimate: totalEstimate,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        _items?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SearchProductsGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
