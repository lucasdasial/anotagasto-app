import 'package:anotagasto_app/core/models/expense_category.dart';
import 'package:anotagasto_app/core/models/expense_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseModel.fromJson', () {
    test('parses all fields correctly', () {
      final model = ExpenseModel.fromJson({
        'id': 'abc-123',
        'value': 1500,
        'description': 'Supermercado',
        'category': 'grocery',
        'date': '2024-03-15',
        'user_id': 'user-1',
      });

      expect(model.id, 'abc-123');
      expect(model.value, 1500);
      expect(model.description, 'Supermercado');
      expect(model.category, ExpenseCategory.grocery);
      expect(model.date, DateTime(2024, 3, 15));
      expect(model.userId, 'user-1');
    });

    test('converts non-string id to string', () {
      final model = ExpenseModel.fromJson({
        'id': 42,
        'value': 100,
        'description': '',
        'category': 'grocery',
        'date': '2024-03-15',
        'user_id': 1,
      });

      expect(model.id, '42');
      expect(model.userId, '1');
    });

    test('converts num value to int', () {
      final model = ExpenseModel.fromJson({
        'id': '1',
        'value': 999.0,
        'description': '',
        'category': 'grocery',
        'date': '2024-03-15',
        'user_id': '1',
      });

      expect(model.value, 999);
      expect(model.value, isA<int>());
    });

    test('returns empty description when missing', () {
      final model = ExpenseModel.fromJson({
        'id': '1',
        'value': 100,
        'category': 'grocery',
        'date': '2024-03-15',
        'user_id': '1',
      });

      expect(model.description, '');
    });

    test('returns uncategorized for unknown category', () {
      final model = ExpenseModel.fromJson({
        'id': '1',
        'value': 100,
        'description': '',
        'category': 'invalid_category',
        'date': '2024-03-15',
        'user_id': '1',
      });

      expect(model.category, ExpenseCategory.uncategorized);
    });

    test('falls back to DateTime.now for invalid date', () {
      final before = DateTime.now();
      final model = ExpenseModel.fromJson({
        'id': '1',
        'value': 100,
        'description': '',
        'category': 'grocery',
        'date': 'not-a-date',
        'user_id': '1',
      });
      final after = DateTime.now();

      expect(
        model.date.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        model.date.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });
  });

  group('ExpenseModel.toJson', () {
    test('serializes all fields correctly', () {
      final model = ExpenseModel(
        id: 'abc-123',
        value: 1500,
        description: 'Supermercado',
        category: ExpenseCategory.grocery,
        date: DateTime(2024, 3, 15),
        userId: 'user-1',
      );

      final json = model.toJson();

      expect(json['id'], 'abc-123');
      expect(json['value'], 1500);
      expect(json['description'], 'Supermercado');
      expect(json['category'], 'grocery');
      expect(json['user_id'], 'user-1');
      expect(json['date'], contains('2024-03-15'));
    });
  });

  group('ExpenseListModel.fromMap', () {
    test('parses expenses, amountTotal and pagination', () {
      final model = ExpenseListModel.fromMap({
        'data': [
          {
            'id': '1',
            'value': 500,
            'description': 'Item 1',
            'category': 'grocery',
            'date': '2024-03-01',
            'user_id': 'u1',
          },
        ],
        'amount_total': 500,
        'pagination': {
          'page': 1,
          'page_size': 20,
          'total': 1,
          'total_pages': 1,
        },
      });

      expect(model.expenses.length, 1);
      expect(model.amountTotal, 500);
      expect(model.pagination.page, 1);
    });

    test('returns empty list and zero total when data is missing', () {
      final model = ExpenseListModel.fromMap({});

      expect(model.expenses, isEmpty);
      expect(model.amountTotal, 0);
    });
  });
}
