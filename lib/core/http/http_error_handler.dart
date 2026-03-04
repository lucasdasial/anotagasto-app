import 'package:dio/dio.dart';

class HttpErrorHandler extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;

    if (err.type == DioExceptionType.connectionTimeout) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          message: "Tempo de conexão esgotado",
        ),
      );
    }

    if (status == 401) {
      err = err.copyWith(message: "Não autorizado");
    } else if (status == 403) {
      err = err.copyWith(message: "Acesso proibido");
    } else if (status == 404) {
      err = err.copyWith(message: "Recurso não encontrado");
    } else if (status != null && status >= 500) {
      err = err.copyWith(message: "Erro no servidor");
    } else {
      err = err.copyWith(message: "Erro desconhecido");
    }

    return handler.next(err);
  }
}
