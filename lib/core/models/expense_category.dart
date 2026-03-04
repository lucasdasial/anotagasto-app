import 'package:flutter/material.dart';

enum ExpenseCategory {
  grocery,
  eatOut,
  cleaningProducts,
  health,
  medicines,
  housing,
  subscriptions,
  transportPublic,
  transportApps,
  education,
  shopping,
  debts,
  leisure,
  beauty,
  clothing,
  uncategorized;

  String toApi() {
    return switch (this) {
      ExpenseCategory.grocery => 'grocery',
      ExpenseCategory.eatOut => 'eat_out',
      ExpenseCategory.cleaningProducts => 'cleaning_products',
      ExpenseCategory.health => 'health',
      ExpenseCategory.medicines => 'medicines',
      ExpenseCategory.housing => 'housing',
      ExpenseCategory.subscriptions => 'subscriptions',
      ExpenseCategory.transportPublic => 'transport_public',
      ExpenseCategory.transportApps => 'transport_apps',
      ExpenseCategory.education => 'education',
      ExpenseCategory.shopping => 'shopping',
      ExpenseCategory.debts => 'debts',
      ExpenseCategory.leisure => 'leisure',
      ExpenseCategory.beauty => 'beauty',
      ExpenseCategory.clothing => 'clothing',
      ExpenseCategory.uncategorized => 'uncategorized',
    };
  }

  static ExpenseCategory fromApi(String value) {
    return switch (value) {
      'grocery' => ExpenseCategory.grocery,
      'eat_out' => ExpenseCategory.eatOut,
      'cleaning_products' => ExpenseCategory.cleaningProducts,
      'health' => ExpenseCategory.health,
      'medicines' => ExpenseCategory.medicines,
      'housing' => ExpenseCategory.housing,
      'subscriptions' => ExpenseCategory.subscriptions,
      'transport_public' => ExpenseCategory.transportPublic,
      'transport_apps' => ExpenseCategory.transportApps,
      'education' => ExpenseCategory.education,
      'shopping' => ExpenseCategory.shopping,
      'debts' => ExpenseCategory.debts,
      'leisure' => ExpenseCategory.leisure,
      'beauty' => ExpenseCategory.beauty,
      'clothing' => ExpenseCategory.clothing,
      _ => ExpenseCategory.uncategorized,
    };
  }

  String get label {
    return switch (this) {
      ExpenseCategory.grocery => 'Mercado',
      ExpenseCategory.eatOut => 'Comer fora',
      ExpenseCategory.cleaningProducts => 'Limpeza',
      ExpenseCategory.health => 'Saúde',
      ExpenseCategory.medicines => 'Remédios',
      ExpenseCategory.housing => 'Moradia',
      ExpenseCategory.subscriptions => 'Assinaturas',
      ExpenseCategory.transportPublic => 'Transporte público',
      ExpenseCategory.transportApps => 'Apps de transporte',
      ExpenseCategory.education => 'Educação',
      ExpenseCategory.shopping => 'Compras',
      ExpenseCategory.debts => 'Dívidas',
      ExpenseCategory.leisure => 'Lazer',
      ExpenseCategory.beauty => 'Beleza',
      ExpenseCategory.clothing => 'Roupas',
      ExpenseCategory.uncategorized => 'Sem categoria',
    };
  }

  IconData get icon {
    return switch (this) {
      ExpenseCategory.grocery => Icons.shopping_basket_outlined,
      ExpenseCategory.eatOut => Icons.restaurant_outlined,
      ExpenseCategory.cleaningProducts => Icons.cleaning_services_outlined,
      ExpenseCategory.health => Icons.favorite_outline,
      ExpenseCategory.medicines => Icons.medication_outlined,
      ExpenseCategory.housing => Icons.home_outlined,
      ExpenseCategory.subscriptions => Icons.subscriptions_outlined,
      ExpenseCategory.transportPublic => Icons.directions_bus_outlined,
      ExpenseCategory.transportApps => Icons.local_taxi_outlined,
      ExpenseCategory.education => Icons.school_outlined,
      ExpenseCategory.shopping => Icons.shopping_bag_outlined,
      ExpenseCategory.debts => Icons.credit_card_outlined,
      ExpenseCategory.leisure => Icons.sports_esports_outlined,
      ExpenseCategory.beauty => Icons.face_outlined,
      ExpenseCategory.clothing => Icons.checkroom_outlined,
      ExpenseCategory.uncategorized => Icons.help_outline,
    };
  }
}
