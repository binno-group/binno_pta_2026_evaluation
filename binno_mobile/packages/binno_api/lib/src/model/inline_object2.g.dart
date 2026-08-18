// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inline_object2.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InlineObject2 extends InlineObject2 {
  @override
  final BuiltList<InlineObject2AllOfErrorsInner>? errors;
  @override
  final String? type;
  @override
  final String? title;
  @override
  final int? status;
  @override
  final String? detail;
  @override
  final String? instance;

  factory _$InlineObject2([void Function(InlineObject2Builder)? updates]) =>
      (InlineObject2Builder()..update(updates))._build();

  _$InlineObject2._(
      {this.errors,
      this.type,
      this.title,
      this.status,
      this.detail,
      this.instance})
      : super._();
  @override
  InlineObject2 rebuild(void Function(InlineObject2Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InlineObject2Builder toBuilder() => InlineObject2Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InlineObject2 &&
        errors == other.errors &&
        type == other.type &&
        title == other.title &&
        status == other.status &&
        detail == other.detail &&
        instance == other.instance;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, errors.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, detail.hashCode);
    _$hash = $jc(_$hash, instance.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InlineObject2')
          ..add('errors', errors)
          ..add('type', type)
          ..add('title', title)
          ..add('status', status)
          ..add('detail', detail)
          ..add('instance', instance))
        .toString();
  }
}

class InlineObject2Builder
    implements Builder<InlineObject2, InlineObject2Builder>, ProblemBuilder {
  _$InlineObject2? _$v;

  ListBuilder<InlineObject2AllOfErrorsInner>? _errors;
  ListBuilder<InlineObject2AllOfErrorsInner> get errors =>
      _$this._errors ??= ListBuilder<InlineObject2AllOfErrorsInner>();
  set errors(covariant ListBuilder<InlineObject2AllOfErrorsInner>? errors) =>
      _$this._errors = errors;

  String? _type;
  String? get type => _$this._type;
  set type(covariant String? type) => _$this._type = type;

  String? _title;
  String? get title => _$this._title;
  set title(covariant String? title) => _$this._title = title;

  int? _status;
  int? get status => _$this._status;
  set status(covariant int? status) => _$this._status = status;

  String? _detail;
  String? get detail => _$this._detail;
  set detail(covariant String? detail) => _$this._detail = detail;

  String? _instance;
  String? get instance => _$this._instance;
  set instance(covariant String? instance) => _$this._instance = instance;

  InlineObject2Builder() {
    InlineObject2._defaults(this);
  }

  InlineObject2Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _errors = $v.errors?.toBuilder();
      _type = $v.type;
      _title = $v.title;
      _status = $v.status;
      _detail = $v.detail;
      _instance = $v.instance;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant InlineObject2 other) {
    _$v = other as _$InlineObject2;
  }

  @override
  void update(void Function(InlineObject2Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InlineObject2 build() => _build();

  _$InlineObject2 _build() {
    _$InlineObject2 _$result;
    try {
      _$result = _$v ??
          _$InlineObject2._(
            errors: _errors?.build(),
            type: type,
            title: title,
            status: status,
            detail: detail,
            instance: instance,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'errors';
        _errors?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'InlineObject2', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
