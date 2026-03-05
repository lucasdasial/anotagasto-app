import 'package:anotagasto_app/core/models/expense_model.dart';
import 'package:anotagasto_app/core/theme/app_colors.dart';
import 'package:anotagasto_app/core/utils/constants.dart';
import 'package:anotagasto_app/core/utils/currency_formatter.dart';
import 'package:anotagasto_app/core/utils/date_formatter.dart';
import 'package:anotagasto_app/core/view_state.dart';
import 'package:anotagasto_app/core/widgets/category_chip.dart';
import 'package:anotagasto_app/core/widgets/error_banner.dart';
import 'package:anotagasto_app/features/expenses/expenses_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpensesView extends StatefulWidget {
  const ExpensesView({super.key});

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  // StatefulWidget needed for initState to trigger initial data load.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpensesViewModel>().getExpenseList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewState = context.watch<ExpensesViewModel>().viewState;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;
        final hPadding = isDesktop
            ? Constants.paddingPage
            : Constants.paddingPage * 0.67; // 16px on mobile

        if (viewState is LoadingStateView) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewState is ErrorStateView) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: ErrorBanner(
                message: viewState.message,
                onRetry: () =>
                    context.read<ExpensesViewModel>().getExpenseList(),
              ),
            ),
          );
        }

        if (viewState is SuccessStateView<ExpenseListModel>) {
          return _ExpenseListBody(
            data: viewState.data,
            hPadding: hPadding,
            isDesktop: isDesktop,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ExpenseListBody extends StatelessWidget {
  final ExpenseListModel data;
  final double hPadding;
  final bool isDesktop;

  const _ExpenseListBody({
    required this.data,
    required this.hPadding,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          amountTotal: data.amountTotal,
          hPadding: hPadding,
          isDesktop: isDesktop,
        ),
        Expanded(
          child: data.expenses.isEmpty
              ? Center(
                  child: Text(
                    'Nenhuma despesa encontrada.',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                )
              : isDesktop
              ? _DesktopGrid(expenses: data.expenses, hPadding: hPadding)
              : _MobileList(expenses: data.expenses, hPadding: hPadding),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final int amountTotal;
  final double hPadding;
  final bool isDesktop;

  const _Header({
    required this.amountTotal,
    required this.hPadding,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPadding, isDesktop ? 32 : 20, hPadding, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            'Despesas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? null : 20,
            ),
          ),
          Text(
            CurrencyFormatter.format(amountTotal),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileList extends StatelessWidget {
  final List<ExpenseModel> expenses;
  final double hPadding;

  const _MobileList({required this.expenses, required this.hPadding});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(hPadding, 0, hPadding, 24),
      itemCount: expenses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, index) => _ExpenseItem(expense: expenses[index]),
    );
  }
}

class _DesktopGrid extends StatelessWidget {
  final List<ExpenseModel> expenses;
  final double hPadding;

  const _DesktopGrid({required this.expenses, required this.hPadding});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(hPadding, 0, hPadding, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 76,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: expenses.length,
      itemBuilder: (_, index) => _ExpenseItem(expense: expenses[index]),
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  final ExpenseModel expense;

  const _ExpenseItem({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CategoryChip(category: expense.category, compact: true, selected: true),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  expense.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.formatDate(expense.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            CurrencyFormatter.format(expense.value),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
