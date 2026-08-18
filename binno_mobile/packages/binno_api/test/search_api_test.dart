import 'package:test/test.dart';
import 'package:binno_api/binno_api.dart';

/// tests for SearchApi
void main() {
  final instance = BinnoApi().getSearchApi();

  group(SearchApi, () {
    // Search — FTS+trigram, p95<300ms (BR-07)
    //
    //Future<SearchProductsGet200Response> searchProductsGet({ String q, int categoryId, int priceMin, int priceMax, int regionId, String weightClass, num minRating, String sort, String cursor, int limit }) async
    test('test searchProductsGet', () async {
      // TODO
    });
  });
}
