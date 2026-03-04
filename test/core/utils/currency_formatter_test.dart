import 'package:anotagasto_app/core/utils/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyFormatter.format', () {
    test('formats zero cents as BRL zero', () {
      expect(CurrencyFormatter.format(0), 'R\$\u00a00,00');
    });

    test('divides cents by 100 before formatting', () {
      expect(CurrencyFormatter.format(1000), 'R\$\u00a010,00');
    });

    test('formats thousands with dot separator', () {
      expect(CurrencyFormatter.format(100000), 'R\$\u00a01.000,00');
    });

    test('formats cents remainder with comma separator', () {
      expect(CurrencyFormatter.format(123456), 'R\$\u00a01.234,56');
    });

    test('formats negative value with minus sign', () {
      expect(CurrencyFormatter.format(-990), '-R\$\u00a09,90');
    });
  });

  group('CurrencyFormatter.parse', () {
    test('parses BRL string to cents', () {
      expect(CurrencyFormatter.parse('R\$\u00a010,00'), 1000);
    });

    test('parses value with thousands separator to cents', () {
      expect(CurrencyFormatter.parse('R\$\u00a01.234,56'), 123456);
    });

    test('parses zero', () {
      expect(CurrencyFormatter.parse('R\$\u00a00,00'), 0);
    });

    test('returns null for non-numeric string', () {
      expect(CurrencyFormatter.parse('abc'), null);
    });
  });
}
