import 'package:anotagasto_app/core/http/http_error_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturingErrorHandler extends Fake implements ErrorInterceptorHandler {
  DioException? rejected;
  DioException? nexted;

  @override
  void reject(DioException err) => rejected = err;

  @override
  void next(DioException err) => nexted = err;
}

void main() {
  late HttpErrorHandler handler;
  late _CapturingErrorHandler capture;

  setUp(() {
    handler = HttpErrorHandler();
    capture = _CapturingErrorHandler();
  });

  DioException buildError({
    DioExceptionType type = DioExceptionType.badResponse,
    int? statusCode,
    dynamic data,
  }) {
    return DioException(
      requestOptions: RequestOptions(path: '/test'),
      type: type,
      response: statusCode != null
          ? Response(
              requestOptions: RequestOptions(path: '/test'),
              statusCode: statusCode,
              data: data,
            )
          : null,
    );
  }

  group('timeout errors', () {
    test('rejects connectionTimeout with human-readable message', () {
      handler.onError(
        buildError(type: DioExceptionType.connectionTimeout),
        capture,
      );

      expect(capture.rejected?.message, 'Tempo de conexão esgotado');
    });

    test('rejects receiveTimeout with human-readable message', () {
      handler.onError(
        buildError(type: DioExceptionType.receiveTimeout),
        capture,
      );

      expect(capture.rejected?.message, 'Tempo de conexão esgotado');
    });

    test('rejects sendTimeout with human-readable message', () {
      handler.onError(
        buildError(type: DioExceptionType.sendTimeout),
        capture,
      );

      expect(capture.rejected?.message, 'Tempo de conexão esgotado');
    });
  });

  group('connection errors', () {
    test('rejects connectionError with no-internet message', () {
      handler.onError(
        buildError(type: DioExceptionType.connectionError),
        capture,
      );

      expect(capture.rejected?.message, 'Sem conexão com a internet');
    });

    test('rejects unknown type with no-internet message', () {
      handler.onError(
        buildError(type: DioExceptionType.unknown),
        capture,
      );

      expect(capture.rejected?.message, 'Sem conexão com a internet');
    });
  });

  group('5xx server errors', () {
    test('rejects 500 with server error message', () {
      handler.onError(buildError(statusCode: 500), capture);

      expect(capture.rejected?.message, 'Erro no servidor');
    });

    test('rejects 503 with server error message', () {
      handler.onError(buildError(statusCode: 503), capture);

      expect(capture.rejected?.message, 'Erro no servidor');
    });
  });

  group('4xx client errors', () {
    test('passes 401 through with body intact', () {
      final err = buildError(
        statusCode: 401,
        data: {'error': 'Unauthorized'},
      );

      handler.onError(err, capture);

      expect(capture.nexted, isNotNull);
      expect(capture.rejected, isNull);
      expect(capture.nexted!.response!.data['error'], 'Unauthorized');
    });

    test('passes 422 through with body intact', () {
      final err = buildError(
        statusCode: 422,
        data: {'error': 'Invalid credentials'},
      );

      handler.onError(err, capture);

      expect(capture.nexted, isNotNull);
      expect(capture.rejected, isNull);
      expect(capture.nexted!.response!.data['error'], 'Invalid credentials');
    });

    test('passes 404 through to handler', () {
      handler.onError(buildError(statusCode: 404), capture);

      expect(capture.nexted, isNotNull);
      expect(capture.rejected, isNull);
    });
  });
}
