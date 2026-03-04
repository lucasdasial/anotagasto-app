import 'package:anotagasto_app/core/storage/storage_service.dart';
import 'package:anotagasto_app/features/auth/repositories/auth_repository.dart';
import 'package:anotagasto_app/core/view_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final StorageService _storage;

  ViewState viewState = InitialStateView();

  LoginViewModel({
    required AuthRepository authRepository,
    required StorageService storage,
  }) : _authRepository = authRepository,
       _storage = storage;

  Future<void> onSubmit(String phone, String password) async {
    viewState = LoadingStateView();
    notifyListeners();

    try {
      final response = await _authRepository.login(phone, password);
      await _storage.setToken(response.token);
      viewState = SuccessStateView(response);
    } on DioException catch (e) {
      viewState = ErrorStateView(e.response?.data["error"] ?? e.message);
    } catch (e, stack) {
      debugPrint('🐛 LoginViewModel.onSubmit: $e\n$stack');
      viewState = ErrorStateView(
        'Ocorreu um erro inesperado. Tente novamente.',
      );
    }

    notifyListeners();
  }

  void resetViewState() {
    viewState = InitialStateView();
  }
}
