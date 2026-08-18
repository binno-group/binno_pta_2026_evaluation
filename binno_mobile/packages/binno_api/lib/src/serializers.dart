//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:binno_api/src/date_serializer.dart';
import 'package:binno_api/src/model/date.dart';

import 'package:binno_api/src/model/auth_otp_request_post200_response.dart';
import 'package:binno_api/src/model/auth_otp_request_post_request.dart';
import 'package:binno_api/src/model/auth_otp_verify_post200_response.dart';
import 'package:binno_api/src/model/auth_otp_verify_post200_response_one_of.dart';
import 'package:binno_api/src/model/auth_otp_verify_post_request.dart';
import 'package:binno_api/src/model/auth_refresh_post_request.dart';
import 'package:binno_api/src/model/category.dart';
import 'package:binno_api/src/model/driver_offer.dart';
import 'package:binno_api/src/model/geo_point.dart';
import 'package:binno_api/src/model/inline_object.dart';
import 'package:binno_api/src/model/inline_object1.dart';
import 'package:binno_api/src/model/inline_object2.dart';
import 'package:binno_api/src/model/inline_object2_all_of_errors_inner.dart';
import 'package:binno_api/src/model/invoice.dart';
import 'package:binno_api/src/model/invoice_versions_inner.dart';
import 'package:binno_api/src/model/order_create.dart';
import 'package:binno_api/src/model/order_create_dropoff.dart';
import 'package:binno_api/src/model/order_create_items_inner.dart';
import 'package:binno_api/src/model/order_detail.dart';
import 'package:binno_api/src/model/order_detail_all_of_events.dart';
import 'package:binno_api/src/model/order_detail_all_of_items.dart';
import 'package:binno_api/src/model/order_summary.dart';
import 'package:binno_api/src/model/orders_get200_response.dart';
import 'package:binno_api/src/model/orders_id_cancel_post_request.dart';
import 'package:binno_api/src/model/orders_id_disputes_post201_response.dart';
import 'package:binno_api/src/model/orders_id_disputes_post_request.dart';
import 'package:binno_api/src/model/orders_id_payment_mark_paid_post_request.dart';
import 'package:binno_api/src/model/orders_id_ratings_post_request.dart';
import 'package:binno_api/src/model/orders_post201_response.dart';
import 'package:binno_api/src/model/price_summary.dart';
import 'package:binno_api/src/model/problem.dart';
import 'package:binno_api/src/model/product_card.dart';
import 'package:binno_api/src/model/product_card_supplier.dart';
import 'package:binno_api/src/model/product_input.dart';
import 'package:binno_api/src/model/product_page.dart';
import 'package:binno_api/src/model/proposal_input.dart';
import 'package:binno_api/src/model/proposal_input_items_inner.dart';
import 'package:binno_api/src/model/search_products_get200_response.dart';
import 'package:binno_api/src/model/supplier_billing_payment_intent_post200_response.dart';
import 'package:binno_api/src/model/supplier_billing_summary_get200_response.dart';
import 'package:binno_api/src/model/supplier_orders_id_accept_post_request.dart';
import 'package:binno_api/src/model/supplier_orders_id_accept_post_request_final_items_inner.dart';
import 'package:binno_api/src/model/supplier_orders_id_payment_deny_post_request.dart';
import 'package:binno_api/src/model/supplier_orders_id_proposals_post201_response.dart';
import 'package:binno_api/src/model/supplier_orders_id_reject_post_request.dart';
import 'package:binno_api/src/model/supplier_products_post201_response.dart';
import 'package:binno_api/src/model/token_pair.dart';
import 'package:binno_api/src/model/user.dart';
import 'package:binno_api/src/model/verify_supplier_id_get200_response.dart';

part 'serializers.g.dart';

@SerializersFor([
  AuthOtpRequestPost200Response,
  AuthOtpRequestPostRequest,
  AuthOtpVerifyPost200Response,
  AuthOtpVerifyPost200ResponseOneOf,
  AuthOtpVerifyPostRequest,
  AuthRefreshPostRequest,
  Category,
  DriverOffer,
  GeoPoint,
  InlineObject,
  InlineObject1,
  InlineObject2,
  InlineObject2AllOfErrorsInner,
  Invoice,
  InvoiceVersionsInner,
  OrderCreate,
  OrderCreateDropoff,
  OrderCreateItemsInner,
  OrderDetail,
  OrderDetailAllOfEvents,
  OrderDetailAllOfItems,
  OrderSummary,
  $OrderSummary,
  OrdersGet200Response,
  OrdersIdCancelPostRequest,
  OrdersIdDisputesPost201Response,
  OrdersIdDisputesPostRequest,
  OrdersIdPaymentMarkPaidPostRequest,
  OrdersIdRatingsPostRequest,
  OrdersPost201Response,
  PriceSummary,
  Problem,
  $Problem,
  ProductCard,
  ProductCardSupplier,
  ProductInput,
  ProductPage,
  ProposalInput,
  ProposalInputItemsInner,
  SearchProductsGet200Response,
  SupplierBillingPaymentIntentPost200Response,
  SupplierBillingSummaryGet200Response,
  SupplierOrdersIdAcceptPostRequest,
  SupplierOrdersIdAcceptPostRequestFinalItemsInner,
  SupplierOrdersIdPaymentDenyPostRequest,
  SupplierOrdersIdProposalsPost201Response,
  SupplierOrdersIdRejectPostRequest,
  SupplierProductsPost201Response,
  TokenPair,
  User,
  VerifySupplierIdGet200Response,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Category)]),
        () => ListBuilder<Category>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(DriverOffer)]),
        () => ListBuilder<DriverOffer>(),
      )
      ..add(OrderSummary.serializer)
      ..add(Problem.serializer)
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
