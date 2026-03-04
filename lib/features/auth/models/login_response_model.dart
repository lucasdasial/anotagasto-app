class LoginResponseModel {
  String token;
  LoginResponseModel({required this.token});

  factory LoginResponseModel.fromMap(Map<String, dynamic> map) {
    try {
      return LoginResponseModel(token: map['token'] as String);
    } catch (e) {
      throw Exception("Error durante a serialização dos dados");
    }
  }
}
