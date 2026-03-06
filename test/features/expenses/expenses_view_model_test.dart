import 'package:anotagasto_app/core/models/expense_category.dart';
import 'package:anotagasto_app/core/models/expense_model.dart';
import 'package:anotagasto_app/core/models/pagination_model.dart';
import 'package:anotagasto_app/core/view_state.dart';
import 'package:anotagasto_app/features/expenses/expense_repository.dart';
import 'package:anotagasto_app/features/expenses/expenses_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

ExpenseModel _expense({
  String id = '1',
  int value = 1000,
  String description = 'Test',
  ExpenseCategory category = ExpenseCategory.grocery,
}) =>
    ExpenseModel(
      id: id,
      value: value,
      description: description,
      category: category,
      date: DateTime(2024, 1, 1),
      userId: 'user1',
    );

ExpenseListModel _listWith(List<ExpenseModel> expenses, {int amountTotal = 0}) =>
    ExpenseListModel(
      expenses: expenses,
      amountTotal: amountTotal,
      pagination: PaginationModel(
        page: 1,
        pageSize: 20,
        total: expenses.length,
        totalPages: 1,
      ),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(ExpenseCategory.grocery);
    registerFallbackValue(DateTime(2024));
  });

  late MockExpenseRepository expenseRepository;
  late ExpensesViewModel vm;

  setUp(() {
    expenseRepository = MockExpenseRepository();
    vm = ExpensesViewModel(expenseRepository);
  });

  tearDown(() => vm.dispose());

  group('getExpenseList', () {
    test('starts with InitialStateView', () {
      expect(vm.viewState, isA<InitialStateView>());
    });

    test('emits loading then success', () async {
      when(() => expenseRepository.getExpenseList())
          .thenAnswer((_) async => _listWith([]));

      final states = <ViewState>[];
      vm.addListener(() => states.add(vm.viewState));

      await vm.getExpenseList();

      expect(states, [isA<LoadingStateView>(), isA<SuccessStateView>()]);
    });

    test('returns expense list on success', () async {
      final list = _listWith([_expense()], amountTotal: 1000);
      when(() => expenseRepository.getExpenseList())
          .thenAnswer((_) async => list);

      await vm.getExpenseList();

      final state = vm.viewState as SuccessStateView<ExpenseListModel>;
      expect(state.data, list);
    });

    test('sets error message from DioException response body', () async {
      when(() => expenseRepository.getExpenseList()).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 500,
            data: {'error': 'Server error'},
          ),
        ),
      );

      await vm.getExpenseList();

      expect(vm.viewState, isA<ErrorStateView>());
      expect((vm.viewState as ErrorStateView).message, 'Server error');
    });

    test('sets generic message on unexpected error', () async {
      when(() => expenseRepository.getExpenseList())
          .thenThrow(Exception('Unexpected'));

      await vm.getExpenseList();

      expect(vm.viewState, isA<ErrorStateView>());
      expect(
        (vm.viewState as ErrorStateView).message,
        'Ocorreu um erro inesperado. Tente novamente.',
      );
    });
  });

  group('deleteExpense', () {
    test('removes expense from list and decrements total', () async {
      final e1 = _expense(id: '1', value: 1000);
      final e2 = _expense(id: '2', value: 500);
      vm.viewState = SuccessStateView(_listWith([e1, e2], amountTotal: 1500));

      when(() => expenseRepository.deleteExpense('1'))
          .thenAnswer((_) async {});

      await vm.deleteExpense('1');

      final state = vm.viewState as SuccessStateView<ExpenseListModel>;
      expect(state.data.expenses.map((e) => e.id), [e2.id]);
      expect(state.data.amountTotal, 500);
      expect(state.data.pagination.total, 1);
    });

    test('notifies listeners after deletion', () async {
      final e = _expense(id: '1', value: 1000);
      vm.viewState = SuccessStateView(_listWith([e], amountTotal: 1000));

      when(() => expenseRepository.deleteExpense('1'))
          .thenAnswer((_) async {});

      var notified = false;
      vm.addListener(() => notified = true);

      await vm.deleteExpense('1');

      expect(notified, isTrue);
    });

    test('rethrows when repository throws', () async {
      when(() => expenseRepository.deleteExpense(any()))
          .thenThrow(DioException(requestOptions: RequestOptions()));

      expect(() => vm.deleteExpense('99'), throwsA(isA<DioException>()));
    });

    test('does nothing to viewState when state is not SuccessStateView', () async {
      when(() => expenseRepository.deleteExpense('1'))
          .thenAnswer((_) async {});

      await vm.deleteExpense('1');

      expect(vm.viewState, isA<InitialStateView>());
    });
  });

  group('addExpense', () {
    test('prepends new expense to list and increments total', () async {
      final existing = _expense(id: '1', value: 500);
      vm.viewState = SuccessStateView(_listWith([existing], amountTotal: 500));

      final newExpense = _expense(id: '2', value: 1000);
      when(
        () => expenseRepository.createExpense(
          value: 1000,
          description: 'New',
          category: ExpenseCategory.grocery,
        ),
      ).thenAnswer((_) async => newExpense);

      await vm.addExpense(
        value: 1000,
        description: 'New',
        category: ExpenseCategory.grocery,
      );

      final state = vm.viewState as SuccessStateView<ExpenseListModel>;
      expect(state.data.expenses.first.id, '2');
      expect(state.data.expenses.length, 2);
      expect(state.data.amountTotal, 1500);
      expect(state.data.pagination.total, 2);
    });

    test('notifies listeners after adding', () async {
      vm.viewState = SuccessStateView(_listWith([], amountTotal: 0));

      final newExpense = _expense(id: '1', value: 500);
      when(
        () => expenseRepository.createExpense(
          value: any(named: 'value'),
          description: any(named: 'description'),
          category: any(named: 'category'),
        ),
      ).thenAnswer((_) async => newExpense);

      var notified = false;
      vm.addListener(() => notified = true);

      await vm.addExpense(
        value: 500,
        description: 'Test',
        category: ExpenseCategory.grocery,
      );

      expect(notified, isTrue);
    });

    test('rethrows when repository throws', () async {
      when(
        () => expenseRepository.createExpense(
          value: any(named: 'value'),
          description: any(named: 'description'),
          category: any(named: 'category'),
        ),
      ).thenThrow(DioException(requestOptions: RequestOptions()));

      expect(
        () => vm.addExpense(
          value: 500,
          description: 'Test',
          category: ExpenseCategory.grocery,
        ),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('editExpense', () {
    final newDate = DateTime(2025, 6, 10);

    void mockUpdate(ExpenseModel returns) {
      when(
        () => expenseRepository.updateExpense(
          id: any(named: 'id'),
          value: any(named: 'value'),
          description: any(named: 'description'),
          category: any(named: 'category'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) async => returns);
    }

    test('replaces expense in list and recalculates amountTotal', () async {
      final e1 = _expense(id: '1', value: 1000);
      final e2 = _expense(id: '2', value: 500);
      vm.viewState = SuccessStateView(_listWith([e1, e2], amountTotal: 1500));

      final updated = _expense(id: '1', value: 800);
      mockUpdate(updated);

      await vm.editExpense(
        id: '1',
        value: 800,
        description: 'Updated',
        category: ExpenseCategory.grocery,
        date: newDate,
      );

      final state = vm.viewState as SuccessStateView<ExpenseListModel>;
      expect(state.data.expenses.firstWhere((e) => e.id == '1').value, 800);
      expect(state.data.amountTotal, 1300);
    });

    test('re-sorts list by date descending after edit', () async {
      final older = _expense(id: '1', value: 1000);
      final newer = ExpenseModel(
        id: '2', value: 500, description: 'Newer',
        category: ExpenseCategory.grocery,
        date: DateTime(2024, 6, 1),
        userId: 'user1',
      );
      vm.viewState = SuccessStateView(_listWith([newer, older], amountTotal: 1500));

      // Edit older expense to have the newest date
      final updated = ExpenseModel(
        id: '1', value: 1000, description: 'Updated',
        category: ExpenseCategory.grocery,
        date: DateTime(2025, 1, 1),
        userId: 'user1',
      );
      mockUpdate(updated);

      await vm.editExpense(
        id: '1',
        value: 1000,
        description: 'Updated',
        category: ExpenseCategory.grocery,
        date: DateTime(2025, 1, 1),
      );

      final state = vm.viewState as SuccessStateView<ExpenseListModel>;
      expect(state.data.expenses.first.id, '1');
    });

    test('notifies listeners after edit', () async {
      final e = _expense(id: '1', value: 1000);
      vm.viewState = SuccessStateView(_listWith([e], amountTotal: 1000));
      mockUpdate(_expense(id: '1', value: 900));

      var notified = false;
      vm.addListener(() => notified = true);

      await vm.editExpense(
        id: '1', value: 900, description: 'x',
        category: ExpenseCategory.grocery, date: newDate,
      );

      expect(notified, isTrue);
    });

    test('rethrows when repository throws', () async {
      when(
        () => expenseRepository.updateExpense(
          id: any(named: 'id'),
          value: any(named: 'value'),
          description: any(named: 'description'),
          category: any(named: 'category'),
          date: any(named: 'date'),
        ),
      ).thenThrow(DioException(requestOptions: RequestOptions()));

      expect(
        () => vm.editExpense(
          id: '1', value: 1000, description: 'x',
          category: ExpenseCategory.grocery, date: newDate,
        ),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('toggleCategory', () {
    test('adds category when not selected', () {
      vm.toggleCategory(ExpenseCategory.grocery);
      expect(vm.selectedCategories, contains(ExpenseCategory.grocery));
    });

    test('removes category when already selected', () {
      vm.toggleCategory(ExpenseCategory.grocery);
      vm.toggleCategory(ExpenseCategory.grocery);
      expect(vm.selectedCategories, isNot(contains(ExpenseCategory.grocery)));
    });

    test('can select multiple categories independently', () {
      vm.toggleCategory(ExpenseCategory.grocery);
      vm.toggleCategory(ExpenseCategory.health);
      expect(vm.selectedCategories,
          containsAll([ExpenseCategory.grocery, ExpenseCategory.health]));
    });

    test('selectedCategories is unmodifiable', () {
      expect(
        () => vm.selectedCategories.add(ExpenseCategory.grocery),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('notifies listeners on toggle', () {
      var count = 0;
      vm.addListener(() => count++);

      vm.toggleCategory(ExpenseCategory.grocery);
      vm.toggleCategory(ExpenseCategory.grocery);

      expect(count, 2);
    });
  });

  group('applyFilter', () {
    final expenses = [
      _expense(id: '1', category: ExpenseCategory.grocery),
      _expense(id: '2', category: ExpenseCategory.health),
      _expense(id: '3', category: ExpenseCategory.grocery),
    ];

    test('returns all expenses when no category is selected', () {
      expect(vm.applyFilter(expenses), expenses);
    });

    test('returns only expenses matching selected category', () {
      vm.toggleCategory(ExpenseCategory.grocery);

      final result = vm.applyFilter(expenses);

      expect(result.map((e) => e.id), containsAll(['1', '3']));
      expect(result.length, 2);
    });

    test('returns expenses matching any of the selected categories', () {
      vm.toggleCategory(ExpenseCategory.grocery);
      vm.toggleCategory(ExpenseCategory.health);

      final result = vm.applyFilter(expenses);

      expect(result.length, 3);
    });

    test('returns empty list when no expense matches selected category', () {
      vm.toggleCategory(ExpenseCategory.leisure);

      expect(vm.applyFilter(expenses), isEmpty);
    });
  });
}
