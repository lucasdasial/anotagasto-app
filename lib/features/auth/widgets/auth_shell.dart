import 'package:anotagasto_app/core/theme/app_colors.dart';
import 'package:anotagasto_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _AuthHeader(),
                  const SizedBox(height: 40),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.edit_note,
            color: AppColors.onAccent,
            size: 26,
          ),
        ),
        const SizedBox(height: 20),
        const Text('AnotaGasto', style: AppTextStyles.headlineLarge),
        const SizedBox(height: 4),
        const Text(
          'Controle seus gastos com simplicidade',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
