import '../utils/currency_formatters.dart';
import '../utils/date_helpers.dart';
import '../../data/models/expense.dart';

class LocalNotificationService {
  Future<void> initialize() async {}

  Future<void> scheduleExpenseReminders(List<Expense> expenses) async {}

  Future<void> showWeeklySummary(List<Expense> expenses) async {}

  String buildReminderBody(Expense expense) {
    return '${expense.name} is due ${formatShortDate(expense.dueDate)} for ${formatPhp(expense.amount)}.';
  }

  String buildWeeklySummaryBody(List<Expense> expenses) {
    final List<Expense> dueThisWeek = expenses
        .where(
          (Expense expense) =>
              expense.status != PaymentStatus.paid && isThisWeek(expense.dueDate),
        )
        .toList();
    final double total = dueThisWeek.fold<double>(
      0,
      (double sum, Expense expense) => sum + expense.amount,
    );

    return 'You have ${dueThisWeek.length} expense(s) due this week - ${formatPhp(total)} total.';
  }
}
