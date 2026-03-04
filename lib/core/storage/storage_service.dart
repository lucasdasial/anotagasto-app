// coverage:ignore-file
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  String? getToken() => _prefs.getString(_tokenKey);

  Future<void> setToken(String token) => _prefs.setString(_tokenKey, token);

  Future<void> clearToken() => _prefs.remove(_tokenKey);

  String? getUserId() => _prefs.getString(_userIdKey);

  Future<void> setUserId(String id) => _prefs.setString(_userIdKey, id);

  Future<void> clearUserId() => _prefs.remove(_userIdKey);

  Future<void> clearAll() async {
    await Future.wait([clearToken(), clearUserId()]);
  }
}
