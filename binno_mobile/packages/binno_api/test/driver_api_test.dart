import 'package:test/test.dart';
import 'package:binno_api/binno_api.dart';

/// tests for DriverApi
void main() {
  final instance = BinnoApi().getDriverApi();

  group(DriverApi, () {
    // Active offers — classic + urgent (BR-17.3, BR-17.4)
    //
    //Future<BuiltList<DriverOffer>> driverOffersGet() async
    test('test driverOffersGet', () async {
      // TODO
    });

    // Accept an offer — atomic, first-accept-wins (AC-17.2)
    //
    //Future driverOffersIdAcceptPost(String id) async
    test('test driverOffersIdAcceptPost', () async {
      // TODO
    });

    // Delivered — 1-3 photos mandatory (BR-18.3)
    //
    //Future driverOrdersIdDeliveredPost(String id, BuiltList<MultipartFile> photos, GeoPoint location) async
    test('test driverOrdersIdDeliveredPost', () async {
      // TODO
    });
  });
}
