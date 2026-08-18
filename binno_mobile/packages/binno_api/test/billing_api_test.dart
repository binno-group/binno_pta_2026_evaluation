import 'package:test/test.dart';
import 'package:binno_api/binno_api.dart';

/// tests for BillingApi
void main() {
  final instance = BinnoApi().getBillingApi();

  group(BillingApi, () {
    // Invoice — BIN-YYYYMM-NNNNN, valid for 5 business days (BR-10.2, BR-10.4)
    //
    //Future<Invoice> ordersIdInvoiceGet(String id) async
    test('test ordersIdInvoiceGet', () async {
      // TODO
    });

    // Commission payment details + reference code (BR-14.4)
    //
    //Future<SupplierBillingPaymentIntentPost200Response> supplierBillingPaymentIntentPost({ String idempotencyKey }) async
    test('test supplierBillingPaymentIntentPost', () async {
      // TODO
    });

    // Billing summary (BR-13, BR-14.3)
    //
    //Future<SupplierBillingSummaryGet200Response> supplierBillingSummaryGet() async
    test('test supplierBillingSummaryGet', () async {
      // TODO
    });
  });
}
