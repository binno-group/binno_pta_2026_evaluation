//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:built_value/serializer.dart';
import 'package:binno_api/src/serializers.dart';
import 'package:binno_api/src/auth/api_key_auth.dart';
import 'package:binno_api/src/auth/basic_auth.dart';
import 'package:binno_api/src/auth/bearer_auth.dart';
import 'package:binno_api/src/auth/oauth.dart';
import 'package:binno_api/src/api/auth_api.dart';
import 'package:binno_api/src/api/billing_api.dart';
import 'package:binno_api/src/api/catalog_api.dart';
import 'package:binno_api/src/api/disputes_api.dart';
import 'package:binno_api/src/api/driver_api.dart';
import 'package:binno_api/src/api/orders_api.dart';
import 'package:binno_api/src/api/payment_api.dart';
import 'package:binno_api/src/api/search_api.dart';
import 'package:binno_api/src/api/trust_api.dart';

class BinnoApi {
  static const String basePath = r'https://api.binno.uz/api/v1';

  final Dio dio;
  final Serializers serializers;

  BinnoApi({
    Dio? dio,
    Serializers? serializers,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : this.serializers = serializers ?? standardSerializers,
        this.dio = dio ??
            Dio(BaseOptions(
              baseUrl: basePathOverride ?? basePath,
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor)
              as OAuthInterceptor)
          .tokens[name] = token;
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor)
              as BearerAuthInterceptor)
          .tokens[name] = token;
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor)
              as BasicAuthInterceptor)
          .authInfo[name] = BasicAuthInfo(username, password);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this
                  .dio
                  .interceptors
                  .firstWhere((element) => element is ApiKeyAuthInterceptor)
              as ApiKeyAuthInterceptor)
          .apiKeys[name] = apiKey;
    }
  }

  /// Get AuthApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AuthApi getAuthApi() {
    return AuthApi(dio, serializers);
  }

  /// Get BillingApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  BillingApi getBillingApi() {
    return BillingApi(dio, serializers);
  }

  /// Get CatalogApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  CatalogApi getCatalogApi() {
    return CatalogApi(dio, serializers);
  }

  /// Get DisputesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  DisputesApi getDisputesApi() {
    return DisputesApi(dio, serializers);
  }

  /// Get DriverApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  DriverApi getDriverApi() {
    return DriverApi(dio, serializers);
  }

  /// Get OrdersApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  OrdersApi getOrdersApi() {
    return OrdersApi(dio, serializers);
  }

  /// Get PaymentApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  PaymentApi getPaymentApi() {
    return PaymentApi(dio, serializers);
  }

  /// Get SearchApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SearchApi getSearchApi() {
    return SearchApi(dio, serializers);
  }

  /// Get TrustApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  TrustApi getTrustApi() {
    return TrustApi(dio, serializers);
  }
}
