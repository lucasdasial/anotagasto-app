import 'package:anotagasto/core/ui_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginState {
  UiState<String> uiState;
  bool rememberMe;

  LoginState({this.uiState = const Initial(), this.rememberMe = false});

  LoginState copyWith({UiState<String>? uiState, bool? rememberMe}) =>
      LoginState(
        uiState: uiState ?? this.uiState,
        rememberMe: rememberMe ?? this.rememberMe,
      );
}

class LoginViewModel extends Notifier<LoginState> {
  @override
  LoginState build() => LoginState();

  void setRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  Future<void> login() async {
    state = state.copyWith(uiState: Loading());

    await Future.delayed(Duration(seconds: 4));
    state = state.copyWith(uiState: Success("xpto_token"));
  }

  void logout() {
    state = state.copyWith(uiState: Initial());
  }
}

final loginViewModelProvider = NotifierProvider<LoginViewModel, LoginState>(
  LoginViewModel.new,
);
