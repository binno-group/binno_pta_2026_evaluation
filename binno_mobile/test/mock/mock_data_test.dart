import 'package:binno/features/shared/mock/mock_data.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for `MockData` integrity and the model getters.
void main() {
  group('categories', () {
    test('has 8 categories', () {
      expect(MockData.categories.length, 8);
    });

    test('every category has an asset path and a name', () {
      for (final c in MockData.categories) {
        expect(c.name.trim(), isNotEmpty);
        expect(c.asset.startsWith('assets/products/'), isTrue);
        expect(c.asset.endsWith('.png'), isTrue);
        expect(c.offerCount, greaterThan(0));
      }
    });

    test('category names do not repeat', () {
      final names = MockData.categories.map((c) => c.name).toList();
      expect(names.toSet().length, names.length);
    });
  });

  group('productAsset', () {
    test('maps a product label to the right image', () {
      expect(MockData.productAsset('M400'), endsWith('sement.png'));
      expect(MockData.productAsset('Ø12'), endsWith('armatura.png'));
      expect(MockData.productAsset('M150'), endsWith('gisht.png'));
      expect(MockData.productAsset('QQ'), endsWith('sement.png'));
    });

    test('returns null for an unknown label', () {
      expect(MockData.productAsset('XYZ'), isNull);
    });
  });

  group('allStores / allProducts', () {
    test('the store list is not empty', () {
      expect(MockData.allStores, isNotEmpty);
    });

    test('the product list is not empty', () {
      expect(MockData.allProducts, isNotEmpty);
    });

    test('store titles do not repeat', () {
      final titles = MockData.allStores.map((s) => s.title).toList();
      expect(titles.toSet().length, titles.length);
    });
  });

  group('MockStore getters', () {
    test('title has the "name · unit" shape', () {
      final s = MockData.metallSavdo;
      expect(s.title, '${s.name} · ${s.unitNumber}');
    });

    test('isNew derives from the review count', () {
      expect(MockData.metallSavdo.isNew, MockData.metallSavdo.reviewCount < 3);
    });

    test('complexBlock joins the complex and the block', () {
      final s = MockData.metallSavdo;
      if (s.complex != null && s.block != null) {
        expect(s.complexBlock, '${s.complex}, ${s.block}');
      }
    });
  });

  group('addresses', () {
    test('there is at least one address and the first is the default', () {
      expect(MockData.addresses, isNotEmpty);
      expect(MockData.addresses.first.isDefault, isTrue);
    });

    test('address coordinates are in a sensible range', () {
      for (final a in MockData.addresses) {
        expect(a.latitude, inInclusiveRange(37.0, 46.0));
        expect(a.longitude, inInclusiveRange(55.0, 74.0));
      }
    });
  });
}
