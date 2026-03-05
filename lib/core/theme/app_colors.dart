import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF1F1F1F);
  static const secondary = Color.fromARGB(255, 147, 202, 107);
  // static const secondary = Color.fromARGB(255, 107, 164, 202);
  static const background = Color(0xFFf4f4f4);

  // --- Backgrounds ---
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceDim = Color(0xFFEEEEEE);

  // --- Content ---
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color onSurfaceVariant = Color(0xFF6B6B6B);
  static const Color onSurfaceMuted = Color(0xFFAAAAAA);

  // --- Accent ---
  static const Color accent = primary;
  static const Color accentLight = Color(0xFF3A3A3A);
  static const Color onAccent = Color(0xFFFFFFFF);

  // --- Semantic ---
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE65100);
  static const Color error = Color.fromARGB(255, 182, 25, 25);

  // --- Chart palette (one color per category, ordered like ExpenseCategory enum) ---
  // grocery, eat_out, cleaning_products, health, medicines, housing,
  // subscriptions, transport_public, transport_apps, education,
  // shopping, debts, leisure, beauty, clothing, delivery, vehicle, uncategorized
  static const List<Color> chartPalette = [
    Color(0xFF4CAF50), // grocery — green
    Color(0xFFFF7043), // eat_out — deep orange
    Color(0xFF29B6F6), // cleaning_products — light blue
    Color(0xFFAB47BC), // health — purple
    Color(0xFFEC407A), // medicines — pink
    Color(0xFF5C6BC0), // housing — indigo
    Color(0xFF26C6DA), // subscriptions — cyan
    Color(0xFF66BB6A), // transport_public — light green
    Color(0xFFFFCA28), // transport_apps — amber
    Color(0xFF42A5F5), // education — blue
    Color(0xFFFF7043), // shopping — deep orange (variant)
    Color(0xFFEF5350), // debts — red
    Color(0xFFFFEE58), // leisure — yellow
    Color(0xFFF06292), // beauty — light pink
    Color(0xFF26A69A), // clothing — teal
    Color(0xFFFF8A65), // delivery — orange
    Color(0xFF78909C), // vehicle — blue grey
    Color(0xFFBDBDBD), // uncategorized — grey
  ];
}
