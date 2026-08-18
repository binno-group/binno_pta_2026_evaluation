/// The BINNO money formatter.
///
/// One presentation: `600 000 so'm`, thousands grouped with a thin
/// (non-breaking) space, and "so'm" never wraps to the next line alone.
///
/// Per the Master Spec, money is stored as **integer tiyin** in the
/// database and the UI shows so'm. The mock data comes in so'm, so it is
/// formatted directly; [fromTiyin] converts when needed.
abstract class Money {
  /// The non-breaking space between digit groups and the unit.
  static const nbsp = ' ';

  /// `2040000` → `2 040 000`
  static String format(num amount) {
    final isNegative = amount < 0;
    final digits = amount.abs().round().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && (digits.length - i) % 3 == 0) buffer.write(nbsp);
      buffer.write(digits[i]);
    }

    return isNegative ? '-${buffer.toString()}' : buffer.toString();
  }

  /// `2040000` → `2 040 000 so'm`
  static String som(num amount) => '${format(amount)}${nbsp}so\'m';

  /// `48000, 'qop'` → `48 000 so'm / qop`
  static String perUnit(num amount, String unit) =>
      '${som(amount)}$nbsp/$nbsp$unit';

  /// Converts tiyin to so'm.
  static num fromTiyin(int tiyin) => tiyin / 100;

  /// `120, 'qop'` → `120 qop`
  static String qty(num value, String unit) {
    final text = value == value.roundToDouble()
        ? value.round().toString()
        : value.toString();
    return '$text$nbsp$unit';
  }
}
