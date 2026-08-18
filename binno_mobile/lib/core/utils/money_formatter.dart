import 'package:intl/intl.dart';

/// The only presentation boundary for API money values.
///
/// Money enters the app as integer tiyin and is never accepted as [num] or
/// [double]. The backend remains authoritative for every calculation.
abstract final class MoneyFormat {
  static final NumberFormat _integerFormat = NumberFormat.decimalPattern('uz');

  static String som(int amount) {
    return '${_integerFormat.format(amount).replaceAll(RegExp(r"[\u00A0\u202F]"), ' ')} so\'m';
  }
}
