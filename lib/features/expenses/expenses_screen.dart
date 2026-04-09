import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatters.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/expense.dart';
import '../../data/repositories/expense_repository.dart';
import 'widgets/add_edit_expense_sheet.dart';

enum ExpenseFilter { all, open, paid, overdue }

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final TextEditingController _searchController = TextEditingController();
  ExpenseFilter _filter = ExpenseFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Expense> expenses = ref.watch(expenseControllerProvider);
    final String searchTerm = _searchController.text.trim().toLowerCase();
    final List<Expense> filtered = expenses.where((Expense expense) {
      final bool matchesSearch = searchTerm.isEmpty ||
          expense.name.toLowerCase().contains(searchTerm) ||
          (expense.notes?.toLowerCase().contains(searchTerm) ?? false);
      final bool matchesFilter = switch (_filter) {
        ExpenseFilter.all => true,
        ExpenseFilter.open => expense.status != PaymentStatus.paid,
        ExpenseFilter.paid => expense.status == PaymentStatus.paid,
        ExpenseFilter.overdue => expense.status == PaymentStatus.overdue,
      };
      return matchesSearch && matchesFilter;
    }).toList();

    final Map<ExpenseCategory, List<Expense>> grouped =
        <ExpenseCategory, List<Expense>>{
      for (final ExpenseCategory category in ExpenseCategory.values)
        category: filtered
            .where((Expense item) => item.category == category)
            .toList(),
    };

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditExpenseSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: <Widget>[
            Text(
              'Expenses',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Search, filter, swipe right to mark paid, or swipe left to delete.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search by name or notes',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ExpenseFilter.values.map((ExpenseFilter filter) {
                return ChoiceChip(
                  label: Text(_filterLabel(filter)),
                  selected: _filter == filter,
                  onSelected: (_) => setState(() => _filter = filter),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (filtered.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    searchTerm.isEmpty
                        ? 'No expenses match this filter yet.'
                        : 'No expenses matched "$searchTerm".',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ...ExpenseCategory.values.map(
                (ExpenseCategory category) => _ExpenseSection(
                  category: category,
                  items: grouped[category] ?? <Expense>[],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseSection extends ConsumerWidget {
  const _ExpenseSection({
    required this.category,
    required this.items,
  });

  final ExpenseCategory category;
  final List<Expense> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          title: Text(
            _categoryLabel(category),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text('${items.length} items'),
          children: items.map((Expense expense) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Dismissible(
                key: ValueKey<String>(expense.id),
                background: const _SwipeBg(
                  color: AppColors.emerald,
                  icon: Icons.check_rounded,
                  label: 'Paid',
                  alignment: Alignment.centerLeft,
                ),
                secondaryBackground: const _SwipeBg(
                  color: AppColors.red,
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  alignment: Alignment.centerRight,
                ),
                confirmDismiss: (DismissDirection direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    ref.read(expenseControllerProvider.notifier).markPaid(expense.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${expense.name} marked as paid.')),
                    );
                    return false;
                  }

                  return true;
                },
                onDismissed: (_) {
                  ref.read(expenseControllerProvider.notifier).deleteExpense(expense.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${expense.name} deleted.'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          ref.read(expenseControllerProvider.notifier).addExpense(expense);
                        },
                      ),
                    ),
                  );
                },
                child: InkWell(
                  onTap: () => showAddEditExpenseSheet(
                    context,
                    ref,
                    expense: expense,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                expense.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _dueLabel(expense),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (expense.notes != null && expense.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    expense.notes!,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              formatPhp(expense.amount),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            _StatusBadge(status: expense.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SwipeBg extends StatelessWidget {
  const _SwipeBg({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignment,
  });

  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      PaymentStatus.paid => AppColors.emerald,
      PaymentStatus.unpaid => AppColors.amber,
      PaymentStatus.overdue => AppColors.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11),
      ),
    );
  }
}

String _categoryLabel(ExpenseCategory category) {
  switch (category) {
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

String _filterLabel(ExpenseFilter filter) {
  switch (filter) {
    case ExpenseFilter.all:
      return 'All';
    case ExpenseFilter.open:
      return 'Open';
    case ExpenseFilter.paid:
      return 'Paid';
    case ExpenseFilter.overdue:
      return 'Overdue';
  }
}

String _dueLabel(Expense expense) {
  if (expense.status == PaymentStatus.paid) {
    return 'Paid • ${formatShortDate(expense.dueDate)}';
  }

  if (isOverdue(expense.dueDate)) {
    return 'Overdue by ${daysUntil(expense.dueDate).abs()} day(s)';
  }

  if (isSameDate(expense.dueDate, DateTime.now())) {
    return 'Due today';
  }

  if (isTomorrow(expense.dueDate)) {
    return 'Due tomorrow';
  }

  if (isThisWeek(expense.dueDate)) {
    return 'Due this week • ${formatShortDate(expense.dueDate)}';
  }

  return 'Due ${formatShortDate(expense.dueDate)}';
}
