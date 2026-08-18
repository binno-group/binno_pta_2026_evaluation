import 'package:binno_app/features/auth/domain/phone_number.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses Uzbek local number into E.164', () {
    expect(
      UzbekistanPhoneNumber.parse('90 123 45 67')?.e164,
      '+998901234567',
    );
  });

  test('rejects incomplete number', () {
    expect(UzbekistanPhoneNumber.parse('90123'), isNull);
  });

  test('formats every progressive display segment', () {
    expect(UzbekistanPhoneNumber.display(''), '+998');
    expect(UzbekistanPhoneNumber.display('9'), '+998 9');
    expect(UzbekistanPhoneNumber.display('901'), '+998 90 1');
    expect(UzbekistanPhoneNumber.display('901234'), '+998 90 123 4');
    expect(UzbekistanPhoneNumber.display('90123456'), '+998 90 123 45 6');
    expect(
      UzbekistanPhoneNumber.display('+998901234567'),
      '+998 90 123 45 67',
    );
  });
}
