import 'package:anotagasto_app/core/models/analytics_summary_model.dart';
import 'package:anotagasto_app/core/theme/app_colors.dart';
import 'package:anotagasto_app/core/utils/currency_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryDonutChart extends StatefulWidget {
  final AnalyticsSummaryModel summary;

  const CategoryDonutChart({super.key, required this.summary});

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final sections = widget.summary.byCategory
        .where((s) => s.total > 0)
        .toList();

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: sections.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value;
                final isTouched = i == _touchedIndex;
                return PieChartSectionData(
                  value: s.total.toDouble(),
                  color: AppColors.chartPalette[s.category.index],
                  radius: isTouched ? 72 : 60,
                  title: '',
                  badgeWidget: isTouched
                      ? _Badge(
                          label: s.category.label,
                          percentage: s.percentage,
                        )
                      : null,
                  badgePositionPercentageOffset: 1.3,
                );
              }).toList(),
              centerSpaceRadius: 60,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, PieTouchResponse? res) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        res?.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        res!.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                CurrencyFormatter.format(widget.summary.totalMonth),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final double percentage;

  const _Badge({required this.label, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label\n${percentage.toStringAsFixed(1)}%',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
