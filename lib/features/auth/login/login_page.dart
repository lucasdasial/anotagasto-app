import 'package:anotagasto/core/ui_state.dart';
import 'package:anotagasto/features/auth/login/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            return Center(
              child: switch (viewModel.state) {
                Initial() => FilledButton(
                  onPressed: viewModel.login,
                  child: Text("Entrar"),
                ),
                Loading() => CircularProgressIndicator(),
                Success(:final data) => Text("Logado: $data"),
                Error(:final message) => Text("Erro: $message"),
                _ => SizedBox.shrink(),
              },
            );
          },
        ),
      ),
    );
  }
}
