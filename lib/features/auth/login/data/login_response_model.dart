import 'dart:convert';

class LoginResponseModel {
  String token;
  LoginResponseModel({required this.token});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'token': token};
  }

  factory LoginResponseModel.fromMap(Map<String, dynamic> map) {
    try {
      return LoginResponseModel(token: map['token'] as String);
    } catch (e) {
      throw Exception(
        "Error durante a serialização dos dados: ${e.toString()}",
      );
    }
  }

  String toJson() => json.encode(toMap());
}
