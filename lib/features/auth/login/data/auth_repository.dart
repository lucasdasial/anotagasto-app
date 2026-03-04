// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:anotagasto_app/core/http/http_client.dart';
import 'package:anotagasto_app/features/auth/login/data/login_response_model.dart';

class AuthRepository {
  HttpClient http;

  AuthRepository({required this.http});

  Future<LoginResponseModel> login(String login, String password) async {
    final response = await http.post(
      "/auth",
      bodyParams: {"phone_number": login, "password": password},
    );

    return LoginResponseModel.fromMap(response.data);
  }
}
