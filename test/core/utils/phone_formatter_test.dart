import 'package:anotagasto_app/core/utils/phone_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneMaskFormatter.unmasked', () {
    test('strips mask from mobile number', () {
      expect(PhoneMaskFormatter.unmasked('(11) 99999-9999'), '11999999999');
    });

    test('strips mask from landline number', () {
      expect(PhoneMaskFormatter.unmasked('(11) 3333-4444'), '1133334444');
    });

    test('returns empty string for empty input', () {
      expect(PhoneMaskFormatter.unmasked(''), '');
    });

    test('returns digits unchanged when already unmasked', () {
      expect(PhoneMaskFormatter.unmasked('11999999999'), '11999999999');
    });
  });

  group('PhoneMaskFormatter.formatEditUpdate', () {
    final formatter = PhoneMaskFormatter();

    TextEditingValue update(String text) {
      return formatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: text),
      );
    }

    test('applies mobile mask for 11 digits', () {
      expect(update('11999999999').text, '(11) 99999-9999');
    });

    test('applies landline mask for 10 digits', () {
      expect(update('1133334444').text, '(11) 3333-4444');
    });

    test('applies partial mask for 2 digits', () {
      expect(update('11').text, '(11');
    });

    test('applies partial mask for 6 digits', () {
      expect(update('119999').text, '(11) 9999');
    });

    test('truncates input beyond 11 digits', () {
      expect(update('119999999999').text, '(11) 99999-9999');
    });

    test('returns empty string for empty input', () {
      expect(update('').text, '');
    });
  });
}
