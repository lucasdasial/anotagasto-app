import 'package:anotagasto_app/core/storage/storage_service.dart';
import 'package:anotagasto_app/features/auth/repositories/auth_repository.dart';
import 'package:anotagasto_app/features/auth/views/login_view_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final StorageService _storage;

  LoginViewState viewState = InitialStateLogin();

  LoginViewModel({
    required AuthRepository authRepository,
    required StorageService storage,
  }) : _authRepository = authRepository,
       _storage = storage;

  Future<void> onSubmit(String phone, String password) async {
    viewState = LoadingStateLogin();
    notifyListeners();

    try {
      final response = await _authRepository.login(phone, password);
      await _storage.setToken(response.token);
      viewState = SuccessStateLogin(response);
    } on DioException catch (e) {
      viewState = ErrorStateLogin(e.response?.data["error"] ?? e.message);
    }

    notifyListeners();
  }

  void resetViewState() {
    viewState = InitialStateLogin();
  }
}
