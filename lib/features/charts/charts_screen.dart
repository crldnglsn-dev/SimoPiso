import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatters.dart';
import '../../data/models/expense.dart';
import '../../data/repositories/expense_repository.dart';

class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Expense> expenses = ref.watch(expenseControllerProvider);
    final ExpenseInsights insights = ref.watch(expenseInsightsProvider);
    final Map<ExpenseCategory, double> categoryTotals =
        <ExpenseCategory, double>{
      for (final ExpenseCategory category in ExpenseCategory.values)
        category: expenses
            .where((Expense item) => item.category == category)
            .fold<double>(
              0,
              (double sum, Expense item) => sum + expenseMonthlyEquivalent(item),
            ),
    };
    final Expense? largestExpense = expenses.isEmpty
        ? null
        : (expenses.toList()
              ..sort((Expense a, Expense b) => b.amount.compareTo(a.amount)))
            .first;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: <Widget>[
          Text(
            'Breakdown',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'See where your money goes and what dominates your month.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 54,
                        sections: categoryTotals.entries.map((entry) {
                          return PieChartSectionData(
                            color: _categoryColor(entry.key),
                            value: entry.value == 0 ? 1 : entry.value,
                            radius: 38,
                            title: entry.value == 0
                                ? ''
                                : formatCompactPhp(entry.value),
                            titleStyle: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontSize: 10),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: categoryTotals.entries.map((entry) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _categoryColor(entry.key),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(entry.key.name),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const List<String> months = <String>[
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                            ];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(months[value.toInt()]),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: <BarChartGroupData>[
                      _bar(0, 9000),
                      _bar(1, 11200),
                      _bar(2, 9800),
                      _bar(3, 12600),
                      _bar(4, 13848),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatsCard(
                  title: 'Biggest',
                  value: largestExpense?.name ?? 'None',
                  subtitle: largestExpense == null
                      ? 'No expenses yet'
                      : formatPhp(largestExpense.amount),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatsCard(
                  title: 'Average / month',
                  value: formatPhp(insights.totalMonthlyEquivalentExpenses),
                  subtitle: 'Monthly equivalent',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

BarChartGroupData _bar(int x, double y) {
  return BarChartGroupData(
    x: x,
    barRods: <BarChartRodData>[
      BarChartRodData(
        toY: y,
        width: 22,
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: <Color>[AppColors.emerald, AppColors.amber],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
    ],
  );
}

Color _categoryColor(ExpenseCategory category) {
  switch (category) {
    case ExpenseCategory.subscription:
      return AppColors.emerald;
    case ExpenseCategory.bill:
      return AppColors.amber;
    case ExpenseCategory.loan:
      return AppColors.red;
    case ExpenseCategory.oneTime:
      return const Color(0xFF7C9CF5);
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
