import 'package:test/test.dart';
import 'package:binno_api/binno_api.dart';

/// tests for DisputesApi
void main() {
  final instance = BinnoApi().getDisputesApi();

  group(DisputesApi, () {
    // Open a dispute — 48h window (BR-12.1), max 10 photos
    //
    //Future<OrdersIdDisputesPost201Response> ordersIdDisputesPost(String id, OrdersIdDisputesPostRequest ordersIdDisputesPostRequest) async
    test('test ordersIdDisputesPost', () async {
      // TODO
    });
  });
}
