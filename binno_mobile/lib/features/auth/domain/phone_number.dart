final class UzbekistanPhoneNumber {
  const UzbekistanPhoneNumber._(this.e164);

  final String e164;

  static UzbekistanPhoneNumber? parse(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    final normalized = digits.startsWith('998') ? digits : '998$digits';
    if (!RegExp(r'^998\d{9}$').hasMatch(normalized)) {
      return null;
    }
    return UzbekistanPhoneNumber._('+$normalized');
  }

  static String display(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    final local = digits.startsWith('998') ? digits.substring(3) : digits;
    final limited = local.substring(0, local.length.clamp(0, 9));
    final buffer = StringBuffer('+998');
    if (limited.isNotEmpty) {
      buffer.write(
        ' ${limited.substring(0, limited.length < 2 ? limited.length : 2)}',
      );
    }
    if (limited.length > 2) {
      buffer.write(
        ' ${limited.substring(2, limited.length < 5 ? limited.length : 5)}',
      );
    }
    if (limited.length > 5) {
      buffer.write(
        ' ${limited.substring(5, limited.length < 7 ? limited.length : 7)}',
      );
    }
    if (limited.length > 7) {
      buffer.write(' ${limited.substring(7, limited.length)}');
    }
    return buffer.toString();
  }
}
