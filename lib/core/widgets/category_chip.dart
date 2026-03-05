import 'package:flutter/material.dart';

import '../models/expense_category.dart';
import '../theme/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final ExpenseCategory category;
  final bool selected;
  final VoidCallback? onTap;
  final bool compact;

  const CategoryChip({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final index = ExpenseCategory.values.indexOf(category);
    final color = AppColors.chartPalette[index % AppColors.chartPalette.length];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.surfaceDim,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: compact ? 14 : 16,
              color: selected ? color : AppColors.secondary,
            ),
            if (!compact) ...[
              const SizedBox(width: 6),
              Text(
                category.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? color : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
