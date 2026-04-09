import 'package:intl/intl.dart';

bool isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool isOverdue(DateTime value) {
  final DateTime now = DateTime.now();
  final DateTime cutoff = DateTime(now.year, now.month, now.day);
  return value.isBefore(cutoff);
}

bool isTomorrow(DateTime value) {
  final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
  return isSameDate(value, tomorrow);
}

bool isThisMonth(DateTime value, {DateTime? reference}) {
  final DateTime now = reference ?? DateTime.now();
  return value.year == now.year && value.month == now.month;
}

bool isThisWeek(DateTime value, {DateTime? reference}) {
  final DateTime now = reference ?? DateTime.now();
  final DateTime start = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  final DateTime end = start.add(const Duration(days: 6));
  final DateTime target = DateTime(value.year, value.month, value.day);
  return !target.isBefore(start) && !target.isAfter(end);
}

int daysUntil(DateTime value, {DateTime? reference}) {
  final DateTime now = reference ?? DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime target = DateTime(value.year, value.month, value.day);
  return target.difference(today).inDays;
}

String formatShortDate(DateTime value) => DateFormat('MMM d').format(value);

String formatCalendarDate(DateTime value) =>
    DateFormat('EEE, MMM d').format(value);

String formatMonthLabel(DateTime value) => DateFormat('MMMM yyyy').format(value);
