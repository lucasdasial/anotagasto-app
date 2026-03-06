// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:anotagasto_app/core/http/http_client.dart';
import 'package:anotagasto_app/features/auth/models/login_response_model.dart';

class AuthRepository {
  late final HttpClient _http;

  AuthRepository(HttpClient http) {
    _http = http;
  }

  Future<LoginResponseModel> login(String login, String password) async {
    try {
      final response = await _http.post(
        "/auth",
        bodyParams: {"phone_number": login, "password": password},
      );
      return LoginResponseModel.fromMap(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String name, String phone, String password) async {
    try {
      await _http.post(
        "/register",
        bodyParams: {"name": name, "phone_number": phone, "password": password},
      );
    } catch (e) {
      rethrow;
    }
  }
}
