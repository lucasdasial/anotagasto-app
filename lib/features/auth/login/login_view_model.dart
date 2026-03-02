import 'package:anotagasto/core/ui_state.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  UiState<String> _state = Initial();
  UiState<String> get state => _state;

  Future<void> login() async {
    _state = Loading();
    notifyListeners();

    await Future.delayed(Duration(seconds: 4));
    _state = Success("xpto_token");
    notifyListeners();
  }
}
