// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inline_object1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InlineObject1 extends InlineObject1 {
  @override
  final int? attemptsLeft;
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

  factory _$InlineObject1([void Function(InlineObject1Builder)? updates]) =>
      (InlineObject1Builder()..update(updates))._build();

  _$InlineObject1._(
      {this.attemptsLeft,
      this.type,
      this.title,
      this.status,
      this.detail,
      this.instance})
      : super._();
  @override
  InlineObject1 rebuild(void Function(InlineObject1Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InlineObject1Builder toBuilder() => InlineObject1Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InlineObject1 &&
        attemptsLeft == other.attemptsLeft &&
        type == other.type &&
        title == other.title &&
        status == other.status &&
        detail == other.detail &&
        instance == other.instance;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, attemptsLeft.hashCode);
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
    return (newBuiltValueToStringHelper(r'InlineObject1')
          ..add('attemptsLeft', attemptsLeft)
          ..add('type', type)
          ..add('title', title)
          ..add('status', status)
          ..add('detail', detail)
          ..add('instance', instance))
        .toString();
  }
}

class InlineObject1Builder
    implements Builder<InlineObject1, InlineObject1Builder>, ProblemBuilder {
  _$InlineObject1? _$v;

  int? _attemptsLeft;
  int? get attemptsLeft => _$this._attemptsLeft;
  set attemptsLeft(covariant int? attemptsLeft) =>
      _$this._attemptsLeft = attemptsLeft;

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

  InlineObject1Builder() {
    InlineObject1._defaults(this);
  }

  InlineObject1Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _attemptsLeft = $v.attemptsLeft;
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
  void replace(covariant InlineObject1 other) {
    _$v = other as _$InlineObject1;
  }

  @override
  void update(void Function(InlineObject1Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InlineObject1 build() => _build();

  _$InlineObject1 _build() {
    final _$result = _$v ??
        _$InlineObject1._(
          attemptsLeft: attemptsLeft,
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
