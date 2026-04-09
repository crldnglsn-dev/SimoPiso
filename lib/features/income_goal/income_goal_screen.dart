import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatters.dart';
import '../../data/repositories/expense_repository.dart';

class IncomeGoalScreen extends ConsumerStatefulWidget {
  const IncomeGoalScreen({super.key});

  @override
  ConsumerState<IncomeGoalScreen> createState() => _IncomeGoalScreenState();
}

class _IncomeGoalScreenState extends ConsumerState<IncomeGoalScreen> {
  double _savingsRate = 0.2;
  int _workDaysPerWeek = 5;

  @override
  Widget build(BuildContext context) {
    final ExpenseInsights insights = ref.watch(expenseInsightsProvider);
    final double totalExpenses = insights.totalMonthlyEquivalentExpenses;
    final double recommendedIncome =
        totalExpenses == 0 ? 0 : totalExpenses / (1 - _savingsRate);
    final double savingsBuffer = recommendedIncome - totalExpenses;
    final DateTime now = DateTime.now();
    final int workingDaysThisMonth = _countWorkingDaysInMonth(
      year: now.year,
      month: now.month,
      workDaysPerWeek: _workDaysPerWeek,
    );
    final double dailyIncomeTarget = workingDaysThisMonth == 0
        ? 0
        : recommendedIncome / workingDaysThisMonth;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: <Widget>[
          Text(
            'Income goal',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Plan income around your real obligations plus breathing room.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Savings target: ${(_savingsRate * 100).round()}%',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    min: 0,
                    max: 0.5,
                    divisions: 10,
                    activeColor: AppColors.emerald,
                    value: _savingsRate,
                    onChanged: (double value) {
                      setState(() => _savingsRate = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Work days per week',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: const <ButtonSegment<int>>[
                      ButtonSegment<int>(value: 5, label: Text('5 days')),
                      ButtonSegment<int>(value: 6, label: Text('6 days')),
                      ButtonSegment<int>(value: 7, label: Text('7 days')),
                    ],
                    selected: <int>{_workDaysPerWeek},
                    onSelectionChanged: (Set<int> value) {
                      setState(() => _workDaysPerWeek = value.first);
                    },
                  ),
                  const SizedBox(height: 18),
                  _MetricRow(
                    label: 'Monthly equivalent expenses',
                    value: formatPhp(totalExpenses),
                  ),
                  _MetricRow(
                    label: 'Recommended minimum income',
                    value: formatPhp(recommendedIncome),
                  ),
                  _MetricRow(
                    label: 'Savings buffer',
                    value: formatPhp(savingsBuffer),
                  ),
                  _MetricRow(
                    label: 'Current open balance',
                    value: formatPhp(insights.totalOpen),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Suggested daily income',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Using the real ${DateFormat('MMMM yyyy').format(now)} calendar and a $_workDaysPerWeek-day work week, this is your daily target.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    formatPhp(dailyIncomeTarget),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$workingDaysThisMonth working days in ${DateFormat('MMMM').format(now)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

int _countWorkingDaysInMonth({
  required int year,
  required int month,
  required int workDaysPerWeek,
}) {
  final DateTime firstDay = DateTime(year, month, 1);
  final DateTime lastDay = DateTime(year, month + 1, 0);
  int total = 0;

  for (DateTime day = firstDay;
      !day.isAfter(lastDay);
      day = day.add(const Duration(days: 1))) {
    final int weekday = day.weekday;
    final bool isWorkingDay = switch (workDaysPerWeek) {
      5 => weekday >= DateTime.monday && weekday <= DateTime.friday,
      6 => weekday >= DateTime.monday && weekday <= DateTime.saturday,
      7 => true,
      _ => weekday >= DateTime.monday && weekday <= DateTime.friday,
    };

    if (isWorkingDay) {
      total++;
    }
  }

  return total;
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
