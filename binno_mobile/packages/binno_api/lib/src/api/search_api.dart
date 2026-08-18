//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:binno_api/src/api_util.dart';
import 'package:binno_api/src/model/search_products_get200_response.dart';

class SearchApi {
  final Dio _dio;

  final Serializers _serializers;

  const SearchApi(this._dio, this._serializers);

  /// Search — FTS+trigram, p95&lt;300ms (BR-07)
  ///
  ///
  /// Parameters:
  /// * [q]
  /// * [categoryId]
  /// * [priceMin]
  /// * [priceMax]
  /// * [regionId]
  /// * [weightClass]
  /// * [minRating]
  /// * [sort]
  /// * [cursor] - Keyset pagination cursor (BR-07.4)
  /// * [limit]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SearchProductsGet200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<SearchProductsGet200Response>> searchProductsGet({
    String? q,
    int? categoryId,
    int? priceMin,
    int? priceMax,
    int? regionId,
    String? weightClass,
    num? minRating,
    String? sort,
    String? cursor,
    int? limit = 20,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/search/products';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (q != null)
        r'q': encodeQueryParameter(_serializers, q, const FullType(String)),
      if (categoryId != null)
        r'category_id':
            encodeQueryParameter(_serializers, categoryId, const FullType(int)),
      if (priceMin != null)
        r'price_min':
            encodeQueryParameter(_serializers, priceMin, const FullType(int)),
      if (priceMax != null)
        r'price_max':
            encodeQueryParameter(_serializers, priceMax, const FullType(int)),
      if (regionId != null)
        r'region_id':
            encodeQueryParameter(_serializers, regionId, const FullType(int)),
      if (weightClass != null)
        r'weight_class': encodeQueryParameter(
            _serializers, weightClass, const FullType(String)),
      if (minRating != null)
        r'min_rating':
            encodeQueryParameter(_serializers, minRating, const FullType(num)),
      if (sort != null)
        r'sort':
            encodeQueryParameter(_serializers, sort, const FullType(String)),
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    SearchProductsGet200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(SearchProductsGet200Response),
            ) as SearchProductsGet200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<SearchProductsGet200Response>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }
}
