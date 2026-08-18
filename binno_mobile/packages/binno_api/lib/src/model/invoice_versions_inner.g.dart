// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_versions_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InvoiceVersionsInner extends InvoiceVersionsInner {
  @override
  final int? version;
  @override
  final String? status;

  factory _$InvoiceVersionsInner(
          [void Function(InvoiceVersionsInnerBuilder)? updates]) =>
      (InvoiceVersionsInnerBuilder()..update(updates))._build();

  _$InvoiceVersionsInner._({this.version, this.status}) : super._();
  @override
  InvoiceVersionsInner rebuild(
          void Function(InvoiceVersionsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InvoiceVersionsInnerBuilder toBuilder() =>
      InvoiceVersionsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InvoiceVersionsInner &&
        version == other.version &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InvoiceVersionsInner')
          ..add('version', version)
          ..add('status', status))
        .toString();
  }
}

class InvoiceVersionsInnerBuilder
    implements Builder<InvoiceVersionsInner, InvoiceVersionsInnerBuilder> {
  _$InvoiceVersionsInner? _$v;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  InvoiceVersionsInnerBuilder() {
    InvoiceVersionsInner._defaults(this);
  }

  InvoiceVersionsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InvoiceVersionsInner other) {
    _$v = other as _$InvoiceVersionsInner;
  }

  @override
  void update(void Function(InvoiceVersionsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InvoiceVersionsInner build() => _build();

  _$InvoiceVersionsInner _build() {
    final _$result = _$v ??
        _$InvoiceVersionsInner._(
          version: version,
          status: status,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
