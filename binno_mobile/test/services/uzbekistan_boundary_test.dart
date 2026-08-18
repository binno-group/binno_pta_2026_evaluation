import 'package:binno/core/services/yandex_map_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Tests for `YandexMapService.isInsideUzbekistan`, the boundary polygon (§15).
void main() {
  final service = YandexMapService();

  Point p(double lat, double lng) => Point(latitude: lat, longitude: lng);

  group('Uzbek cities are inside', () {
    const cities = {
      'Toshkent': [41.31, 69.24],
      'Samarqand': [39.65, 66.96],
      'Buxoro': [39.77, 64.42],
      'Nukus': [42.46, 59.61],
      'Termiz': [37.22, 67.28],
      'Andijon': [40.78, 72.34],
      'Farg\'ona': [40.39, 71.78],
      'Xiva': [41.38, 60.36],
      'Namangan': [40.99, 71.67],
      'Qarshi': [38.86, 65.79],
    };

    cities.forEach((name, c) {
      test('$name is inside', () {
        expect(service.isInsideUzbekistan(p(c[0], c[1])), isTrue);
      });
    });
  });

  group('distant neighbouring cities are outside', () {
    const outside = {
      'Almati (KZ)': [43.24, 76.89],
      'Bishkek (KG)': [42.87, 74.59],
      'Ashxabad (TM)': [37.95, 58.38],
      'Moskva (RU)': [55.75, 37.62],
      'Shymkent (KZ)': [42.32, 69.59],
    };

    outside.forEach((name, c) {
      test('$name is outside', () {
        expect(service.isInsideUzbekistan(p(c[0], c[1])), isFalse);
      });
    });
  });
}
