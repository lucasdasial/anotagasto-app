import 'expense_category.dart';

class CategoryStat {
  final ExpenseCategory category;
  final double total;
  final double percentage;

  const CategoryStat({
    required this.category,
    required this.total,
    required this.percentage,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    return CategoryStat(
      category: ExpenseCategory.fromApi(json['category'] as String? ?? ''),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AnalyticsSummaryModel {
  final double totalMonth;
  final List<CategoryStat> byCategory;

  const AnalyticsSummaryModel({
    required this.totalMonth,
    required this.byCategory,
  });

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final categories = data['by_category'] as List? ?? [];
    return AnalyticsSummaryModel(
      totalMonth: (data['total_month'] as num?)?.toDouble() ?? 0.0,
      byCategory: categories
          .map((e) => CategoryStat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
