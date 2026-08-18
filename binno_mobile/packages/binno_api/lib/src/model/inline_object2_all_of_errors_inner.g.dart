// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inline_object2_all_of_errors_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InlineObject2AllOfErrorsInner extends InlineObject2AllOfErrorsInner {
  @override
  final String? field;
  @override
  final String? message;

  factory _$InlineObject2AllOfErrorsInner(
          [void Function(InlineObject2AllOfErrorsInnerBuilder)? updates]) =>
      (InlineObject2AllOfErrorsInnerBuilder()..update(updates))._build();

  _$InlineObject2AllOfErrorsInner._({this.field, this.message}) : super._();
  @override
  InlineObject2AllOfErrorsInner rebuild(
          void Function(InlineObject2AllOfErrorsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InlineObject2AllOfErrorsInnerBuilder toBuilder() =>
      InlineObject2AllOfErrorsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InlineObject2AllOfErrorsInner &&
        field == other.field &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, field.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InlineObject2AllOfErrorsInner')
          ..add('field', field)
          ..add('message', message))
        .toString();
  }
}

class InlineObject2AllOfErrorsInnerBuilder
    implements
        Builder<InlineObject2AllOfErrorsInner,
            InlineObject2AllOfErrorsInnerBuilder> {
  _$InlineObject2AllOfErrorsInner? _$v;

  String? _field;
  String? get field => _$this._field;
  set field(String? field) => _$this._field = field;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  InlineObject2AllOfErrorsInnerBuilder() {
    InlineObject2AllOfErrorsInner._defaults(this);
  }

  InlineObject2AllOfErrorsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _field = $v.field;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InlineObject2AllOfErrorsInner other) {
    _$v = other as _$InlineObject2AllOfErrorsInner;
  }

  @override
  void update(void Function(InlineObject2AllOfErrorsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InlineObject2AllOfErrorsInner build() => _build();

  _$InlineObject2AllOfErrorsInner _build() {
    final _$result = _$v ??
        _$InlineObject2AllOfErrorsInner._(
          field: field,
          message: message,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
