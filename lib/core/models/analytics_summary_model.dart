import 'expense_category.dart';

class CategoryStat {
  final ExpenseCategory category;
  final int total;
  final double percentage;

  const CategoryStat({
    required this.category,
    required this.total,
    required this.percentage,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    return CategoryStat(
      category: ExpenseCategory.fromApi(json['category'] as String? ?? ''),
      total: (json['total'] as num?)?.toInt() ?? 0,
      percentage: 0, // calculated in AnalyticsSummaryModel.fromJson
    );
  }
}

class AnalyticsSummaryModel {
  final int totalMonth;
  final List<CategoryStat> byCategory;

  const AnalyticsSummaryModel({
    required this.totalMonth,
    required this.byCategory,
  });

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final totalMonth = (data['total'] as num?)?.toInt() ?? 0;
    final categories = data['by_category'] as List? ?? [];
    final byCategory = categories
        .map((e) => CategoryStat.fromJson(e as Map<String, dynamic>))
        .toList();
    // Percentage is not returned by the API; calculate client-side.
    final withPercentage = byCategory
        .map((s) => CategoryStat(
              category: s.category,
              total: s.total,
              percentage: totalMonth > 0 ? s.total / totalMonth * 100 : 0,
            ))
        .toList();
    return AnalyticsSummaryModel(
      totalMonth: totalMonth,
      byCategory: withPercentage,
    );
  }
}
