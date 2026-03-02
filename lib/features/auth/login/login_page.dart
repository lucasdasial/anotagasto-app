import 'package:anotagasto/core/ui_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginViewModel extends ChangeNotifier {
  UiState _state = Initial();
  UiState get state => _state;

  Future<void> login() async {
    _state = Loading();
    notifyListeners();

    await Future.delayed(Duration(seconds: 4));
    _state = Success("xpto_token");
    notifyListeners();
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AnotaGasto")),
      body: ChangeNotifierProvider<LoginViewModel>(
        create: (_) => LoginViewModel(),
        child: Consumer<LoginViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.state is Loading) {
              return Center(child: CircularProgressIndicator());
            }

            if (viewModel.state is Success) {
              return Center(child: Text("Logado!"));
            }

            return Center(
              child: FilledButton(
                onPressed: viewModel.login,
                child: Text("Entrar"),
              ),
            );
          },
        ),
      ),
    );
  }
}
