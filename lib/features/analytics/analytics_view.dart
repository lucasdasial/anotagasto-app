import 'package:anotagasto_app/core/models/analytics_summary_model.dart';
import 'package:anotagasto_app/core/theme/app_colors.dart';
import 'package:anotagasto_app/core/utils/constants.dart';
import 'package:anotagasto_app/core/utils/currency_formatter.dart';
import 'package:anotagasto_app/core/view_state.dart';
import 'package:anotagasto_app/core/widgets/error_banner.dart';
import 'package:anotagasto_app/features/analytics/analytics_view_model.dart';
import 'package:anotagasto_app/features/analytics/widgets/category_donut_chart.dart';
import 'package:anotagasto_app/features/analytics/widgets/category_legend.dart';
import 'package:anotagasto_app/features/analytics/widgets/daily_bar_chart.dart';
import 'package:anotagasto_app/features/analytics/widgets/month_selector.dart';
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
                isDesktop ? 32 : 20,
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
      padding: EdgeInsets.fromLTRB(hPadding, 16, hPadding, 32),
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
// Desktop: two-column
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
        _TotalCard(summary: data.summary),
        const SizedBox(height: 28),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SectionTitle(title: 'Por categoria'),
                    const SizedBox(height: 12),
                    CategoryDonutChart(summary: data.summary),
                    const SizedBox(height: 16),
                    CategoryLegend(stats: data.summary.byCategory),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SectionTitle(title: 'Gastos diários'),
                    const SizedBox(height: 12),
                    DailyBarChart(daily: data.daily, month: month),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared
// ---------------------------------------------------------------------------

class _TotalCard extends StatelessWidget {
  final AnalyticsSummaryModel summary;

  const _TotalCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final activeCategories = summary.byCategory
        .where((s) => s.total > 0)
        .length;
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
          Text(
            'Total do mês',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
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
