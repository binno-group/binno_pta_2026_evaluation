import 'package:binno/core/helpers/money.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for the `Money` formatter.
void main() {
  const nb = Money.nbsp; // uzilmas probel

  group('Money.format', () {
    test('groups thousands with a non-breaking space', () {
      expect(Money.format(2040000), '2${nb}040${nb}000');
      expect(Money.format(48000), '48${nb}000');
      expect(Money.format(600000), '600${nb}000');
      expect(Money.format(1000), '1${nb}000');
    });

    test('numbers below a thousand are not grouped', () {
      expect(Money.format(0), '0');
      expect(Money.format(5), '5');
      expect(Money.format(999), '999');
    });

    test('prefixes a negative number with a minus', () {
      expect(Money.format(-1500), '-1${nb}500');
    });

    test('a fractional number is rounded', () {
      expect(Money.format(1999.6), '2${nb}000');
      expect(Money.format(48000.4), '48${nb}000');
    });
  });

  group('Money.som', () {
    test('appends a non-breaking space and so\'m', () {
      expect(Money.som(48000), '48${nb}000${nb}so\'m');
    });
  });

  group('Money.perUnit', () {
    test('renders as price / unit', () {
      expect(Money.perUnit(48000, 'qop'), '48${nb}000${nb}so\'m$nb/${nb}qop');
    });
  });

  group('Money.qty', () {
    test('a whole number shows no fraction', () {
      expect(Money.qty(120, 'qop'), '120${nb}qop');
    });

    test('a fractional number is kept', () {
      expect(Money.qty(11.7, 'm'), '11.7${nb}m');
    });
  });

  group('Money.fromTiyin', () {
    test('converts tiyin to so\'m', () {
      expect(Money.fromTiyin(204000000), 2040000);
      expect(Money.fromTiyin(100), 1);
    });
  });
}
