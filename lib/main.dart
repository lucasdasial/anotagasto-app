import 'dart:async';
import 'dart:developer';

import 'package:anotagasto_app/app/app.dart';
import 'package:anotagasto_app/core/di/service_locator.dart';
import 'package:anotagasto_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await setupServiceLocator();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrintStack(
      stackTrace: details.stack,
      label: "[Crash no app][STACKTRACE =>]",
    );
    inspect(details);

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: AppColors.warning,
        content: Text("Ocorreu um erro no app. Tente novamente mais tarde."),
      ),
    );
  };

  runZonedGuarded(
    () {
      runApp(const App());
    },
    (error, stack) {
      inspect(error);
      inspect(stack);
      SnackBar(content: Text(error.toString()));
    },
  );
}
