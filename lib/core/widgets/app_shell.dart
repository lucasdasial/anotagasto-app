import 'package:anotagasto_app/app/routes.dart';
import 'package:anotagasto_app/core/di/service_locator.dart';
import 'package:anotagasto_app/core/storage/storage_service.dart';
import 'package:anotagasto_app/core/utils/constants.dart';
import 'package:anotagasto_app/features/expenses/expenses_view.dart';
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
  // StatefulWidget needed for auth guard, tab state, and user load trigger.
  int _selectedIndex = 0;

  static const _tabs = [
    (icon: Icons.receipt_long_outlined, label: 'Despesas'),
    (icon: Icons.person_outline, label: 'Perfil'),
  ];

  static const _views = [
    ExpensesView(),
    ProfileView(),
  ];

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
  final List<({IconData icon, String label})> tabs;
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
// Desktop shell — NavigationRail
// ---------------------------------------------------------------------------

class _DesktopShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<({IconData icon, String label})> tabs;
  final Widget child;

  const _DesktopShell({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.tabs,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: tabs
                  .map((t) => NavigationRailDestination(
                        icon: Icon(t.icon),
                        label: Text(t.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1),
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
    );
  }
}
