import 'package:anotagasto_app/core/models/expense_model.dart';
import 'package:anotagasto_app/core/models/pagination_model.dart';
import 'package:anotagasto_app/core/view_state.dart';
import 'package:anotagasto_app/features/expenses/expense_repository.dart';
import 'package:anotagasto_app/features/expenses/expenses_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

void main() {
  late MockExpenseRepository expenseRepository;
  late ExpensesViewModel vm;

  final mockExpenseList = ExpenseListModel(
    expenses: [],
    amountTotal: 0,
    pagination: PaginationModel(
      page: 1,
      pageSize: 20,
      total: 0,
      totalPages: 1,
    ),
  );

  setUp(() {
    expenseRepository = MockExpenseRepository();
    vm = ExpensesViewModel(expenseRepository);
  });

  tearDown(() => vm.dispose());

  group("Expenses_view_model", () {
    test('Should starts with InitialStateView', () {
      expect(vm.viewState, isA<InitialStateView>());
    });

    test("Should pass by LoadingStateView before SuccessStateView", () async {
      when(() => expenseRepository.getExpenseList())
          .thenAnswer((_) async => mockExpenseList);

      final states = <ViewState>[];
      vm.addListener(() => states.add(vm.viewState));

      await vm.getExpenseList();

      expect(states, [isA<LoadingStateView>(), isA<SuccessStateView>()]);
    });

    test("Should return expense list successfully", () async {
      when(() => expenseRepository.getExpenseList())
          .thenAnswer((_) async => mockExpenseList);

      await vm.getExpenseList();

      final state = vm.viewState as SuccessStateView<ExpenseListModel>;
      expect(state.data, mockExpenseList);
    });

    test("Should return DioException error", () async {
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

    test("Should return Unexpected error", () async {
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
}
