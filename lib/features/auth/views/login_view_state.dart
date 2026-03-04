import 'package:anotagasto_app/features/auth/models/login_response_model.dart';

sealed class LoginViewState {}

class InitialStateLogin extends LoginViewState {}

class LoadingStateLogin extends LoginViewState {}

class ErrorStateLogin extends LoginViewState {
  final String message;
  ErrorStateLogin(this.message);
}

class SuccessStateLogin extends LoginViewState {
  final LoginResponseModel data;
  SuccessStateLogin(this.data);
}
