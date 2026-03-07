import 'package:anotagasto_app/core/models/analytics_summary_model.dart';
import 'package:anotagasto_app/core/models/expense_model.dart';
import 'package:anotagasto_app/core/theme/app_colors.dart';
import 'package:anotagasto_app/core/utils/constants.dart';
import 'package:anotagasto_app/core/utils/currency_formatter.dart';
import 'package:anotagasto_app/core/utils/date_formatter.dart';
import 'package:anotagasto_app/core/view_state.dart';
import 'package:anotagasto_app/core/widgets/category_chip.dart';
import 'package:anotagasto_app/core/widgets/error_banner.dart';
import 'package:anotagasto_app/features/analytics/analytics_view_model.dart';
import 'package:anotagasto_app/features/analytics/widgets/category_donut_chart.dart';
import 'package:anotagasto_app/features/analytics/widgets/category_legend.dart';
import 'package:anotagasto_app/features/analytics/widgets/daily_bar_chart.dart';
import 'package:anotagasto_app/features/analytics/widgets/month_selector.dart';
import 'package:anotagasto_app/features/expenses/expenses_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// StatefulWidget needed for initState data load.
class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsViewModel>().load();
      final expVm = context.read<ExpensesViewModel>();
      if (expVm.viewState is InitialStateView) {
        expVm.getExpenseList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalyticsViewModel>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;
        final hPadding = isDesktop
            ? Constants.paddingPage
            : Constants.paddingPage * 0.67;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                hPadding,
                isDesktop ? 24 : 20,
                hPadding,
                0,
              ),
              child: MonthSelector(
                month: vm.month,
                canGoNext: vm.canGoNext,
                onPrevious: () =>
                    context.read<AnalyticsViewModel>().previousMonth(),
                onNext: () => context.read<AnalyticsViewModel>().nextMonth(),
              ),
            ),
            Expanded(child: _buildBody(vm, hPadding, isDesktop)),
          ],
        );
      },
    );
  }

  Widget _buildBody(AnalyticsViewModel vm, double hPadding, bool isDesktop) {
    if (vm.viewState is LoadingStateView) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.viewState is ErrorStateView) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          child: ErrorBanner(
            message: (vm.viewState as ErrorStateView).message,
            onRetry: () => context.read<AnalyticsViewModel>().load(),
          ),
        ),
      );
    }

    if (vm.viewState is! SuccessStateView<AnalyticsData>) {
      return const SizedBox.shrink();
    }

    final data = (vm.viewState as SuccessStateView<AnalyticsData>).data;
    final hasData = data.summary.byCategory.any((s) => s.total > 0);

    if (!hasData) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 56,
              color: AppColors.onSurfaceMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma despesa neste mês.',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPadding, 20, hPadding, 32),
      child: isDesktop
          ? _DesktopLayout(data: data, month: vm.month)
          : _MobileLayout(data: data, month: vm.month),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile: vertical stack
// ---------------------------------------------------------------------------

class _MobileLayout extends StatelessWidget {
  final AnalyticsData data;
  final DateTime month;

  const _MobileLayout({required this.data, required this.month});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TotalCard(summary: data.summary),
        const SizedBox(height: 24),
        _SectionTitle(title: 'Por categoria'),
        const SizedBox(height: 12),
        CategoryDonutChart(summary: data.summary),
        const SizedBox(height: 16),
        CategoryLegend(stats: data.summary.byCategory),
        const SizedBox(height: 28),
        _SectionTitle(title: 'Gastos diários'),
        const SizedBox(height: 12),
        DailyBarChart(daily: data.daily, month: month),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop: stat cards + two-column charts + recent transactions
// ---------------------------------------------------------------------------

class _DesktopLayout extends StatelessWidget {
  final AnalyticsData data;
  final DateTime month;

  const _DesktopLayout({required this.data, required this.month});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatCards(summary: data.summary),
        const SizedBox(height: 28),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ChartCard(
                  title: 'Gastos por Categoria',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CategoryDonutChart(summary: data.summary),
                      const SizedBox(height: 16),
                      CategoryLegend(stats: data.summary.byCategory),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ChartCard(
                  title: 'Gastos Diários',
                  child: DailyBarChart(daily: data.daily, month: month),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const _RecentTransactionsSection(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Stat cards row
// ---------------------------------------------------------------------------

class _StatCards extends StatelessWidget {
  final AnalyticsSummaryModel summary;

  const _StatCards({required this.summary});

  @override
  Widget build(BuildContext context) {
    final top = summary.topCategory;
    return IntrinsicHeight(
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _StatCard(
            label: 'Gasto Total Mensal',
            value: CurrencyFormatter.format(summary.totalMonth),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            label: 'Transações',
            value: '${summary.count}',
            subtitle: summary.count == 1 ? 'despesa registrada' : 'despesas registradas',
          ),
        ),
        if (top != null) ...[
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              label: 'Top Categoria',
              value: top.category.label,
              subtitle: CurrencyFormatter.format(top.total),
              highlight: true,
            ),
          ),
        ],
      ],
    ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final bool highlight;

  const _StatCard({
    required this.label,
    required this.value,
    this.subtitle,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = highlight ? AppColors.primary : AppColors.surface;
    final labelColor = highlight ? Colors.white70 : AppColors.onSurfaceVariant;
    final valueColor = highlight ? Colors.white : AppColors.onSurface;
    final subtitleColor = highlight ? Colors.white60 : AppColors.onSurfaceMuted;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: highlight ? null : Border.all(color: AppColors.surfaceDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 11, color: subtitleColor),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent transactions section (desktop only)
// ---------------------------------------------------------------------------

class _RecentTransactionsSection extends StatelessWidget {
  const _RecentTransactionsSection();

  @override
  Widget build(BuildContext context) {
    final expState = context.select<ExpensesViewModel, ViewState>(
      (vm) => vm.viewState,
    );

    if (expState is! SuccessStateView<ExpenseListModel>) {
      return const SizedBox.shrink();
    }

    final expenses = expState.data.expenses.take(5).toList();
    if (expenses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(title: 'Transações Recentes'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceDim),
          ),
          child: Column(
            children: [
              _TransactionRow.header(),
              const Divider(height: 1),
              ...expenses.asMap().entries.map((entry) {
                final isLast = entry.key == expenses.length - 1;
                return Column(
                  children: [
                    _TransactionRow(expense: entry.value),
                    if (!isLast) const Divider(height: 1),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final ExpenseModel? expense;
  final bool isHeader;

  const _TransactionRow({this.expense}) : isHeader = false;
  const _TransactionRow.header()
      : expense = null,
        isHeader = true;

  @override
  Widget build(BuildContext context) {
    if (isHeader) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'Descrição',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Categoria',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                'Data',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                'Valor',
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final e = expense!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CategoryChip(category: e.category, compact: true, selected: true),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.description,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              e.category.label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              DateFormatter.formatDate(e.date),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              CurrencyFormatter.format(e.value),
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared
// ---------------------------------------------------------------------------

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final AnalyticsSummaryModel summary;

  const _TotalCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final activeCategories =
        summary.byCategory.where((s) => s.total > 0).length;
    final top = summary.topCategory;
    final gasto = summary.count == 1 ? 'item' : 'itens';
    final categoria = activeCategories == 1 ? 'categoria' : 'categorias';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total do mês',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(summary.totalMonth),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          _InfoLine('Você registrou ${summary.count} $gasto'),
          const SizedBox(height: 6),
          _InfoLine(
            'Seus gastos estão distribuídos em $activeCategories $categoria',
          ),
          if (top != null) ...[
            const SizedBox(height: 6),
            _InfoLine(
              'A categoria com maior gasto foi: ${top.category.label} (${CurrencyFormatter.format(top.total)})',
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String text;

  const _InfoLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 13),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
