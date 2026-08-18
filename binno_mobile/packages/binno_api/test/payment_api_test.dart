import 'package:test/test.dart';
import 'package:binno_api/binno_api.dart';

/// tests for PaymentApi
void main() {
  final instance = BinnoApi().getPaymentApi();

  group(PaymentApi, () {
    // Buyer marks payment + optional receipt (BR-11.1)
    //
    //Future ordersIdPaymentMarkPaidPost(String id, { String idempotencyKey, OrdersIdPaymentMarkPaidPostRequest ordersIdPaymentMarkPaidPostRequest }) async
    test('test ordersIdPaymentMarkPaidPost', () async {
      // TODO
    });

    // Money arrived — the order moves to preparing (BR-11.1)
    //
    //Future supplierOrdersIdPaymentConfirmPost(String id, { String idempotencyKey }) async
    test('test supplierOrdersIdPaymentConfirmPost', () async {
      // TODO
    });

    // Money did not arrive — automatic dispute (BR-11.3)
    //
    //Future supplierOrdersIdPaymentDenyPost(String id, SupplierOrdersIdPaymentDenyPostRequest supplierOrdersIdPaymentDenyPostRequest) async
    test('test supplierOrdersIdPaymentDenyPost', () async {
      // TODO
    });
  });
}
