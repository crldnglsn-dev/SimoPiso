import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatters.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/expense.dart';
import '../../data/repositories/expense_repository.dart';
import '../expenses/widgets/add_edit_expense_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Expense> expenses = ref.watch(expenseControllerProvider);
    final ExpenseInsights insights = ref.watch(expenseInsightsProvider);
    final double total = insights.totalMonthlyEquivalentExpenses;
    final double savingsRate = 0.2;
    final double incomeGoal = total == 0 ? 0 : total / (1 - savingsRate);
    final List<Expense> upcoming = expenses
        .where((Expense item) => item.status != PaymentStatus.paid)
        .take(6)
        .toList();

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.emerald,
        onRefresh: () async {
          ref.read(expenseControllerProvider.notifier).refreshOverdueStatuses();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: <Widget>[
            Text(
              'Your monthly load',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Track what is due, what is late, and what income keeps you safe.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _HeroCard(total: total, incomeGoal: incomeGoal),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: _MetricCard(
                    title: 'Due today',
                    value: '${insights.dueTodayCount}',
                    subtitle: 'Need attention now',
                    color: AppColors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Overdue',
                    value: '${insights.overdueCount}',
                    subtitle: 'Catch these up',
                    color: AppColors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _MetricCard(
                    title: 'Paid',
                    value: formatPhp(insights.totalPaid),
                    subtitle: '${insights.paidCount}/${insights.totalCount} cleared',
                    color: AppColors.emerald,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Open',
                    value: formatPhp(insights.totalOpen),
                    subtitle: '${insights.dueThisWeekCount} due this week',
                    color: AppColors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Payment progress',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      minHeight: 10,
                      value: insights.paidProgress,
                      backgroundColor: AppColors.surfaceGlass,
                      color: AppColors.emerald,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${insights.paidCount} paid, ${insights.openCount} still open',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle(
              title: 'Upcoming dues',
              actionLabel: 'Add',
              onAction: () => showAddEditExpenseSheet(context, ref),
            ),
            const SizedBox(height: 12),
            if (upcoming.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'No dues yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first expense to start tracking bills, subscriptions, and loans.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 162,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    final Expense expense = upcoming[index];
                    final Color color = _statusColor(expense.status);
                    return Container(
                      width: 220,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: <Color>[
                            color.withValues(alpha: 0.22),
                            AppColors.surface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              expense.status.name.toUpperCase(),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            expense.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatPhp(expense.amount),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _upcomingLabel(expense),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemCount: upcoming.length,
                ),
              ),
            const SizedBox(height: 24),
            const _SectionTitle(title: 'Quick summary'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ExpenseCategory.values.map((ExpenseCategory category) {
                final int count = expenses
                    .where((Expense expense) => expense.category == category)
                    .length;
                return Chip(
                  label: Text('${category.label} | $count'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;

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
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: color),
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.total, required this.incomeGoal});

  final double total;
  final double incomeGoal;

  @override
  Widget build(BuildContext context) {
    final double progress =
        incomeGoal == 0 ? 0 : (total / incomeGoal).clamp(0, 1);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: <Color>[AppColors.surfaceAlt, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Total obligations',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            formatPhp(total),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: progress,
                  backgroundColor: AppColors.surfaceGlass,
                  color: AppColors.emerald,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'You need at least ${formatPhp(incomeGoal)}/month',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

Color _statusColor(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.paid:
      return AppColors.emerald;
    case PaymentStatus.unpaid:
      return AppColors.amber;
    case PaymentStatus.overdue:
      return AppColors.red;
  }
}

extension on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.subscription:
        return 'Subscriptions';
      case ExpenseCategory.bill:
        return 'Bills';
      case ExpenseCategory.loan:
        return 'Loans';
      case ExpenseCategory.oneTime:
        return 'One-time';
    }
  }
}

String _upcomingLabel(Expense expense) {
  if (expense.status == PaymentStatus.overdue) {
    return 'Overdue • ${formatCalendarDate(expense.dueDate)}';
  }

  if (isSameDate(expense.dueDate, DateTime.now())) {
    return 'Due today';
  }

  if (isTomorrow(expense.dueDate)) {
    return 'Due tomorrow';
  }

  if (isThisWeek(expense.dueDate)) {
    return 'This week • ${formatCalendarDate(expense.dueDate)}';
  }

  return 'Due ${formatCalendarDate(expense.dueDate)}';
}
