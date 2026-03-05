import 'package:anotagasto_app/core/http/http_client.dart';
import 'package:anotagasto_app/core/models/user_model.dart';

class ProfileRepository {
  final HttpClient _http;

  ProfileRepository(HttpClient http) : _http = http;

  Future<UserModel> getMe() async {
    final response = await _http.get("/users/me");
    return UserModel.fromJson(response.data);
  }
}
