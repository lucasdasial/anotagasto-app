import 'package:anotagasto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // final TextTheme textTheme;

  // AppTheme(this.textTheme);

  static ThemeData get() {
    final colorScheme = AppColorSchemes.lightScheme();

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      // textTheme: textTheme.apply(
      //   bodyColor: colorScheme.onSurface,
      //   displayColor: colorScheme.onSurface,
      // ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
    );
  }
}
