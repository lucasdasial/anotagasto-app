import 'dart:async';
import 'dart:developer';

import 'package:anotagasto_app/app/app.dart';
import 'package:anotagasto_app/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await setupServiceLocator();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    inspect(details);
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
