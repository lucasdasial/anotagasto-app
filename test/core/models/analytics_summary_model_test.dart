import 'package:anotagasto_app/core/models/analytics_summary_model.dart';
import 'package:anotagasto_app/core/models/expense_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> summaryPayload({
    int total = 10000,
    int count = 5,
    List<Map<String, dynamic>> byCategory = const [],
  }) {
    return {
      'data': {
        'total': total,
        'count': count,
        'by_category': byCategory,
      },
    };
  }

  group('AnalyticsSummaryModel.fromJson', () {
    test('parses totalMonth, count and byCategory from data wrapper', () {
      final model = AnalyticsSummaryModel.fromJson(
        summaryPayload(total: 10000, count: 5),
      );

      expect(model.totalMonth, 10000);
      expect(model.count, 5);
    });

    test('parses without data wrapper', () {
      final model = AnalyticsSummaryModel.fromJson({
        'total': 5000,
        'count': 2,
        'by_category': [],
      });

      expect(model.totalMonth, 5000);
      expect(model.count, 2);
    });

    test('returns zero defaults when fields are missing', () {
      final model = AnalyticsSummaryModel.fromJson({});

      expect(model.totalMonth, 0);
      expect(model.count, 0);
      expect(model.byCategory, isEmpty);
    });

    test('converts num totalMonth to int', () {
      final model = AnalyticsSummaryModel.fromJson(
        summaryPayload(total: 9999),
      );

      expect(model.totalMonth, isA<int>());
    });
  });

  group('percentage calculation', () {
    test('calculates percentage client-side from total', () {
      final model = AnalyticsSummaryModel.fromJson(
        summaryPayload(
          total: 10000,
          byCategory: [
            {'category': 'grocery', 'total': 6000},
            {'category': 'eat_out', 'total': 4000},
          ],
        ),
      );

      expect(model.byCategory[0].percentage, closeTo(60.0, 0.01));
      expect(model.byCategory[1].percentage, closeTo(40.0, 0.01));
    });

    test('returns 0 percentage when totalMonth is zero', () {
      final model = AnalyticsSummaryModel.fromJson(
        summaryPayload(
          total: 0,
          byCategory: [
            {'category': 'grocery', 'total': 0},
          ],
        ),
      );

      expect(model.byCategory[0].percentage, 0.0);
    });
  });

  group('topCategory', () {
    test('returns first category with total greater than zero', () {
      final model = AnalyticsSummaryModel.fromJson(
        summaryPayload(
          total: 8000,
          byCategory: [
            {'category': 'grocery', 'total': 5000},
            {'category': 'eat_out', 'total': 3000},
          ],
        ),
      );

      expect(model.topCategory?.category, ExpenseCategory.grocery);
    });

    test('skips categories with zero total', () {
      final model = AnalyticsSummaryModel.fromJson(
        summaryPayload(
          total: 3000,
          byCategory: [
            {'category': 'grocery', 'total': 0},
            {'category': 'eat_out', 'total': 3000},
          ],
        ),
      );

      expect(model.topCategory?.category, ExpenseCategory.eatOut);
    });

    test('returns null when all categories have zero total', () {
      final model = AnalyticsSummaryModel.fromJson(
        summaryPayload(
          total: 0,
          byCategory: [
            {'category': 'grocery', 'total': 0},
          ],
        ),
      );

      expect(model.topCategory, isNull);
    });

    test('returns null when byCategory is empty', () {
      final model = AnalyticsSummaryModel.fromJson(summaryPayload());

      expect(model.topCategory, isNull);
    });
  });
}
