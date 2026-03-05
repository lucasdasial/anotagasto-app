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
      },
    );
    return ExpenseModel.fromJson(response.data['data']);
  }
}
