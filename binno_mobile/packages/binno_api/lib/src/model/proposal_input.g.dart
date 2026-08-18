// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proposal_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProposalInput extends ProposalInput {
  @override
  final BuiltList<ProposalInputItemsInner> items;
  @override
  final int prepDays;
  @override
  final String? note;

  factory _$ProposalInput([void Function(ProposalInputBuilder)? updates]) =>
      (ProposalInputBuilder()..update(updates))._build();

  _$ProposalInput._({required this.items, required this.prepDays, this.note})
      : super._();
  @override
  ProposalInput rebuild(void Function(ProposalInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProposalInputBuilder toBuilder() => ProposalInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProposalInput &&
        items == other.items &&
        prepDays == other.prepDays &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, prepDays.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProposalInput')
          ..add('items', items)
          ..add('prepDays', prepDays)
          ..add('note', note))
        .toString();
  }
}

class ProposalInputBuilder
    implements Builder<ProposalInput, ProposalInputBuilder> {
  _$ProposalInput? _$v;

  ListBuilder<ProposalInputItemsInner>? _items;
  ListBuilder<ProposalInputItemsInner> get items =>
      _$this._items ??= ListBuilder<ProposalInputItemsInner>();
  set items(ListBuilder<ProposalInputItemsInner>? items) =>
      _$this._items = items;

  int? _prepDays;
  int? get prepDays => _$this._prepDays;
  set prepDays(int? prepDays) => _$this._prepDays = prepDays;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  ProposalInputBuilder() {
    ProposalInput._defaults(this);
  }

  ProposalInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _prepDays = $v.prepDays;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProposalInput other) {
    _$v = other as _$ProposalInput;
  }

  @override
  void update(void Function(ProposalInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProposalInput build() => _build();

  _$ProposalInput _build() {
    _$ProposalInput _$result;
    try {
      _$result = _$v ??
          _$ProposalInput._(
            items: items.build(),
            prepDays: BuiltValueNullFieldError.checkNotNull(
                prepDays, r'ProposalInput', 'prepDays'),
            note: note,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProposalInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
