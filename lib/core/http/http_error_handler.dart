import 'package:dio/dio.dart';

class HttpErrorHandler extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return handler.reject(
        err.copyWith(message: 'Tempo de conexão esgotado'),
      );
    }

    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      return handler.reject(
        err.copyWith(message: 'Sem conexão com a internet'),
      );
    }

    if (status != null && status >= 500) {
      return handler.reject(
        err.copyWith(message: 'Erro no servidor'),
      );
    }

    // 4xx: passa com o body intacto para o ViewModel ler e.response?.data["error"]
    handler.next(err);
  }
}
