// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_orders_id_accept_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierOrdersIdAcceptPostRequest
    extends SupplierOrdersIdAcceptPostRequest {
  @override
  final BuiltList<SupplierOrdersIdAcceptPostRequestFinalItemsInner> finalItems;
  @override
  final int? prepTimeEstimate;

  factory _$SupplierOrdersIdAcceptPostRequest(
          [void Function(SupplierOrdersIdAcceptPostRequestBuilder)? updates]) =>
      (SupplierOrdersIdAcceptPostRequestBuilder()..update(updates))._build();

  _$SupplierOrdersIdAcceptPostRequest._(
      {required this.finalItems, this.prepTimeEstimate})
      : super._();
  @override
  SupplierOrdersIdAcceptPostRequest rebuild(
          void Function(SupplierOrdersIdAcceptPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierOrdersIdAcceptPostRequestBuilder toBuilder() =>
      SupplierOrdersIdAcceptPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierOrdersIdAcceptPostRequest &&
        finalItems == other.finalItems &&
        prepTimeEstimate == other.prepTimeEstimate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, finalItems.hashCode);
    _$hash = $jc(_$hash, prepTimeEstimate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SupplierOrdersIdAcceptPostRequest')
          ..add('finalItems', finalItems)
          ..add('prepTimeEstimate', prepTimeEstimate))
        .toString();
  }
}

class SupplierOrdersIdAcceptPostRequestBuilder
    implements
        Builder<SupplierOrdersIdAcceptPostRequest,
            SupplierOrdersIdAcceptPostRequestBuilder> {
  _$SupplierOrdersIdAcceptPostRequest? _$v;

  ListBuilder<SupplierOrdersIdAcceptPostRequestFinalItemsInner>? _finalItems;
  ListBuilder<SupplierOrdersIdAcceptPostRequestFinalItemsInner>
      get finalItems => _$this._finalItems ??=
          ListBuilder<SupplierOrdersIdAcceptPostRequestFinalItemsInner>();
  set finalItems(
          ListBuilder<SupplierOrdersIdAcceptPostRequestFinalItemsInner>?
              finalItems) =>
      _$this._finalItems = finalItems;

  int? _prepTimeEstimate;
  int? get prepTimeEstimate => _$this._prepTimeEstimate;
  set prepTimeEstimate(int? prepTimeEstimate) =>
      _$this._prepTimeEstimate = prepTimeEstimate;

  SupplierOrdersIdAcceptPostRequestBuilder() {
    SupplierOrdersIdAcceptPostRequest._defaults(this);
  }

  SupplierOrdersIdAcceptPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _finalItems = $v.finalItems.toBuilder();
      _prepTimeEstimate = $v.prepTimeEstimate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierOrdersIdAcceptPostRequest other) {
    _$v = other as _$SupplierOrdersIdAcceptPostRequest;
  }

  @override
  void update(
      void Function(SupplierOrdersIdAcceptPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierOrdersIdAcceptPostRequest build() => _build();

  _$SupplierOrdersIdAcceptPostRequest _build() {
    _$SupplierOrdersIdAcceptPostRequest _$result;
    try {
      _$result = _$v ??
          _$SupplierOrdersIdAcceptPostRequest._(
            finalItems: finalItems.build(),
            prepTimeEstimate: prepTimeEstimate,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'finalItems';
        finalItems.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SupplierOrdersIdAcceptPostRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
