// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_orders_id_reject_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierOrdersIdRejectPostRequest
    extends SupplierOrdersIdRejectPostRequest {
  @override
  final String reason;

  factory _$SupplierOrdersIdRejectPostRequest(
          [void Function(SupplierOrdersIdRejectPostRequestBuilder)? updates]) =>
      (SupplierOrdersIdRejectPostRequestBuilder()..update(updates))._build();

  _$SupplierOrdersIdRejectPostRequest._({required this.reason}) : super._();
  @override
  SupplierOrdersIdRejectPostRequest rebuild(
          void Function(SupplierOrdersIdRejectPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierOrdersIdRejectPostRequestBuilder toBuilder() =>
      SupplierOrdersIdRejectPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierOrdersIdRejectPostRequest && reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SupplierOrdersIdRejectPostRequest')
          ..add('reason', reason))
        .toString();
  }
}

class SupplierOrdersIdRejectPostRequestBuilder
    implements
        Builder<SupplierOrdersIdRejectPostRequest,
            SupplierOrdersIdRejectPostRequestBuilder> {
  _$SupplierOrdersIdRejectPostRequest? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  SupplierOrdersIdRejectPostRequestBuilder() {
    SupplierOrdersIdRejectPostRequest._defaults(this);
  }

  SupplierOrdersIdRejectPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierOrdersIdRejectPostRequest other) {
    _$v = other as _$SupplierOrdersIdRejectPostRequest;
  }

  @override
  void update(
      void Function(SupplierOrdersIdRejectPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierOrdersIdRejectPostRequest build() => _build();

  _$SupplierOrdersIdRejectPostRequest _build() {
    final _$result = _$v ??
        _$SupplierOrdersIdRejectPostRequest._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'SupplierOrdersIdRejectPostRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
