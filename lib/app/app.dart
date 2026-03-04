import 'package:anotagasto_app/core/di/service_locator.dart';
import 'package:anotagasto_app/core/storage/storage_service.dart';
import 'package:anotagasto_app/core/theme/app_theme.dart';
import 'package:anotagasto_app/features/auth/repositories/auth_repository.dart';
import 'package:anotagasto_app/features/auth/views/home/home_view.dart';
import 'package:anotagasto_app/features/auth/views/login/login_view.dart';
import 'package:anotagasto_app/features/auth/views/login/login_view_model.dart';
import 'package:anotagasto_app/features/auth/widgets/auth_shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnotaGasto',
      theme: AppTheme.light,
      initialRoute: '/login',
      routes: {
        '/login': (context) => ChangeNotifierProvider(
          create: (_) => LoginViewModel(
            authRepository: di<AuthRepository>(),
            storage: di<StorageService>(),
          ),
          child: AuthShell(child: LoginView()),
        ),
        "/home": (context) => HomeView(),
      },
    );
  }
}
