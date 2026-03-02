import 'package:anotagasto/core/theme/app_theme.dart';
import 'package:anotagasto/features/auth/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Anota Gasto',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.get(),
        home: const LoginPage(),
      ),
    );
  }
}
