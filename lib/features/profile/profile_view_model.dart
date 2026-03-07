import 'package:anotagasto_app/core/storage/storage_service.dart';
import 'package:anotagasto_app/core/view_state.dart';
import 'package:anotagasto_app/features/profile/profile_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;
  final StorageService _storage;

  ViewState viewState = InitialStateView();
  bool loggedOut = false;

  ProfileViewModel({
    required ProfileRepository repository,
    required StorageService storage,
  }) : _repository = repository,
       _storage = storage;

  Future<void> loadUser() async {
    viewState = LoadingStateView();
    notifyListeners();

    try {
      final user = await _repository.getMe();
      viewState = SuccessStateView(user);
    } on DioException catch (e) {
      viewState = ErrorStateView(e.response?.data['error'] ?? e.message);
    } catch (e, stack) {
      debugPrint('ProfileViewModel.loadUser: $e\n$stack');
      viewState = ErrorStateView(
        'Ocorreu um erro inesperado. Tente novamente.',
      );
    }

    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.clearAll();
    loggedOut = true;
    notifyListeners();
  }
}
