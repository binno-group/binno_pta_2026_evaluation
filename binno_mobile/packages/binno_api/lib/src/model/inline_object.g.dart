// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inline_object.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InlineObject extends InlineObject {
  @override
  final int? retryAfter;
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

  factory _$InlineObject([void Function(InlineObjectBuilder)? updates]) =>
      (InlineObjectBuilder()..update(updates))._build();

  _$InlineObject._(
      {this.retryAfter,
      this.type,
      this.title,
      this.status,
      this.detail,
      this.instance})
      : super._();
  @override
  InlineObject rebuild(void Function(InlineObjectBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InlineObjectBuilder toBuilder() => InlineObjectBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InlineObject &&
        retryAfter == other.retryAfter &&
        type == other.type &&
        title == other.title &&
        status == other.status &&
        detail == other.detail &&
        instance == other.instance;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, retryAfter.hashCode);
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
    return (newBuiltValueToStringHelper(r'InlineObject')
          ..add('retryAfter', retryAfter)
          ..add('type', type)
          ..add('title', title)
          ..add('status', status)
          ..add('detail', detail)
          ..add('instance', instance))
        .toString();
  }
}

class InlineObjectBuilder
    implements Builder<InlineObject, InlineObjectBuilder>, ProblemBuilder {
  _$InlineObject? _$v;

  int? _retryAfter;
  int? get retryAfter => _$this._retryAfter;
  set retryAfter(covariant int? retryAfter) => _$this._retryAfter = retryAfter;

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

  InlineObjectBuilder() {
    InlineObject._defaults(this);
  }

  InlineObjectBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _retryAfter = $v.retryAfter;
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
  void replace(covariant InlineObject other) {
    _$v = other as _$InlineObject;
  }

  @override
  void update(void Function(InlineObjectBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InlineObject build() => _build();

  _$InlineObject _build() {
    final _$result = _$v ??
        _$InlineObject._(
          retryAfter: retryAfter,
          type: type,
          title: title,
          status: status,
          detail: detail,
          instance: instance,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
