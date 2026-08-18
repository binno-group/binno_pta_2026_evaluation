import 'package:binno_app/core/utils/money_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats integer API money with Uzbek grouping', () {
    expect(MoneyFormat.som(600000), "600 000 so'm");
  });

  test('does not add decimals to zero', () {
    expect(MoneyFormat.som(0), "0 so'm");
  });
}
