import 'package:anotagasto_app/core/models/analytics_summary_model.dart';
import 'package:anotagasto_app/core/theme/app_colors.dart';
import 'package:anotagasto_app/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

class CategoryLegend extends StatelessWidget {
  final List<CategoryStat> stats;

  const CategoryLegend({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stats
          .where((s) => s.total > 0)
          .map((s) => _LegendRow(stat: s))
          .toList(),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final CategoryStat stat;

  const _LegendRow({required this.stat});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.chartPalette[stat.category.index];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Icon(stat.category.icon, size: 16, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              stat.category.label,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${stat.percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            CurrencyFormatter.format(stat.total),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
