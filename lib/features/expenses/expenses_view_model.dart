import 'package:anotagasto_app/core/models/expense_category.dart';
import 'package:anotagasto_app/core/models/expense_model.dart';
import 'package:anotagasto_app/core/models/pagination_model.dart';
import 'package:anotagasto_app/core/utils/date_formatter.dart';
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

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime get selectedMonth => _selectedMonth;

  ExpensesViewModel(this.expenseRepository);

  Future<void> getExpenseList() async {
    viewState = LoadingStateView();
    notifyListeners();

    try {
      final month = DateFormatter.toApiMonth(
        _selectedMonth.year,
        _selectedMonth.month,
      );
      final expenses = await expenseRepository.getExpenseList(month: month);
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

  Future<void> changeMonth(DateTime month) async {
    _selectedMonth = DateTime(month.year, month.month);
    _selectedCategories.clear();
    await getExpenseList();
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
          expenses: _sortedByDate([expense, ...current.expenses]),
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

  /// Throws on error — caller is responsible for handling.
  Future<void> editExpense({
    required String id,
    required int value,
    required String description,
    required ExpenseCategory category,
    required DateTime date,
  }) async {
    final updated = await expenseRepository.updateExpense(
      id: id,
      value: value,
      description: description,
      category: category,
      date: date,
    );

    if (viewState is SuccessStateView<ExpenseListModel>) {
      final current = (viewState as SuccessStateView<ExpenseListModel>).data;
      final old = current.expenses.firstWhere((e) => e.id == id);
      viewState = SuccessStateView(
        ExpenseListModel(
          expenses: _sortedByDate(
            current.expenses.map((e) => e.id == id ? updated : e).toList(),
          ),
          amountTotal: current.amountTotal - old.value + updated.value,
          pagination: current.pagination,
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

  void clearCategories() {
    _selectedCategories.clear();
    notifyListeners();
  }

  List<ExpenseModel> _sortedByDate(List<ExpenseModel> expenses) {
    return [...expenses]..sort((a, b) => b.date.compareTo(a.date));
  }

  List<ExpenseModel> applyFilter(List<ExpenseModel> all) {
    if (_selectedCategories.isEmpty) return all;
    return all.where((e) => _selectedCategories.contains(e.category)).toList();
  }
}
