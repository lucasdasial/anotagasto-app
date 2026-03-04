import 'package:anotagasto_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppSnackBar {
  static void error(BuildContext context, String message) {
    _show(context, message: message, backgroundColor: AppColors.error);
  }

  static void success(BuildContext context, String message) {
    _show(context, message: message, backgroundColor: AppColors.success);
  }

  static void info(BuildContext context, String message) {
    _show(context, message: message, backgroundColor: AppColors.primary);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        width: 400,
      ),
    );
  }
}
