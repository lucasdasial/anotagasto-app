import 'package:anotagasto_app/core/theme/app_theme.dart';
import 'package:anotagasto_app/features/auth/login/login_page.dart';
import 'package:anotagasto_app/features/auth/widgets/auth_shell.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anotagasto',
      theme: AppTheme.light,
      initialRoute: '/login',
      routes: {'/login': (context) => const AuthShell(child: LoginPage())},
    );
  }
}
