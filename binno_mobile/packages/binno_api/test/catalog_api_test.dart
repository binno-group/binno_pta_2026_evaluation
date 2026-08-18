import 'package:test/test.dart';
import 'package:binno_api/binno_api.dart';

/// tests for CatalogApi
void main() {
  final instance = BinnoApi().getCatalogApi();

  group(CatalogApi, () {
    // Category tree (max 3 levels, BR-06.1; cached for 1 hour)
    //
    //Future<BuiltList<Category>> categoriesTreeGet() async
    test('test categoriesTreeGet', () async {
      // TODO
    });

    // Supplier product list
    //
    //Future<ProductPage> supplierProductsGet({ String status, String cursor }) async
    test('test supplierProductsGet', () async {
      // TODO
    });

    // Archive (no delete — BR-05.7)
    //
    //Future supplierProductsIdArchivePost(String id) async
    test('test supplierProductsIdArchivePost', () async {
      // TODO
    });

    // Publish — verified suppliers only (BR-04.5, BR-05.2)
    //
    //Future supplierProductsIdPublishPost(String id) async
    test('test supplierProductsIdPublishPost', () async {
      // TODO
    });

    // Create a product (draft) — BR-05.1
    //
    //Future<SupplierProductsPost201Response> supplierProductsPost(ProductInput productInput, { String idempotencyKey }) async
    test('test supplierProductsPost', () async {
      // TODO
    });
  });
}
