import 'package:anotagasto_app/core/config/envs.dart';
import 'package:anotagasto_app/core/http/http_error_handler.dart';
import 'package:dio/dio.dart';

class HttpClient {
  late final Dio _dio;

  HttpClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "${Envs.apiBaseUrl}/api",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(HttpErrorHandler());
  }

  Future<Response> get(String path) => _dio.get(path);
  Future<Response> post(String path, {Object? bodyParams}) =>
      _dio.post(path, data: bodyParams);
}
