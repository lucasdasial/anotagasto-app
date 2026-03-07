import 'package:anotagasto_app/core/models/expense_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseCategory.toApi', () {
    test('converts camelCase enum to snake_case api string', () {
      expect(ExpenseCategory.grocery.toApi(), 'grocery');
      expect(ExpenseCategory.eatOut.toApi(), 'eat_out');
      expect(ExpenseCategory.cleaningProducts.toApi(), 'cleaning_products');
      expect(ExpenseCategory.transportPublic.toApi(), 'transport_public');
      expect(ExpenseCategory.transportApps.toApi(), 'transport_apps');
      expect(ExpenseCategory.uncategorized.toApi(), 'uncategorized');
    });
  });

  group('ExpenseCategory.fromApi', () {
    test('parses known api strings to enum values', () {
      expect(ExpenseCategory.fromApi('grocery'), ExpenseCategory.grocery);
      expect(ExpenseCategory.fromApi('eat_out'), ExpenseCategory.eatOut);
      expect(
        ExpenseCategory.fromApi('cleaning_products'),
        ExpenseCategory.cleaningProducts,
      );
      expect(
        ExpenseCategory.fromApi('transport_public'),
        ExpenseCategory.transportPublic,
      );
      expect(
        ExpenseCategory.fromApi('transport_apps'),
        ExpenseCategory.transportApps,
      );
    });

    test('returns uncategorized for unknown string', () {
      expect(
        ExpenseCategory.fromApi('unknown_value'),
        ExpenseCategory.uncategorized,
      );
    });

    test('returns uncategorized for empty string', () {
      expect(ExpenseCategory.fromApi(''), ExpenseCategory.uncategorized);
    });
  });

  group('toApi / fromApi roundtrip', () {
    test('all categories survive a roundtrip', () {
      for (final category in ExpenseCategory.values) {
        expect(ExpenseCategory.fromApi(category.toApi()), category);
      }
    });
  });

  group('label', () {
    test('grocery label is Mercado', () {
      expect(ExpenseCategory.grocery.label, 'Mercado');
    });

    test('uncategorized label is Sem categoria', () {
      expect(ExpenseCategory.uncategorized.label, 'Sem categoria');
    });

    test('every category has a non-empty label', () {
      for (final category in ExpenseCategory.values) {
        expect(category.label, isNotEmpty);
      }
    });
  });

  group('icon', () {
    test('every category has a non-null icon', () {
      for (final category in ExpenseCategory.values) {
        expect(category.icon, isNotNull);
      }
    });
  });
}
