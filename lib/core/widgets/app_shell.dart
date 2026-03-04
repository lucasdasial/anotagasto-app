import 'package:anotagasto_app/app/routes.dart';
import 'package:anotagasto_app/core/di/service_locator.dart';
import 'package:anotagasto_app/core/storage/storage_service.dart';
import 'package:anotagasto_app/core/utils/constants.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // StatefulWidget needed for initState auth guard redirect.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = di<StorageService>().getToken();
      if (token == null) {
        Navigator.of(context).pushReplacementNamed(Routes.login.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Constants.breakpointDesktop,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
