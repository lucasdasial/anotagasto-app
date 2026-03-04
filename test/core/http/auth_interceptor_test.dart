import 'package:anotagasto_app/core/http/auth_interceptor.dart';
import 'package:anotagasto_app/core/storage/storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStorageService extends Mock implements StorageService {}

class _FakeRequestInterceptorHandler extends Fake
    implements RequestInterceptorHandler {
  RequestOptions? passedOptions;

  @override
  void next(RequestOptions options) {
    passedOptions = options;
  }
}

void main() {
  late MockStorageService storage;
  late AuthInterceptor interceptor;
  late _FakeRequestInterceptorHandler handler;

  setUp(() {
    storage = MockStorageService();
    interceptor = AuthInterceptor(storage);
    handler = _FakeRequestInterceptorHandler();
  });

  RequestOptions buildOptions() => RequestOptions(path: '/test');

  group('AuthInterceptor', () {
    test('adds Bearer token header when token is available', () {
      when(() => storage.getToken()).thenReturn('my_jwt_token');

      interceptor.onRequest(buildOptions(), handler);

      expect(
        handler.passedOptions!.headers['Authorization'],
        'Bearer my_jwt_token',
      );
    });

    test('does not add Authorization header when token is null', () {
      when(() => storage.getToken()).thenReturn(null);

      interceptor.onRequest(buildOptions(), handler);

      expect(handler.passedOptions!.headers.containsKey('Authorization'), false);
    });

    test('always calls handler.next', () {
      when(() => storage.getToken()).thenReturn(null);

      interceptor.onRequest(buildOptions(), handler);

      expect(handler.passedOptions, isNotNull);
    });
  });
}
