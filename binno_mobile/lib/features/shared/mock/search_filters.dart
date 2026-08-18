import '../widgets/binno_labels.dart';
import 'mock_data.dart';

/// Search filters and the sort criterion.
///
/// The sort criteria match the ranking factors (§4.3): price, distance,
/// freshness, response time. Ratings are per **store** and are never
/// merged at the owner level.
class SearchFilters {
  const SearchFilters({
    this.query = 'M400 sement',
    this.sort = 0,
    this.fulfillment = 0,
    this.freshOnly = false,
    this.verifiedOnly = false,
    this.priceMin = 30000,
    this.priceMax = 80000,
    this.radiusKm = 30,
    this.complexes = const <String>{},
  });

  final String query;

  /// 0 price, 1 distance, 2 freshness, 3 rating.
  final int sort;

  /// 0 all, 1 delivery, 2 pickup.
  final int fulfillment;

  final bool freshOnly;
  final bool verifiedOnly;
  final double priceMin;
  final double priceMax;
  final double radiusKm;

  /// An empty set means no complex restriction.
  final Set<String> complexes;

  static const sortLabels = [
    'Narx bo\'yicha, arzonidan',
    'Masofa bo\'yicha, yaqinidan',
    'Yangilanish bo\'yicha, yangisidan',
    'Reyting bo\'yicha, yuqorisidan',
  ];

  /// How many filters differ from the defaults, e.g. "Filtrlar · 3".
  int get activeCount {
    var n = 0;
    if (sort != 0) n++;
    if (fulfillment != 0) n++;
    if (freshOnly) n++;
    if (verifiedOnly) n++;
    if (priceMin > 30000 || priceMax < 80000) n++;
    if (radiusKm < 30) n++;
    if (complexes.isNotEmpty) n++;
    return n;
  }

  /// e.g. "Narx bo'yicha, arzonidan · Qo'yliq".
  String get summaryLine {
    final scope = complexes.isEmpty
        ? 'barcha majmualar'
        : complexes.map((c) => c.split(' ').first).join(', ');
    return '${sortLabels[sort]} · $scope';
  }

  /// The freshness order; a smaller number is fresher.
  static int _freshRank(BinnoFreshness f) => switch (f) {
    BinnoFreshness.fresh => 0,
    BinnoFreshness.normal => 1,
    BinnoFreshness.stale => 2,
    BinnoFreshness.expired => 3,
  };

  bool _matches(MockOffer offer) {
    if (offer.price < priceMin || offer.price > priceMax) return false;
    if (verifiedOnly && !offer.store.verified) return false;
    if (freshOnly && offer.freshness != BinnoFreshness.fresh) return false;

    if (fulfillment == 1 && offer.deliveryFee == null) return false;
    if (fulfillment == 2 && !offer.pickupAvailable) return false;

    final distance = offer.distanceKm;
    if (distance != null && distance > radiusKm) return false;

    if (complexes.isNotEmpty) {
      final complex = offer.store.complex;
      if (complex == null || !complexes.any((c) => c.startsWith(complex))) {
        return false;
      }
    }

    return true;
  }

  int _compare(MockOffer a, MockOffer b) => switch (sort) {
    1 => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999),
    2 => _freshRank(a.freshness).compareTo(_freshRank(b.freshness)),
    3 => b.store.rating.compareTo(a.store.rating),
    _ => a.price.compareTo(b.price),
  };

  /// Filter and sort. The source list is left unchanged.
  List<MockOffer> apply(List<MockOffer> offers) {
    final result = offers.where(_matches).toList()..sort(_compare);
    return result;
  }

  /// Unique stores in the result, e.g. "12 taklif · 5 do'kon".
  static int storeCount(List<MockOffer> offers) =>
      offers.map((o) => o.store.title).toSet().length;

  SearchFilters copyWith({String? query}) => SearchFilters(
    query: query ?? this.query,
    sort: sort,
    fulfillment: fulfillment,
    freshOnly: freshOnly,
    verifiedOnly: verifiedOnly,
    priceMin: priceMin,
    priceMax: priceMax,
    radiusKm: radiusKm,
    complexes: complexes,
  );
}
