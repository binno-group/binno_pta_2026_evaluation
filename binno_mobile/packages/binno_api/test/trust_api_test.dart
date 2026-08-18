import 'package:test/test.dart';
import 'package:binno_api/binno_api.dart';

/// tests for TrustApi
void main() {
  final instance = BinnoApi().getTrustApi();

  group(TrustApi, () {
    // Rating — closed orders only, 14-day window (BR-20.1)
    //
    //Future ordersIdRatingsPost(String id, OrdersIdRatingsPostRequest ordersIdRatingsPostRequest) async
    test('test ordersIdRatingsPost', () async {
      // TODO
    });

    // Public verification page — no auth required (BR-21.4)
    //
    //Future<VerifySupplierIdGet200Response> verifySupplierIdGet(String supplierId) async
    test('test verifySupplierIdGet', () async {
      // TODO
    });
  });
}
