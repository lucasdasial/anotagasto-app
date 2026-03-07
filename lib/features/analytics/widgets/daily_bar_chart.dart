import 'dart:math';

import 'package:anotagasto_app/core/models/analytics_daily_model.dart';
import 'package:anotagasto_app/core/theme/app_colors.dart';
import 'package:anotagasto_app/core/utils/currency_formatter.dart';
import 'package:anotagasto_app/core/utils/date_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DailyBarChart extends StatelessWidget {
  final AnalyticsDailyModel daily;
  final DateTime month;

  const DailyBarChart({super.key, required this.daily, required this.month});

  static const _weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  String _weekdayLabel(int day) {
    return _weekdays[DateTime(month.year, month.month, day).weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final dayMap = {for (final s in daily.daily) s.day: s.total};

    // Last 7 days of the month (capped at today for the current month).
    final now = DateTime.now();
    final isCurrentMonth =
        month.year == now.year && month.month == now.month;
    final lastDay = isCurrentMonth
        ? now.day
        : DateTime(month.year, month.month + 1, 0).day;
    final firstDay = (lastDay - 6).clamp(1, lastDay);
    final days = List.generate(lastDay - firstDay + 1, (i) => firstDay + i);

    const roundedTop = BorderRadius.vertical(top: Radius.circular(3));

    final maxValue = dayMap.values.isEmpty
        ? 1.0
        : dayMap.values.map((v) => v.toDouble()).reduce(max);
    final maxY = maxValue * 1.2;
    // Placeholder height: 40–65% of maxValue with two-frequency sine variation.
    double placeholderFor(int index) =>
        maxValue * (0.40 + 0.15 * ((sin(index * 1.9) + 1) / 2) +
            0.10 * ((sin(index * 3.3) + 1) / 2));

    final groups = days.asMap().entries.map((entry) {
      final index = entry.key;
      final day = entry.value;
      final total = (dayMap[day] ?? 0).toDouble();
      final hasData = total > 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: hasData ? total : placeholderFor(index),
            color: hasData ? AppColors.primary : AppColors.surfaceDim,
            width: 28,
            borderRadius: roundedTop,
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: groups,
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= days.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    _weekdayLabel(days[index]),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final date = DateTime(
                    month.year, month.month, days[group.x]);
                return BarTooltipItem(
                  '${DateFormatter.formatDateShort(date)}\n${CurrencyFormatter.format(rod.toY.round())}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
