import 'package:anotagasto_app/core/http/http_client.dart';
import 'package:anotagasto_app/core/models/expense_category.dart';
import 'package:anotagasto_app/features/expenses/expense_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements HttpClient {}

Response<dynamic> _response(Map<String, dynamic> data, {int status = 200}) =>
    Response(
      requestOptions: RequestOptions(path: '/expenses'),
      statusCode: status,
      data: data,
    );

Map<String, dynamic> _expenseJson({
  String id = '1',
  int value = 1000,
  String description = 'Test',
  String category = 'grocery',
  String date = '2024-01-01T00:00:00.000Z',
  String userId = 'user1',
}) =>
    {
      'id': id,
      'value': value,
      'description': description,
      'category': category,
      'date': date,
      'user_id': userId,
    };

void main() {
  late MockHttpClient http;
  late ExpenseRepository repository;

  setUp(() {
    http = MockHttpClient();
    repository = ExpenseRepository(http);
  });

  group('getExpenseList', () {
    test('returns parsed ExpenseListModel on success', () async {
      when(() => http.get('/expenses')).thenAnswer(
        (_) async => _response({
          'data': [_expenseJson()],
          'amount_total': 1000,
          'pagination': {
            'page': 1,
            'page_size': 20,
            'total': 1,
            'total_pages': 1,
          },
        }),
      );

      final result = await repository.getExpenseList();

      expect(result.expenses.length, 1);
      expect(result.expenses.first.id, '1');
      expect(result.amountTotal, 1000);
    });

    test('returns empty list when data is empty', () async {
      when(() => http.get('/expenses')).thenAnswer(
        (_) async => _response({
          'data': [],
          'amount_total': 0,
          'pagination': {
            'page': 1,
            'page_size': 20,
            'total': 0,
            'total_pages': 1,
          },
        }),
      );

      final result = await repository.getExpenseList();

      expect(result.expenses, isEmpty);
      expect(result.amountTotal, 0);
    });

    test('calls GET /expenses', () async {
      when(() => http.get('/expenses')).thenAnswer(
        (_) async => _response({
          'data': [],
          'amount_total': 0,
          'pagination': <String, dynamic>{},
        }),
      );

      await repository.getExpenseList();

      verify(() => http.get('/expenses')).called(1);
    });

    test('rethrows DioException from http client', () {
      when(() => http.get('/expenses'))
          .thenThrow(DioException(requestOptions: RequestOptions()));

      expect(
        () => repository.getExpenseList(),
        throwsA(isA<DioException>()),
      );
    });
  });


  group('deleteExpense', () {
    test('calls DELETE /expenses/:id', () async {
      when(() => http.delete('/expenses/42')).thenAnswer((_) async =>
          Response(requestOptions: RequestOptions(), statusCode: 204));

      await repository.deleteExpense('42');

      verify(() => http.delete('/expenses/42')).called(1);
    });

    test('rethrows DioException from http client', () {
      when(() => http.delete(any()))
          .thenThrow(DioException(requestOptions: RequestOptions()));

      expect(
        () => repository.deleteExpense('42'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('createExpense', () {
    test('returns parsed ExpenseModel on success', () async {
      when(
        () => http.post('/expenses', bodyParams: any(named: 'bodyParams')),
      ).thenAnswer(
        (_) async => _response({'data': _expenseJson(id: '5', value: 2500)}),
      );

      final result = await repository.createExpense(
        value: 2500,
        description: 'Test',
        category: ExpenseCategory.grocery,
      );

      expect(result.id, '5');
      expect(result.value, 2500);
    });

    test('sends correct body params', () async {
      when(
        () => http.post('/expenses', bodyParams: any(named: 'bodyParams')),
      ).thenAnswer(
        (_) async => _response({'data': _expenseJson()}),
      );

      await repository.createExpense(
        value: 1000,
        description: 'Groceries',
        category: ExpenseCategory.grocery,
      );

      final captured = verify(
        () => http.post(
          '/expenses',
          bodyParams: captureAny(named: 'bodyParams'),
        ),
      ).captured;

      final body = captured.first as Map<String, dynamic>;
      expect(body['value'], 1000);
      expect(body['description'], 'Groceries');
      expect(body['category'], 'grocery');
      expect(body['date'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    });

    test('sends correct category api value', () async {
      when(
        () => http.post('/expenses', bodyParams: any(named: 'bodyParams')),
      ).thenAnswer(
        (_) async =>
            _response({'data': _expenseJson(category: 'eat_out')}),
      );

      await repository.createExpense(
        value: 500,
        description: 'Lunch',
        category: ExpenseCategory.eatOut,
      );

      final captured = verify(
        () => http.post(
          '/expenses',
          bodyParams: captureAny(named: 'bodyParams'),
        ),
      ).captured;

      expect(
        (captured.first as Map<String, dynamic>)['category'],
        'eat_out',
      );
    });

    test('rethrows DioException from http client', () {
      when(
        () => http.post(any(), bodyParams: any(named: 'bodyParams')),
      ).thenThrow(DioException(requestOptions: RequestOptions()));

      expect(
        () => repository.createExpense(
          value: 1000,
          description: 'Test',
          category: ExpenseCategory.grocery,
        ),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('updateExpense', () {
    final date = DateTime(2026, 1, 15);

    test('returns parsed ExpenseModel on success', () async {
      when(
        () => http.put('/expenses/1', bodyParams: any(named: 'bodyParams')),
      ).thenAnswer(
        (_) async => _response({'data': _expenseJson(id: '1', value: 3000)}),
      );

      final result = await repository.updateExpense(
        id: '1',
        value: 3000,
        description: 'Updated',
        category: ExpenseCategory.grocery,
        date: date,
      );

      expect(result.id, '1');
      expect(result.value, 3000);
    });

    test('sends params nested under expense key with correct date', () async {
      when(
        () => http.put('/expenses/1', bodyParams: any(named: 'bodyParams')),
      ).thenAnswer(
        (_) async => _response({'data': _expenseJson()}),
      );

      await repository.updateExpense(
        id: '1',
        value: 1000,
        description: 'Updated',
        category: ExpenseCategory.health,
        date: date,
      );

      final captured = verify(
        () => http.put(
          '/expenses/1',
          bodyParams: captureAny(named: 'bodyParams'),
        ),
      ).captured;

      final body = (captured.first as Map<String, dynamic>)['expense']
          as Map<String, dynamic>;
      expect(body['value'], 1000);
      expect(body['description'], 'Updated');
      expect(body['category'], 'health');
      expect(body['date'], '2026-01-15');
    });

    test('rethrows DioException from http client', () {
      when(
        () => http.put(any(), bodyParams: any(named: 'bodyParams')),
      ).thenThrow(DioException(requestOptions: RequestOptions()));

      expect(
        () => repository.updateExpense(
          id: '1',
          value: 1000,
          description: 'Test',
          category: ExpenseCategory.grocery,
          date: date,
        ),
        throwsA(isA<DioException>()),
      );
    });
  });
}
