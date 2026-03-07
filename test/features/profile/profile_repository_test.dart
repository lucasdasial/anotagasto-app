import 'package:anotagasto_app/core/http/http_client.dart';
import 'package:anotagasto_app/core/models/user_model.dart';
import 'package:anotagasto_app/features/profile/profile_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late MockHttpClient http;
  late ProfileRepository repository;

  setUp(() {
    http = MockHttpClient();
    repository = ProfileRepository(http);
  });

  Response<dynamic> successResponse(Map<String, dynamic> data) => Response(
        requestOptions: RequestOptions(path: '/users/me'),
        statusCode: 200,
        data: data,
      );

  group('getMe', () {
    test('returns UserModel with correct fields on success', () async {
      when(() => http.get(any())).thenAnswer(
        (_) async => successResponse({
          'data': {'id': 'abc-123', 'name': 'João Silva', 'phone': '11999999999'},
        }),
      );

      final result = await repository.getMe();

      expect(result, isA<UserModel>());
      expect(result.id, 'abc-123');
      expect(result.name, 'João Silva');
      expect(result.phone, '11999999999');
    });

    test('calls GET /users/me', () async {
      when(() => http.get(any())).thenAnswer(
        (_) async => successResponse({
          'data': {'id': 'abc-123', 'name': 'João', 'phone': '11999999999'},
        }),
      );

      await repository.getMe();

      verify(() => http.get('/users/me')).called(1);
    });

    test('parses response without data wrapper', () async {
      when(() => http.get(any())).thenAnswer(
        (_) async => successResponse(
          {'id': 'abc-123', 'name': 'João', 'phone': '11999999999'},
        ),
      );

      final result = await repository.getMe();

      expect(result.id, 'abc-123');
      expect(result.name, 'João');
    });

    test('returns empty strings for missing optional fields', () async {
      when(() => http.get(any())).thenAnswer(
        (_) async => successResponse({'data': {'id': 'abc-123'}}),
      );

      final result = await repository.getMe();

      expect(result.name, '');
      expect(result.phone, '');
    });

    test('rethrows DioException from http client', () {
      final exception = DioException(requestOptions: RequestOptions());
      when(() => http.get(any())).thenThrow(exception);

      expect(
        () => repository.getMe(),
        throwsA(isA<DioException>()),
      );
    });
  });
}
