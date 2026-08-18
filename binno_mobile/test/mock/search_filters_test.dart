import 'package:binno/features/shared/mock/mock_data.dart';
import 'package:binno/features/shared/mock/search_filters.dart';
import 'package:binno/features/shared/widgets/binno_labels.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for the `SearchFilters` filtering and sorting logic.
void main() {
  final offers = MockData.searchResults; // 4 ta M400 sement taklifi

  group('apply, default state', () {
    test('all offers stay within the price range', () {
      const f = SearchFilters();
      expect(f.apply(offers).length, offers.length);
    });

    test('sorts by price ascending (default)', () {
      const f = SearchFilters();
      final result = f.apply(offers);
      for (var i = 1; i < result.length; i++) {
        expect(result[i - 1].price <= result[i].price, isTrue);
      }
      // Cheapest first.
      expect(result.first.price, 45000);
    });
  });

  group('apply, price filter', () {
    test('a lower upper bound drops the expensive offers', () {
      const f = SearchFilters(priceMax: 46000);
      final result = f.apply(offers);
      expect(result.length, 1);
      expect(result.first.price, 45000);
    });

    test('no matching offer yields an empty list', () {
      const f = SearchFilters(priceMin: 100000, priceMax: 200000);
      expect(f.apply(offers), isEmpty);
    });
  });

  group('apply, verified and freshness filters', () {
    test('verifiedOnly keeps only verified stores', () {
      const f = SearchFilters(verifiedOnly: true);
      final result = f.apply(offers);
      expect(result, isNotEmpty);
      expect(result.every((o) => o.store.verified), isTrue);
    });

    test('freshOnly keeps only fresh offers', () {
      const f = SearchFilters(freshOnly: true);
      final result = f.apply(offers);
      expect(result.every((o) => o.freshness == BinnoFreshness.fresh), isTrue);
    });
  });

  group('apply, radius filter', () {
    test('a small radius drops all distant offers', () {
      const f = SearchFilters(radiusKm: 5); // takliflar 6+ km
      expect(f.apply(offers), isEmpty);
    });
  });

  group('apply, sort criterion', () {
    test('sorts by rating descending', () {
      const f = SearchFilters(sort: 3);
      final result = f.apply(offers);
      for (var i = 1; i < result.length; i++) {
        expect(
          result[i - 1].store.rating >= result[i].store.rating,
          isTrue,
        );
      }
    });
  });

  group('activeCount', () {
    test('is 0 in the default state', () {
      expect(const SearchFilters().activeCount, 0);
    });

    test('counts every changed filter', () {
      const f = SearchFilters(freshOnly: true, verifiedOnly: true, sort: 2);
      expect(f.activeCount, 3);
    });
  });

  group('storeCount', () {
    test('returns the unique store count', () {
      expect(SearchFilters.storeCount(offers), offers.map((o) => o.store.title).toSet().length);
    });
  });

  group('summaryLine / copyWith', () {
    test('summaryLine includes the sort label', () {
      const f = SearchFilters(sort: 1);
      expect(f.summaryLine.contains(SearchFilters.sortLabels[1]), isTrue);
    });

    test('copyWith replaces only the query', () {
      const f = SearchFilters(sort: 2, freshOnly: true);
      final c = f.copyWith(query: 'armatura');
      expect(c.query, 'armatura');
      expect(c.sort, 2);
      expect(c.freshOnly, isTrue);
    });
  });
}
