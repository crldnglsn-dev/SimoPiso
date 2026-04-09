import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem('/', Icons.home_rounded, 'Home'),
    _NavItem('/expenses', Icons.receipt_long_rounded, 'Expenses'),
    _NavItem('/calendar', Icons.calendar_month_rounded, 'Calendar'),
    _NavItem('/income-goal', Icons.trending_up_rounded, 'Income'),
    _NavItem('/charts', Icons.pie_chart_rounded, 'Charts'),
    _NavItem('/settings', Icons.tune_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _items.indexWhere(
      (_NavItem item) => item.route == location,
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex < 0 ? 0 : currentIndex,
          onTap: (int index) => context.go(_items[index].route),
          items: _items
              .map(
                (_NavItem item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.route, this.icon, this.label);

  final String route;
  final IconData icon;
  final String label;
}
