import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/charts/charts_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/expenses/expenses_screen.dart';
import 'features/income_goal/income_goal_screen.dart';
import 'features/settings/settings_screen.dart';
import 'shared/widgets/app_shell.dart';

class SimoPisoApp extends StatelessWidget {
  const SimoPisoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SimoPiso',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return AppShell(location: state.uri.toString(), child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const DashboardScreen(),
        ),
        GoRoute(
          path: '/expenses',
          builder: (BuildContext context, GoRouterState state) =>
              const ExpensesScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (BuildContext context, GoRouterState state) =>
              const CalendarScreen(),
        ),
        GoRoute(
          path: '/income-goal',
          builder: (BuildContext context, GoRouterState state) =>
              const IncomeGoalScreen(),
        ),
        GoRoute(
          path: '/charts',
          builder: (BuildContext context, GoRouterState state) =>
              const ChartsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (BuildContext context, GoRouterState state) =>
              const SettingsScreen(),
        ),
      ],
    ),
  ],
);
