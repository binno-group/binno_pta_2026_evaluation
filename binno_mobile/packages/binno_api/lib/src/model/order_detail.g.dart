// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_detail.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderDetail extends OrderDetail {
  @override
  final String? dropoffAddress;
  @override
  final String? invoiceNo;
  @override
  final BuiltList<OrderDetailAllOfItems>? items;
  @override
  final BuiltList<OrderDetailAllOfEvents>? events;
  @override
  final String? id;
  @override
  final String? reference;
  @override
  final String? status;
  @override
  final String? supplierName;
  @override
  final String? itemSummary;
  @override
  final int? totalAmount;
  @override
  final bool? isUrgent;
  @override
  final DateTime? updatedAt;

  factory _$OrderDetail([void Function(OrderDetailBuilder)? updates]) =>
      (OrderDetailBuilder()..update(updates))._build();

  _$OrderDetail._(
      {this.dropoffAddress,
      this.invoiceNo,
      this.items,
      this.events,
      this.id,
      this.reference,
      this.status,
      this.supplierName,
      this.itemSummary,
      this.totalAmount,
      this.isUrgent,
      this.updatedAt})
      : super._();
  @override
  OrderDetail rebuild(void Function(OrderDetailBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderDetailBuilder toBuilder() => OrderDetailBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderDetail &&
        dropoffAddress == other.dropoffAddress &&
        invoiceNo == other.invoiceNo &&
        items == other.items &&
        events == other.events &&
        id == other.id &&
        reference == other.reference &&
        status == other.status &&
        supplierName == other.supplierName &&
        itemSummary == other.itemSummary &&
        totalAmount == other.totalAmount &&
        isUrgent == other.isUrgent &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dropoffAddress.hashCode);
    _$hash = $jc(_$hash, invoiceNo.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, events.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, reference.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, supplierName.hashCode);
    _$hash = $jc(_$hash, itemSummary.hashCode);
    _$hash = $jc(_$hash, totalAmount.hashCode);
    _$hash = $jc(_$hash, isUrgent.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrderDetail')
          ..add('dropoffAddress', dropoffAddress)
          ..add('invoiceNo', invoiceNo)
          ..add('items', items)
          ..add('events', events)
          ..add('id', id)
          ..add('reference', reference)
          ..add('status', status)
          ..add('supplierName', supplierName)
          ..add('itemSummary', itemSummary)
          ..add('totalAmount', totalAmount)
          ..add('isUrgent', isUrgent)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class OrderDetailBuilder
    implements Builder<OrderDetail, OrderDetailBuilder>, OrderSummaryBuilder {
  _$OrderDetail? _$v;

  String? _dropoffAddress;
  String? get dropoffAddress => _$this._dropoffAddress;
  set dropoffAddress(covariant String? dropoffAddress) =>
      _$this._dropoffAddress = dropoffAddress;

  String? _invoiceNo;
  String? get invoiceNo => _$this._invoiceNo;
  set invoiceNo(covariant String? invoiceNo) => _$this._invoiceNo = invoiceNo;

  ListBuilder<OrderDetailAllOfItems>? _items;
  ListBuilder<OrderDetailAllOfItems> get items =>
      _$this._items ??= ListBuilder<OrderDetailAllOfItems>();
  set items(covariant ListBuilder<OrderDetailAllOfItems>? items) =>
      _$this._items = items;

  ListBuilder<OrderDetailAllOfEvents>? _events;
  ListBuilder<OrderDetailAllOfEvents> get events =>
      _$this._events ??= ListBuilder<OrderDetailAllOfEvents>();
  set events(covariant ListBuilder<OrderDetailAllOfEvents>? events) =>
      _$this._events = events;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  String? _reference;
  String? get reference => _$this._reference;
  set reference(covariant String? reference) => _$this._reference = reference;

  String? _status;
  String? get status => _$this._status;
  set status(covariant String? status) => _$this._status = status;

  String? _supplierName;
  String? get supplierName => _$this._supplierName;
  set supplierName(covariant String? supplierName) =>
      _$this._supplierName = supplierName;

  String? _itemSummary;
  String? get itemSummary => _$this._itemSummary;
  set itemSummary(covariant String? itemSummary) =>
      _$this._itemSummary = itemSummary;

  int? _totalAmount;
  int? get totalAmount => _$this._totalAmount;
  set totalAmount(covariant int? totalAmount) =>
      _$this._totalAmount = totalAmount;

  bool? _isUrgent;
  bool? get isUrgent => _$this._isUrgent;
  set isUrgent(covariant bool? isUrgent) => _$this._isUrgent = isUrgent;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(covariant DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  OrderDetailBuilder() {
    OrderDetail._defaults(this);
  }

  OrderDetailBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _dropoffAddress = $v.dropoffAddress;
      _invoiceNo = $v.invoiceNo;
      _items = $v.items?.toBuilder();
      _events = $v.events?.toBuilder();
      _id = $v.id;
      _reference = $v.reference;
      _status = $v.status;
      _supplierName = $v.supplierName;
      _itemSummary = $v.itemSummary;
      _totalAmount = $v.totalAmount;
      _isUrgent = $v.isUrgent;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant OrderDetail other) {
    _$v = other as _$OrderDetail;
  }

  @override
  void update(void Function(OrderDetailBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderDetail build() => _build();

  _$OrderDetail _build() {
    _$OrderDetail _$result;
    try {
      _$result = _$v ??
          _$OrderDetail._(
            dropoffAddress: dropoffAddress,
            invoiceNo: invoiceNo,
            items: _items?.build(),
            events: _events?.build(),
            id: id,
            reference: reference,
            status: status,
            supplierName: supplierName,
            itemSummary: itemSummary,
            totalAmount: totalAmount,
            isUrgent: isUrgent,
            updatedAt: updatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        _items?.build();
        _$failedField = 'events';
        _events?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OrderDetail', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
