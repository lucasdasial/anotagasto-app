import 'package:anotagasto_app/core/http/http_client.dart';
import 'package:anotagasto_app/features/auth/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late MockHttpClient http;
  late AuthRepository repository;

  setUp(() {
    http = MockHttpClient();
    repository = AuthRepository(http);
  });

  Response<dynamic> successResponse(Map<String, dynamic> data) => Response(
        requestOptions: RequestOptions(path: '/auth'),
        statusCode: 200,
        data: data,
      );

  group('login', () {
    test('returns LoginResponseModel with token on success', () async {
      when(() => http.post(any(), bodyParams: any(named: 'bodyParams')))
          .thenAnswer((_) async => successResponse({'token': 'jwt_token'}));

      final result = await repository.login('11999999999', 'password123');

      expect(result.token, 'jwt_token');
    });

    test('sends phone_number and password in request body', () async {
      when(() => http.post(any(), bodyParams: any(named: 'bodyParams')))
          .thenAnswer((_) async => successResponse({'token': 'jwt_token'}));

      await repository.login('11999999999', 'password123');

      verify(
        () => http.post(
          '/auth',
          bodyParams: {
            'phone_number': '11999999999',
            'password': 'password123',
          },
        ),
      ).called(1);
    });

    test('rethrows DioException from http client', () async {
      final exception = DioException(requestOptions: RequestOptions());
      when(() => http.post(any(), bodyParams: any(named: 'bodyParams')))
          .thenThrow(exception);

      expect(
        () => repository.login('11999999999', 'wrongpassword'),
        throwsA(isA<DioException>()),
      );
    });

    test('throws when response body is missing token field', () async {
      when(() => http.post(any(), bodyParams: any(named: 'bodyParams')))
          .thenAnswer((_) async => successResponse({'unexpected': 'field'}));

      expect(
        () => repository.login('11999999999', 'password123'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
