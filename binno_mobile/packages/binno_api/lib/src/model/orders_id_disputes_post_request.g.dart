// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_id_disputes_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OrdersIdDisputesPostRequestTypeEnum
    _$ordersIdDisputesPostRequestTypeEnum_paymentNotReceived =
    const OrdersIdDisputesPostRequestTypeEnum._('paymentNotReceived');
const OrdersIdDisputesPostRequestTypeEnum
    _$ordersIdDisputesPostRequestTypeEnum_goodsDamaged =
    const OrdersIdDisputesPostRequestTypeEnum._('goodsDamaged');
const OrdersIdDisputesPostRequestTypeEnum
    _$ordersIdDisputesPostRequestTypeEnum_wrongItems =
    const OrdersIdDisputesPostRequestTypeEnum._('wrongItems');
const OrdersIdDisputesPostRequestTypeEnum
    _$ordersIdDisputesPostRequestTypeEnum_notDelivered =
    const OrdersIdDisputesPostRequestTypeEnum._('notDelivered');
const OrdersIdDisputesPostRequestTypeEnum
    _$ordersIdDisputesPostRequestTypeEnum_qualityClaim =
    const OrdersIdDisputesPostRequestTypeEnum._('qualityClaim');
const OrdersIdDisputesPostRequestTypeEnum
    _$ordersIdDisputesPostRequestTypeEnum_other =
    const OrdersIdDisputesPostRequestTypeEnum._('other');

OrdersIdDisputesPostRequestTypeEnum
    _$ordersIdDisputesPostRequestTypeEnumValueOf(String name) {
  switch (name) {
    case 'paymentNotReceived':
      return _$ordersIdDisputesPostRequestTypeEnum_paymentNotReceived;
    case 'goodsDamaged':
      return _$ordersIdDisputesPostRequestTypeEnum_goodsDamaged;
    case 'wrongItems':
      return _$ordersIdDisputesPostRequestTypeEnum_wrongItems;
    case 'notDelivered':
      return _$ordersIdDisputesPostRequestTypeEnum_notDelivered;
    case 'qualityClaim':
      return _$ordersIdDisputesPostRequestTypeEnum_qualityClaim;
    case 'other':
      return _$ordersIdDisputesPostRequestTypeEnum_other;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OrdersIdDisputesPostRequestTypeEnum>
    _$ordersIdDisputesPostRequestTypeEnumValues = BuiltSet<
        OrdersIdDisputesPostRequestTypeEnum>(const <OrdersIdDisputesPostRequestTypeEnum>[
  _$ordersIdDisputesPostRequestTypeEnum_paymentNotReceived,
  _$ordersIdDisputesPostRequestTypeEnum_goodsDamaged,
  _$ordersIdDisputesPostRequestTypeEnum_wrongItems,
  _$ordersIdDisputesPostRequestTypeEnum_notDelivered,
  _$ordersIdDisputesPostRequestTypeEnum_qualityClaim,
  _$ordersIdDisputesPostRequestTypeEnum_other,
]);

Serializer<OrdersIdDisputesPostRequestTypeEnum>
    _$ordersIdDisputesPostRequestTypeEnumSerializer =
    _$OrdersIdDisputesPostRequestTypeEnumSerializer();

class _$OrdersIdDisputesPostRequestTypeEnumSerializer
    implements PrimitiveSerializer<OrdersIdDisputesPostRequestTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'paymentNotReceived': 'payment_not_received',
    'goodsDamaged': 'goods_damaged',
    'wrongItems': 'wrong_items',
    'notDelivered': 'not_delivered',
    'qualityClaim': 'quality_claim',
    'other': 'other',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'payment_not_received': 'paymentNotReceived',
    'goods_damaged': 'goodsDamaged',
    'wrong_items': 'wrongItems',
    'not_delivered': 'notDelivered',
    'quality_claim': 'qualityClaim',
    'other': 'other',
  };

  @override
  final Iterable<Type> types = const <Type>[
    OrdersIdDisputesPostRequestTypeEnum
  ];
  @override
  final String wireName = 'OrdersIdDisputesPostRequestTypeEnum';

  @override
  Object serialize(
          Serializers serializers, OrdersIdDisputesPostRequestTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OrdersIdDisputesPostRequestTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OrdersIdDisputesPostRequestTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OrdersIdDisputesPostRequest extends OrdersIdDisputesPostRequest {
  @override
  final OrdersIdDisputesPostRequestTypeEnum type;
  @override
  final String statement;
  @override
  final BuiltList<String>? photos;

  factory _$OrdersIdDisputesPostRequest(
          [void Function(OrdersIdDisputesPostRequestBuilder)? updates]) =>
      (OrdersIdDisputesPostRequestBuilder()..update(updates))._build();

  _$OrdersIdDisputesPostRequest._(
      {required this.type, required this.statement, this.photos})
      : super._();
  @override
  OrdersIdDisputesPostRequest rebuild(
          void Function(OrdersIdDisputesPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrdersIdDisputesPostRequestBuilder toBuilder() =>
      OrdersIdDisputesPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrdersIdDisputesPostRequest &&
        type == other.type &&
        statement == other.statement &&
        photos == other.photos;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, statement.hashCode);
    _$hash = $jc(_$hash, photos.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrdersIdDisputesPostRequest')
          ..add('type', type)
          ..add('statement', statement)
          ..add('photos', photos))
        .toString();
  }
}

class OrdersIdDisputesPostRequestBuilder
    implements
        Builder<OrdersIdDisputesPostRequest,
            OrdersIdDisputesPostRequestBuilder> {
  _$OrdersIdDisputesPostRequest? _$v;

  OrdersIdDisputesPostRequestTypeEnum? _type;
  OrdersIdDisputesPostRequestTypeEnum? get type => _$this._type;
  set type(OrdersIdDisputesPostRequestTypeEnum? type) => _$this._type = type;

  String? _statement;
  String? get statement => _$this._statement;
  set statement(String? statement) => _$this._statement = statement;

  ListBuilder<String>? _photos;
  ListBuilder<String> get photos => _$this._photos ??= ListBuilder<String>();
  set photos(ListBuilder<String>? photos) => _$this._photos = photos;

  OrdersIdDisputesPostRequestBuilder() {
    OrdersIdDisputesPostRequest._defaults(this);
  }

  OrdersIdDisputesPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _statement = $v.statement;
      _photos = $v.photos?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrdersIdDisputesPostRequest other) {
    _$v = other as _$OrdersIdDisputesPostRequest;
  }

  @override
  void update(void Function(OrdersIdDisputesPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrdersIdDisputesPostRequest build() => _build();

  _$OrdersIdDisputesPostRequest _build() {
    _$OrdersIdDisputesPostRequest _$result;
    try {
      _$result = _$v ??
          _$OrdersIdDisputesPostRequest._(
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'OrdersIdDisputesPostRequest', 'type'),
            statement: BuiltValueNullFieldError.checkNotNull(
                statement, r'OrdersIdDisputesPostRequest', 'statement'),
            photos: _photos?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'photos';
        _photos?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OrdersIdDisputesPostRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
