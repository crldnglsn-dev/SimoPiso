import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatters.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/expense.dart';
import '../../data/repositories/expense_repository.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final List<Expense> expenses = ref.watch(expenseControllerProvider);
    final List<Expense> selectedExpenses = expenses
        .where((Expense item) => isSameDate(item.dueDate, _selectedDay))
        .toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: <Widget>[
          Text(
            'Calendar',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a day to see what is due.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TableCalendar<Expense>(
                firstDay: DateTime.utc(2020),
                lastDay: DateTime.utc(2035),
                focusedDay: _focusedDay,
                selectedDayPredicate: (DateTime day) =>
                    isSameDate(day, _selectedDay),
                eventLoader: (DateTime day) => expenses
                    .where((Expense item) => isSameDate(item.dueDate, day))
                    .toList(),
                availableGestures: AvailableGestures.all,
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.emerald,
                    shape: BoxShape.circle,
                  ),
                  outsideTextStyle: TextStyle(color: AppColors.textSecondary),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders<Expense>(
                  markerBuilder: (
                    BuildContext context,
                    DateTime day,
                    List<Expense> dayExpenses,
                  ) {
                    if (dayExpenses.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: dayExpenses.take(3).map((Expense expense) {
                        final Color color = switch (expense.status) {
                          PaymentStatus.paid => AppColors.emerald,
                          PaymentStatus.unpaid => AppColors.amber,
                          PaymentStatus.overdue => AppColors.red,
                        };

                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            formatCalendarDate(_selectedDay),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (selectedExpenses.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'No dues on this date.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            ...selectedExpenses.map(
              (Expense expense) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(expense.name),
                  subtitle: Text(expense.status.name.toUpperCase()),
                  trailing: Text(formatPhp(expense.amount)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
