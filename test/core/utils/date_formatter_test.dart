import 'package:anotagasto_app/core/utils/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateFormatter.toApiMonth', () {
    test('formats single-digit month with leading zero', () {
      expect(DateFormatter.toApiMonth(2024, 3), '2024-03');
    });

    test('formats double-digit month without padding', () {
      expect(DateFormatter.toApiMonth(2024, 12), '2024-12');
    });

    test('pads year with leading zeros when below 4 digits', () {
      expect(DateFormatter.toApiMonth(999, 1), '0999-01');
    });
  });

  group('DateFormatter.fromApiMonth', () {
    test('parses year and month from API string', () {
      final result = DateFormatter.fromApiMonth('2024-03');
      expect(result.year, 2024);
      expect(result.month, 3);
    });

    test('parses double-digit month correctly', () {
      final result = DateFormatter.fromApiMonth('2024-12');
      expect(result.year, 2024);
      expect(result.month, 12);
    });
  });

  group('DateFormatter.monthLabel', () {
    test('returns January label in Portuguese', () {
      expect(DateFormatter.monthLabel(2024, 1), 'Janeiro 2024');
    });

    test('returns June label in Portuguese', () {
      expect(DateFormatter.monthLabel(2024, 6), 'Junho 2024');
    });

    test('returns December label in Portuguese', () {
      expect(DateFormatter.monthLabel(2024, 12), 'Dezembro 2024');
    });
  });

  group('DateFormatter.formatDate', () {
    test('formats date as dd/MM/yyyy', () {
      expect(DateFormatter.formatDate(DateTime(2024, 3, 5)), '05/03/2024');
    });
  });

  group('DateFormatter.formatDateShort', () {
    test('formats date as dd/MM', () {
      expect(DateFormatter.formatDateShort(DateTime(2024, 3, 5)), '05/03');
    });
  });
}
