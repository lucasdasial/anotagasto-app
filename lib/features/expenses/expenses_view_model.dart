import 'package:anotagasto_app/core/models/expense_category.dart';
import 'package:anotagasto_app/core/models/expense_model.dart';
import 'package:anotagasto_app/core/view_state.dart';
import 'package:anotagasto_app/features/expenses/expense_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class ExpensesViewModel extends ChangeNotifier {
  final ExpenseRepository expenseRepository;
  ViewState viewState = InitialStateView();

  final Set<ExpenseCategory> _selectedCategories = {};
  Set<ExpenseCategory> get selectedCategories =>
      Set.unmodifiable(_selectedCategories);

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

  void toggleCategory(ExpenseCategory category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    notifyListeners();
  }

  List<ExpenseModel> applyFilter(List<ExpenseModel> all) {
    if (_selectedCategories.isEmpty) return all;
    return all.where((e) => _selectedCategories.contains(e.category)).toList();
  }

  Future<void> addExpense() async {}
}
