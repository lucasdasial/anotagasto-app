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
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

class ExpenseListModel {
  final List<ExpenseModel> expenses;
  final int amountTotal;
  final PaginationModel pagination;

  const ExpenseListModel({
    required this.expenses,
    required this.amountTotal,
    required this.pagination,
  });

  factory ExpenseListModel.fromMap(Map<String, dynamic> json) {
    final data = json['data'] as List? ?? [];
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    return ExpenseListModel(
      amountTotal: _parseInt(json["amount_total"]),
      expenses: data
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromMap(pagination),
    );
  }
}
