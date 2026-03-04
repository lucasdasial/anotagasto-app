import 'expense_category.dart';
import 'pagination_model.dart';

class ExpenseModel {
  final String id;
  final int value;
  final String description;
  final ExpenseCategory category;
  final DateTime date;
  final String userId;

  const ExpenseModel({
    required this.id,
    required this.value,
    required this.description,
    required this.category,
    required this.date,
    required this.userId,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'].toString(),
      value: (json['value'] as num).toInt(),
      description: json['description'] as String? ?? '',
      category: ExpenseCategory.fromApi(json['category'] as String? ?? ''),
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      userId: json['user_id'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'description': description,
      'category': category.toApi(),
      'date': date.toIso8601String(),
      'user_id': userId,
    };
  }

  ExpenseModel copyWith({
    String? id,
    int? value,
    String? description,
    ExpenseCategory? category,
    DateTime? date,
    String? userId,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      value: value ?? this.value,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }
}

class ExpenseListResult {
  final List<ExpenseModel> expenses;
  final PaginationModel pagination;

  const ExpenseListResult({required this.expenses, required this.pagination});

  factory ExpenseListResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List? ?? [];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return ExpenseListResult(
      expenses: data
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromJson(meta),
    );
  }
}
