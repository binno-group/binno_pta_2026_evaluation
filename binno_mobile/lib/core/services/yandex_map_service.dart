import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../constants/map_const.dart';

/// The single map-related service: reverse geocoding and current location.
///
/// The whole MapKit API is gathered in this file, so when the package
/// version changes or an API signature differs, the fix lands here only.
@lazySingleton
class YandexMapService {
  /// Point to address text (reverse geocoding).
  ///
  /// Returns `null` when there is no network or the response is empty; the
  /// caller keeps showing the coordinates and the app does not crash.
  Future<String?> addressOfPoint(Point point) async {
    try {
      // In 4.x, `searchByPoint` returns a (session, result) record.
      final (_, resultFuture) = await YandexSearch.searchByPoint(
        point: point,
        zoom: MapConst.pickerZoom.toInt(),
        searchOptions: const SearchOptions(
          searchType: SearchType.geo,
          geometry: false,
        ),
      );

      final result = await resultFuture;
      final items = result.items;
      if (items == null || items.isEmpty) return null;

      final address = items.first.toponymMetadata?.address.formattedAddress;
      if (address == null || address.trim().isEmpty) return null;
      return address;
    } catch (_) {
      // Geocoding is optional: the point can be picked without an address.
      return null;
    }
  }

  /// The current location. `null` when permission is denied or GPS is off.
  Future<Point?> currentPoint() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      return Point(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return null;
    }
  }

  /// The distance between two points, in kilometres.
  double distanceKm(Point from, Point to) {
    final meters = Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
    return meters / 1000;
  }

  /// Checks whether the point lies inside Uzbekistan (§15).
  ///
  /// A simplified polygon is used here: it covers all Uzbek cities and
  /// rejects distant neighbouring territory. In production a precise
  /// GeoJSON boundary is recommended.
  bool isInsideUzbekistan(Point p) =>
      _pointInPolygon(p, _uzbekistanBoundary);

  static bool _pointInPolygon(Point p, List<Point> polygon) {
    var inside = false;
    final n = polygon.length;
    for (var i = 0, j = n - 1; i < n; j = i++) {
      final yi = polygon[i].latitude, xi = polygon[i].longitude;
      final yj = polygon[j].latitude, xj = polygon[j].longitude;
      final intersect = ((yi > p.latitude) != (yj > p.latitude)) &&
          (p.longitude < (xj - xi) * (p.latitude - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  /// The Uzbekistan boundary (simplified polygon, lat/lng).
  ///
  /// `final` so we do not depend on the `Point` constructor being const.
  static final List<Point> _uzbekistanBoundary = [
    Point(latitude: 45.60, longitude: 58.20),
    Point(latitude: 45.55, longitude: 61.30),
    Point(latitude: 44.10, longitude: 62.10),
    Point(latitude: 43.20, longitude: 64.30),
    Point(latitude: 42.20, longitude: 66.00),
    Point(latitude: 41.90, longitude: 68.40),
    Point(latitude: 41.30, longitude: 69.90),
    Point(latitude: 41.05, longitude: 70.60),
    Point(latitude: 41.35, longitude: 71.40),
    Point(latitude: 41.15, longitude: 72.95),
    Point(latitude: 40.70, longitude: 73.15),
    Point(latitude: 40.15, longitude: 72.00),
    Point(latitude: 39.50, longitude: 70.00),
    Point(latitude: 38.10, longitude: 68.20),
    Point(latitude: 37.10, longitude: 68.20),
    Point(latitude: 36.95, longitude: 66.90),
    Point(latitude: 37.60, longitude: 65.10),
    Point(latitude: 38.20, longitude: 64.10),
    Point(latitude: 39.20, longitude: 62.30),
    Point(latitude: 41.10, longitude: 60.10),
    Point(latitude: 43.00, longitude: 58.40),
    Point(latitude: 44.30, longitude: 58.00),
  ];
}
