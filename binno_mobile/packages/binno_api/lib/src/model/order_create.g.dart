// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderCreate extends OrderCreate {
  @override
  final String supplierId;
  @override
  final BuiltList<OrderCreateItemsInner> items;
  @override
  final OrderCreateDropoff dropoff;
  @override
  final bool? isUrgent;
  @override
  final String? buyerNote;

  factory _$OrderCreate([void Function(OrderCreateBuilder)? updates]) =>
      (OrderCreateBuilder()..update(updates))._build();

  _$OrderCreate._(
      {required this.supplierId,
      required this.items,
      required this.dropoff,
      this.isUrgent,
      this.buyerNote})
      : super._();
  @override
  OrderCreate rebuild(void Function(OrderCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderCreateBuilder toBuilder() => OrderCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderCreate &&
        supplierId == other.supplierId &&
        items == other.items &&
        dropoff == other.dropoff &&
        isUrgent == other.isUrgent &&
        buyerNote == other.buyerNote;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, supplierId.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, dropoff.hashCode);
    _$hash = $jc(_$hash, isUrgent.hashCode);
    _$hash = $jc(_$hash, buyerNote.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrderCreate')
          ..add('supplierId', supplierId)
          ..add('items', items)
          ..add('dropoff', dropoff)
          ..add('isUrgent', isUrgent)
          ..add('buyerNote', buyerNote))
        .toString();
  }
}

class OrderCreateBuilder implements Builder<OrderCreate, OrderCreateBuilder> {
  _$OrderCreate? _$v;

  String? _supplierId;
  String? get supplierId => _$this._supplierId;
  set supplierId(String? supplierId) => _$this._supplierId = supplierId;

  ListBuilder<OrderCreateItemsInner>? _items;
  ListBuilder<OrderCreateItemsInner> get items =>
      _$this._items ??= ListBuilder<OrderCreateItemsInner>();
  set items(ListBuilder<OrderCreateItemsInner>? items) => _$this._items = items;

  OrderCreateDropoffBuilder? _dropoff;
  OrderCreateDropoffBuilder get dropoff =>
      _$this._dropoff ??= OrderCreateDropoffBuilder();
  set dropoff(OrderCreateDropoffBuilder? dropoff) => _$this._dropoff = dropoff;

  bool? _isUrgent;
  bool? get isUrgent => _$this._isUrgent;
  set isUrgent(bool? isUrgent) => _$this._isUrgent = isUrgent;

  String? _buyerNote;
  String? get buyerNote => _$this._buyerNote;
  set buyerNote(String? buyerNote) => _$this._buyerNote = buyerNote;

  OrderCreateBuilder() {
    OrderCreate._defaults(this);
  }

  OrderCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _supplierId = $v.supplierId;
      _items = $v.items.toBuilder();
      _dropoff = $v.dropoff.toBuilder();
      _isUrgent = $v.isUrgent;
      _buyerNote = $v.buyerNote;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderCreate other) {
    _$v = other as _$OrderCreate;
  }

  @override
  void update(void Function(OrderCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderCreate build() => _build();

  _$OrderCreate _build() {
    _$OrderCreate _$result;
    try {
      _$result = _$v ??
          _$OrderCreate._(
            supplierId: BuiltValueNullFieldError.checkNotNull(
                supplierId, r'OrderCreate', 'supplierId'),
            items: items.build(),
            dropoff: dropoff.build(),
            isUrgent: isUrgent,
            buyerNote: buyerNote,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
        _$failedField = 'dropoff';
        dropoff.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OrderCreate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
