// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_orders_id_payment_deny_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierOrdersIdPaymentDenyPostRequest
    extends SupplierOrdersIdPaymentDenyPostRequest {
  @override
  final String note;

  factory _$SupplierOrdersIdPaymentDenyPostRequest(
          [void Function(SupplierOrdersIdPaymentDenyPostRequestBuilder)?
              updates]) =>
      (SupplierOrdersIdPaymentDenyPostRequestBuilder()..update(updates))
          ._build();

  _$SupplierOrdersIdPaymentDenyPostRequest._({required this.note}) : super._();
  @override
  SupplierOrdersIdPaymentDenyPostRequest rebuild(
          void Function(SupplierOrdersIdPaymentDenyPostRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierOrdersIdPaymentDenyPostRequestBuilder toBuilder() =>
      SupplierOrdersIdPaymentDenyPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierOrdersIdPaymentDenyPostRequest &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SupplierOrdersIdPaymentDenyPostRequest')
          ..add('note', note))
        .toString();
  }
}

class SupplierOrdersIdPaymentDenyPostRequestBuilder
    implements
        Builder<SupplierOrdersIdPaymentDenyPostRequest,
            SupplierOrdersIdPaymentDenyPostRequestBuilder> {
  _$SupplierOrdersIdPaymentDenyPostRequest? _$v;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  SupplierOrdersIdPaymentDenyPostRequestBuilder() {
    SupplierOrdersIdPaymentDenyPostRequest._defaults(this);
  }

  SupplierOrdersIdPaymentDenyPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierOrdersIdPaymentDenyPostRequest other) {
    _$v = other as _$SupplierOrdersIdPaymentDenyPostRequest;
  }

  @override
  void update(
      void Function(SupplierOrdersIdPaymentDenyPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierOrdersIdPaymentDenyPostRequest build() => _build();

  _$SupplierOrdersIdPaymentDenyPostRequest _build() {
    final _$result = _$v ??
        _$SupplierOrdersIdPaymentDenyPostRequest._(
          note: BuiltValueNullFieldError.checkNotNull(
              note, r'SupplierOrdersIdPaymentDenyPostRequest', 'note'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
