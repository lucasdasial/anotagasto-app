import 'package:anotagasto/core/ui_state.dart';
import 'package:anotagasto/features/auth/login/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(loginViewModelProvider.select((s) => s.uiState));
    final rememberMe = ref.watch(
      loginViewModelProvider.select((s) => s.rememberMe),
    );
    final vm = ref.read(loginViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text("AnotaGasto")),
      body: Center(
        child: switch (uiState) {
          Initial() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(onPressed: vm.login, child: Text("Entrar")),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (value) => vm.setRememberMe(value ?? false),
                  ),
                  Text("Lembrar-me"),
                ],
              ),
            ],
          ),
          Loading() => CircularProgressIndicator(),
          Success(:final data) => Column(
            mainAxisAlignment: .center,
            children: [
              Text("Logado: $data"),
              OutlinedButton(onPressed: vm.logout, child: Text("Sair")),
            ],
          ),
          Error(:final message) => Text("Erro: $message"),
          _ => SizedBox.shrink(),
        },
      ),
    );
  }
}
