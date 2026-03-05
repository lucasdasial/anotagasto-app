import 'package:anotagasto_app/core/view_state.dart';
import 'package:anotagasto_app/features/expenses/expense_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class ExpensesViewModel extends ChangeNotifier {
  final ExpenseRepository expenseRepository;
  ViewState viewState = InitialStateView();

  ExpensesViewModel(this.expenseRepository);

  Future<void> getExpenseList() async {
    viewState = LoadingStateView();
    notifyListeners();

    try {
      final expenses = await expenseRepository.getExpenseList();
      viewState = SuccessStateView(expenses);
    } on DioException catch (e) {
      viewState = ErrorStateView(e.response?.data["error"] ?? e.message);
    } catch (e, stack) {
      debugPrint('ExpensesViewModel.getExpenseList: $e\n$stack');
      viewState = ErrorStateView(
        'Ocorreu um erro inesperado. Tente novamente.',
      );
    }

    notifyListeners();
  }

  Future<void> addExpense() async {}
}
