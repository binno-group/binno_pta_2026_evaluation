import 'package:test/test.dart';
import 'package:binno_api/binno_api.dart';

/// tests for OrdersApi
void main() {
  final instance = BinnoApi().getOrdersApi();

  group(OrdersApi, () {
    // List orders (by role)
    //
    //Future<OrdersGet200Response> ordersGet({ String role, String status, String cursor }) async
    test('test ordersGet', () async {
      // TODO
    });

    // Buyer cancel — BR-08.10: unrestricted in created; in accepted only until payment.confirmed; after that only a dispute
    //
    //Future ordersIdCancelPost(String id, OrdersIdCancelPostRequest ordersIdCancelPostRequest) async
    test('test ordersIdCancelPost', () async {
      // TODO
    });

    // Full order state + timeline (BR-08.2)
    //
    //Future<OrderDetail> ordersIdGet(String id) async
    test('test ordersIdGet', () async {
      // TODO
    });

    // Accept the proposal — the order becomes accepted (BR-09.3)
    //
    //Future ordersIdProposalsPidAcceptPost(String id, String pid) async
    test('test ordersIdProposalsPidAcceptPost', () async {
      // TODO
    });

    // Create an order (BR-08.8, BR-08.9)
    //
    //Future<OrdersPost201Response> ordersPost(OrderCreate orderCreate, { String idempotencyKey }) async
    test('test ordersPost', () async {
      // TODO
    });

    // Accept — the final price freezes (BR-08.4); credit-limit check (BR-14.2)
    //
    //Future supplierOrdersIdAcceptPost(String id, SupplierOrdersIdAcceptPostRequest supplierOrdersIdAcceptPostRequest, { String idempotencyKey }) async
    test('test supplierOrdersIdAcceptPost', () async {
      // TODO
    });

    // Price proposal — max 3 rounds, 24h validity (BR-09.2)
    //
    //Future<SupplierOrdersIdProposalsPost201Response> supplierOrdersIdProposalsPost(String id, ProposalInput proposalInput) async
    test('test supplierOrdersIdProposalsPost', () async {
      // TODO
    });

    // Ready — only after payment.confirmed (AC-11.4)
    //
    //Future supplierOrdersIdReadyPost(String id) async
    test('test supplierOrdersIdReadyPost', () async {
      // TODO
    });

    // Reject (a reason is mandatory)
    //
    //Future supplierOrdersIdRejectPost(String id, SupplierOrdersIdRejectPostRequest supplierOrdersIdRejectPostRequest) async
    test('test supplierOrdersIdRejectPost', () async {
      // TODO
    });
  });
}
