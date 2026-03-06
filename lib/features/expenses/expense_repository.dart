import 'package:anotagasto_app/core/http/http_client.dart';
import 'package:anotagasto_app/core/models/expense_category.dart';
import 'package:anotagasto_app/core/models/expense_model.dart';

class ExpenseRepository {
  late HttpClient _http;

  ExpenseRepository(HttpClient http) {
    _http = http;
  }

  Future<ExpenseListModel> getExpenseList() async {
    final response = await _http.get("/expenses");
    return ExpenseListModel.fromMap(response.data);
  }

  Future<void> deleteExpense(String id) async {
    await _http.delete("/expenses/$id");
  }

  Future<ExpenseModel> createExpense({
    required int value,
    required String description,
    required ExpenseCategory category,
  }) async {
    final response = await _http.post(
      "/expenses",
      bodyParams: {
        "value": value,
        "description": description,
        "category": category.toApi(),
        "date": DateTime.now().toIso8601String().substring(0, 10),
      },
    );
    return ExpenseModel.fromJson(response.data['data']);
  }

  Future<ExpenseModel> updateExpense({
    required String id,
    required int value,
    required String description,
    required ExpenseCategory category,
    required DateTime date,
  }) async {
    final response = await _http.put(
      "/expenses/$id",
      bodyParams: {
        "expense": {
          "value": value,
          "description": description,
          "category": category.toApi(),
          "date": date.toIso8601String().substring(0, 10),
        },
      },
    );
    return ExpenseModel.fromJson(response.data['data']);
  }
}
