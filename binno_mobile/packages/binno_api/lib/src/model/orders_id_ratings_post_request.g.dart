// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_id_ratings_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OrdersIdRatingsPostRequestTargetEnum
    _$ordersIdRatingsPostRequestTargetEnum_supplier =
    const OrdersIdRatingsPostRequestTargetEnum._('supplier');
const OrdersIdRatingsPostRequestTargetEnum
    _$ordersIdRatingsPostRequestTargetEnum_driver =
    const OrdersIdRatingsPostRequestTargetEnum._('driver');
const OrdersIdRatingsPostRequestTargetEnum
    _$ordersIdRatingsPostRequestTargetEnum_buyer =
    const OrdersIdRatingsPostRequestTargetEnum._('buyer');

OrdersIdRatingsPostRequestTargetEnum
    _$ordersIdRatingsPostRequestTargetEnumValueOf(String name) {
  switch (name) {
    case 'supplier':
      return _$ordersIdRatingsPostRequestTargetEnum_supplier;
    case 'driver':
      return _$ordersIdRatingsPostRequestTargetEnum_driver;
    case 'buyer':
      return _$ordersIdRatingsPostRequestTargetEnum_buyer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OrdersIdRatingsPostRequestTargetEnum>
    _$ordersIdRatingsPostRequestTargetEnumValues = BuiltSet<
        OrdersIdRatingsPostRequestTargetEnum>(const <OrdersIdRatingsPostRequestTargetEnum>[
  _$ordersIdRatingsPostRequestTargetEnum_supplier,
  _$ordersIdRatingsPostRequestTargetEnum_driver,
  _$ordersIdRatingsPostRequestTargetEnum_buyer,
]);

const OrdersIdRatingsPostRequestReasonCategoryEnum
    _$ordersIdRatingsPostRequestReasonCategoryEnum_sifat =
    const OrdersIdRatingsPostRequestReasonCategoryEnum._('sifat');
const OrdersIdRatingsPostRequestReasonCategoryEnum
    _$ordersIdRatingsPostRequestReasonCategoryEnum_muddat =
    const OrdersIdRatingsPostRequestReasonCategoryEnum._('muddat');
const OrdersIdRatingsPostRequestReasonCategoryEnum
    _$ordersIdRatingsPostRequestReasonCategoryEnum_muomala =
    const OrdersIdRatingsPostRequestReasonCategoryEnum._('muomala');
const OrdersIdRatingsPostRequestReasonCategoryEnum
    _$ordersIdRatingsPostRequestReasonCategoryEnum_narx =
    const OrdersIdRatingsPostRequestReasonCategoryEnum._('narx');

OrdersIdRatingsPostRequestReasonCategoryEnum
    _$ordersIdRatingsPostRequestReasonCategoryEnumValueOf(String name) {
  switch (name) {
    case 'sifat':
      return _$ordersIdRatingsPostRequestReasonCategoryEnum_sifat;
    case 'muddat':
      return _$ordersIdRatingsPostRequestReasonCategoryEnum_muddat;
    case 'muomala':
      return _$ordersIdRatingsPostRequestReasonCategoryEnum_muomala;
    case 'narx':
      return _$ordersIdRatingsPostRequestReasonCategoryEnum_narx;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OrdersIdRatingsPostRequestReasonCategoryEnum>
    _$ordersIdRatingsPostRequestReasonCategoryEnumValues = BuiltSet<
        OrdersIdRatingsPostRequestReasonCategoryEnum>(const <OrdersIdRatingsPostRequestReasonCategoryEnum>[
  _$ordersIdRatingsPostRequestReasonCategoryEnum_sifat,
  _$ordersIdRatingsPostRequestReasonCategoryEnum_muddat,
  _$ordersIdRatingsPostRequestReasonCategoryEnum_muomala,
  _$ordersIdRatingsPostRequestReasonCategoryEnum_narx,
]);

Serializer<OrdersIdRatingsPostRequestTargetEnum>
    _$ordersIdRatingsPostRequestTargetEnumSerializer =
    _$OrdersIdRatingsPostRequestTargetEnumSerializer();
Serializer<OrdersIdRatingsPostRequestReasonCategoryEnum>
    _$ordersIdRatingsPostRequestReasonCategoryEnumSerializer =
    _$OrdersIdRatingsPostRequestReasonCategoryEnumSerializer();

class _$OrdersIdRatingsPostRequestTargetEnumSerializer
    implements PrimitiveSerializer<OrdersIdRatingsPostRequestTargetEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'supplier': 'supplier',
    'driver': 'driver',
    'buyer': 'buyer',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'supplier': 'supplier',
    'driver': 'driver',
    'buyer': 'buyer',
  };

  @override
  final Iterable<Type> types = const <Type>[
    OrdersIdRatingsPostRequestTargetEnum
  ];
  @override
  final String wireName = 'OrdersIdRatingsPostRequestTargetEnum';

  @override
  Object serialize(
          Serializers serializers, OrdersIdRatingsPostRequestTargetEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OrdersIdRatingsPostRequestTargetEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OrdersIdRatingsPostRequestTargetEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OrdersIdRatingsPostRequestReasonCategoryEnumSerializer
    implements
        PrimitiveSerializer<OrdersIdRatingsPostRequestReasonCategoryEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'sifat': 'sifat',
    'muddat': 'muddat',
    'muomala': 'muomala',
    'narx': 'narx',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'sifat': 'sifat',
    'muddat': 'muddat',
    'muomala': 'muomala',
    'narx': 'narx',
  };

  @override
  final Iterable<Type> types = const <Type>[
    OrdersIdRatingsPostRequestReasonCategoryEnum
  ];
  @override
  final String wireName = 'OrdersIdRatingsPostRequestReasonCategoryEnum';

  @override
  Object serialize(Serializers serializers,
          OrdersIdRatingsPostRequestReasonCategoryEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OrdersIdRatingsPostRequestReasonCategoryEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OrdersIdRatingsPostRequestReasonCategoryEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OrdersIdRatingsPostRequest extends OrdersIdRatingsPostRequest {
  @override
  final OrdersIdRatingsPostRequestTargetEnum target;
  @override
  final int score;
  @override
  final String? comment;
  @override
  final OrdersIdRatingsPostRequestReasonCategoryEnum? reasonCategory;

  factory _$OrdersIdRatingsPostRequest(
          [void Function(OrdersIdRatingsPostRequestBuilder)? updates]) =>
      (OrdersIdRatingsPostRequestBuilder()..update(updates))._build();

  _$OrdersIdRatingsPostRequest._(
      {required this.target,
      required this.score,
      this.comment,
      this.reasonCategory})
      : super._();
  @override
  OrdersIdRatingsPostRequest rebuild(
          void Function(OrdersIdRatingsPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrdersIdRatingsPostRequestBuilder toBuilder() =>
      OrdersIdRatingsPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrdersIdRatingsPostRequest &&
        target == other.target &&
        score == other.score &&
        comment == other.comment &&
        reasonCategory == other.reasonCategory;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, target.hashCode);
    _$hash = $jc(_$hash, score.hashCode);
    _$hash = $jc(_$hash, comment.hashCode);
    _$hash = $jc(_$hash, reasonCategory.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrdersIdRatingsPostRequest')
          ..add('target', target)
          ..add('score', score)
          ..add('comment', comment)
          ..add('reasonCategory', reasonCategory))
        .toString();
  }
}

class OrdersIdRatingsPostRequestBuilder
    implements
        Builder<OrdersIdRatingsPostRequest, OrdersIdRatingsPostRequestBuilder> {
  _$OrdersIdRatingsPostRequest? _$v;

  OrdersIdRatingsPostRequestTargetEnum? _target;
  OrdersIdRatingsPostRequestTargetEnum? get target => _$this._target;
  set target(OrdersIdRatingsPostRequestTargetEnum? target) =>
      _$this._target = target;

  int? _score;
  int? get score => _$this._score;
  set score(int? score) => _$this._score = score;

  String? _comment;
  String? get comment => _$this._comment;
  set comment(String? comment) => _$this._comment = comment;

  OrdersIdRatingsPostRequestReasonCategoryEnum? _reasonCategory;
  OrdersIdRatingsPostRequestReasonCategoryEnum? get reasonCategory =>
      _$this._reasonCategory;
  set reasonCategory(
          OrdersIdRatingsPostRequestReasonCategoryEnum? reasonCategory) =>
      _$this._reasonCategory = reasonCategory;

  OrdersIdRatingsPostRequestBuilder() {
    OrdersIdRatingsPostRequest._defaults(this);
  }

  OrdersIdRatingsPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _target = $v.target;
      _score = $v.score;
      _comment = $v.comment;
      _reasonCategory = $v.reasonCategory;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrdersIdRatingsPostRequest other) {
    _$v = other as _$OrdersIdRatingsPostRequest;
  }

  @override
  void update(void Function(OrdersIdRatingsPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrdersIdRatingsPostRequest build() => _build();

  _$OrdersIdRatingsPostRequest _build() {
    final _$result = _$v ??
        _$OrdersIdRatingsPostRequest._(
          target: BuiltValueNullFieldError.checkNotNull(
              target, r'OrdersIdRatingsPostRequest', 'target'),
          score: BuiltValueNullFieldError.checkNotNull(
              score, r'OrdersIdRatingsPostRequest', 'score'),
          comment: comment,
          reasonCategory: reasonCategory,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
