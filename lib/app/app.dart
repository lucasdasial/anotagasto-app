import 'package:anotagasto_app/app/routes.dart';
import 'package:anotagasto_app/core/di/service_locator.dart';
import 'package:anotagasto_app/core/storage/storage_service.dart';
import 'package:anotagasto_app/core/theme/app_theme.dart';
import 'package:anotagasto_app/core/widgets/app_shell.dart';
import 'package:anotagasto_app/features/auth/repositories/auth_repository.dart';
import 'package:anotagasto_app/features/auth/views/login/login_view.dart';
import 'package:anotagasto_app/features/auth/views/login/login_view_model.dart';
import 'package:anotagasto_app/features/auth/widgets/auth_shell.dart';
import 'package:anotagasto_app/features/expenses/expense_repository.dart';
import 'package:anotagasto_app/features/expenses/expenses_view.dart';
import 'package:anotagasto_app/features/expenses/expenses_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'AnotaGasto',
      theme: AppTheme.light,
      initialRoute: Routes.login.name,
      routes: {
        Routes.login.name: (context) => ChangeNotifierProvider(
          create: (_) => LoginViewModel(
            authRepository: di<AuthRepository>(),
            storage: di<StorageService>(),
          ),
          child: AuthShell(child: LoginView()),
        ),
        Routes.expenseList.name: (context) => ChangeNotifierProvider(
          create: (_) => ExpensesViewModel(di<ExpenseRepository>()),
          child: AppShell(child: const ExpensesView()),
        ),
      },
    );
  }
}
