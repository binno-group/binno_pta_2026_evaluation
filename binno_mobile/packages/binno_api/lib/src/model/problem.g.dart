// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

abstract class ProblemBuilder {
  void replace(Problem other);
  void update(void Function(ProblemBuilder) updates);
  String? get type;
  set type(String? type);

  String? get title;
  set title(String? title);

  int? get status;
  set status(int? status);

  String? get detail;
  set detail(String? detail);

  String? get instance;
  set instance(String? instance);
}

class _$$Problem extends $Problem {
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

  factory _$$Problem([void Function($ProblemBuilder)? updates]) =>
      ($ProblemBuilder()..update(updates))._build();

  _$$Problem._({this.type, this.title, this.status, this.detail, this.instance})
      : super._();
  @override
  $Problem rebuild(void Function($ProblemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $ProblemBuilder toBuilder() => $ProblemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $Problem &&
        type == other.type &&
        title == other.title &&
        status == other.status &&
        detail == other.detail &&
        instance == other.instance;
  }

  @override
  int get hashCode {
    var _$hash = 0;
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
    return (newBuiltValueToStringHelper(r'$Problem')
          ..add('type', type)
          ..add('title', title)
          ..add('status', status)
          ..add('detail', detail)
          ..add('instance', instance))
        .toString();
  }
}

class $ProblemBuilder
    implements Builder<$Problem, $ProblemBuilder>, ProblemBuilder {
  _$$Problem? _$v;

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

  $ProblemBuilder() {
    $Problem._defaults(this);
  }

  $ProblemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
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
  void replace(covariant $Problem other) {
    _$v = other as _$$Problem;
  }

  @override
  void update(void Function($ProblemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $Problem build() => _build();

  _$$Problem _build() {
    final _$result = _$v ??
        _$$Problem._(
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
