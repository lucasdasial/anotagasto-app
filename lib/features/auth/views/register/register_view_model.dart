import 'package:anotagasto_app/core/storage/storage_service.dart';
import 'package:anotagasto_app/features/auth/repositories/auth_repository.dart';
import 'package:anotagasto_app/core/view_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final StorageService _storage;

  ViewState viewState = InitialStateView();

  RegisterViewModel({
    required AuthRepository authRepository,
    required StorageService storage,
  }) : _authRepository = authRepository,
       _storage = storage;

  Future<void> onSubmit(String name, String phone, String password) async {
    viewState = LoadingStateView();
    notifyListeners();

    try {
      await _authRepository.register(name, phone, password);
      final response = await _authRepository.login(phone, password);
      await _storage.setToken(response.token);
      viewState = SuccessStateView(response);
    } on DioException catch (e) {
      viewState = ErrorStateView(_extractError(e));
    } catch (e, stack) {
      debugPrint('RegisterViewModel.onSubmit: $e\n$stack');
      viewState = ErrorStateView('Ocorreu um erro inesperado. Tente novamente.');
    }

    notifyListeners();
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      if (data['error'] != null) return data['error'] as String;
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map<String, dynamic>;
        if (errors['phone_number'] != null) return 'Telefone já cadastrado';
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
    }
    return e.message ?? 'Ocorreu um erro. Tente novamente.';
  }

  void resetViewState() {
    viewState = InitialStateView();
  }
}
