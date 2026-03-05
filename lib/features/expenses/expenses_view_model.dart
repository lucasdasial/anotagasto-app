import 'package:anotagasto_app/core/models/expense_category.dart';
import 'package:anotagasto_app/core/models/expense_model.dart';
import 'package:anotagasto_app/core/models/pagination_model.dart';
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

  /// Throws on error — caller is responsible for handling.
  Future<void> deleteExpense(String id) async {
    await expenseRepository.deleteExpense(id);

    if (viewState is SuccessStateView<ExpenseListModel>) {
      final current = (viewState as SuccessStateView<ExpenseListModel>).data;
      final expense = current.expenses.firstWhere((e) => e.id == id);
      viewState = SuccessStateView(
        ExpenseListModel(
          expenses: current.expenses.where((e) => e.id != id).toList(),
          amountTotal: current.amountTotal - expense.value,
          pagination: PaginationModel(
            page: current.pagination.page,
            pageSize: current.pagination.pageSize,
            total: current.pagination.total - 1,
            totalPages: current.pagination.totalPages,
          ),
        ),
      );
      notifyListeners();
    }
  }

  /// Throws on error — caller (sheet) is responsible for handling.
  Future<void> addExpense({
    required int value,
    required String description,
    required ExpenseCategory category,
  }) async {
    final expense = await expenseRepository.createExpense(
      value: value,
      description: description,
      category: category,
    );

    if (viewState is SuccessStateView<ExpenseListModel>) {
      final current = (viewState as SuccessStateView<ExpenseListModel>).data;
      viewState = SuccessStateView(
        ExpenseListModel(
          expenses: [expense, ...current.expenses],
          amountTotal: current.amountTotal + expense.value,
          pagination: PaginationModel(
            page: current.pagination.page,
            pageSize: current.pagination.pageSize,
            total: current.pagination.total + 1,
            totalPages: current.pagination.totalPages,
          ),
        ),
      );
      notifyListeners();
    }
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
}
