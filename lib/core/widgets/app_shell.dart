import 'package:anotagasto_app/app/routes.dart';
import 'package:anotagasto_app/core/di/service_locator.dart';
import 'package:anotagasto_app/core/models/user_model.dart';
import 'package:anotagasto_app/core/storage/storage_service.dart';
import 'package:anotagasto_app/core/theme/app_colors.dart';
import 'package:anotagasto_app/core/utils/constants.dart';
import 'package:anotagasto_app/core/view_state.dart';
import 'package:anotagasto_app/features/analytics/analytics_view.dart';
import 'package:anotagasto_app/features/expenses/expenses_view.dart';
import 'package:anotagasto_app/features/expenses/widgets/add_expense_sheet.dart'
    show showAddExpenseSheet;
import 'package:anotagasto_app/features/profile/profile_view.dart';
import 'package:anotagasto_app/features/profile/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  bool _sheetOpening = false;

  static const _tabs = [
    (
      icon: Icons.receipt_long_outlined,
      label: 'Despesas',
      title: 'Despesas',
    ),
    (
      icon: Icons.bar_chart_outlined,
      label: 'Análises',
      title: 'Dashboard de Análise',
    ),
    (icon: Icons.person_outline, label: 'Perfil', title: 'Perfil'),
  ];

  static const _views = [ExpensesView(), AnalyticsView(), ProfileView()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = di<StorageService>().getToken();
      if (token == null) {
        Navigator.of(context).pushReplacementNamed(Routes.login.name);
        return;
      }
      context.read<ProfileViewModel>().loadUser();
    });
  }

  void _openAddExpense() {
    if (_sheetOpening) return;
    _sheetOpening = true;
    showAddExpenseSheet(context).then((_) {
      if (mounted) _sheetOpening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;
        return isDesktop
            ? _DesktopShell(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) =>
                    setState(() => _selectedIndex = i),
                tabs: _tabs,
                onAddExpense: _selectedIndex == 1 ? _openAddExpense : null,
                child: _views[_selectedIndex],
              )
            : _MobileShell(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) =>
                    setState(() => _selectedIndex = i),
                tabs: _tabs,
                child: _views[_selectedIndex],
              );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile shell — BottomNavigationBar
// ---------------------------------------------------------------------------

class _MobileShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<({IconData icon, String label, String title})> tabs;
  final Widget child;

  const _MobileShell({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.tabs,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: tabs
            .map((t) => NavigationDestination(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop shell — Custom sidebar + top bar
// ---------------------------------------------------------------------------

class _DesktopShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<({IconData icon, String label, String title})> tabs;
  final VoidCallback? onAddExpense;
  final Widget child;

  const _DesktopShell({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.tabs,
    required this.child,
    this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            _Sidebar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              tabs: tabs,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  _TopBar(
                    title: tabs[selectedIndex].title,
                    onAddExpense: onAddExpense,
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: Constants.breakpointDesktop,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sidebar
// ---------------------------------------------------------------------------

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<({IconData icon, String label, String title})> tabs;

  const _Sidebar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final userName = context.select<ProfileViewModel, String?>(
      (vm) => vm.viewState is SuccessStateView<UserModel>
          ? (vm.viewState as SuccessStateView<UserModel>).data.name
          : null,
    );

    return Container(
      width: 220,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AnotaGasto',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (userName != null)
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...tabs.asMap().entries.map((entry) {
            final i = entry.key;
            final tab = entry.value;
            return _SidebarNavItem(
              icon: tab.icon,
              label: tab.label,
              selected: i == selectedIndex,
              onTap: () => onDestinationSelected(i),
            );
          }),
          const Spacer(),
          if (userName != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Text(
                      userName[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? AppColors.primary : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onAddExpense;

  const _TopBar({required this.title, this.onAddExpense});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.onSurfaceVariant,
            ),
            onPressed: () {},
          ),
          if (onAddExpense != null) ...[
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onAddExpense,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Nova Despesa'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
