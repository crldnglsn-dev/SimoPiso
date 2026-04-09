import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/utils/date_helpers.dart';
import '../models/expense.dart';

final Provider<ExpenseRepository> expenseRepositoryProvider =
    Provider<ExpenseRepository>((Ref ref) => LocalExpenseRepository());

final StateNotifierProvider<ExpenseController, List<Expense>>
    expenseControllerProvider =
    StateNotifierProvider<ExpenseController, List<Expense>>((Ref ref) {
      return ExpenseController(ref.watch(expenseRepositoryProvider));
    });

final Provider<ExpenseInsights> expenseInsightsProvider =
    Provider<ExpenseInsights>((Ref ref) {
      final List<Expense> expenses = ref.watch(expenseControllerProvider);
      return ExpenseInsights.fromExpenses(expenses);
    });

abstract class ExpenseRepository {
  Future<List<Expense>> loadExpenses();
  Future<void> saveExpenses(List<Expense> expenses);
}

class MemoryExpenseRepository implements ExpenseRepository {
  MemoryExpenseRepository([List<Expense>? seedExpenses])
      : _expenses = List<Expense>.from(seedExpenses ?? <Expense>[]);

  List<Expense> _expenses;

  @override
  Future<List<Expense>> loadExpenses() async {
    return List<Expense>.from(_expenses);
  }

  @override
  Future<void> saveExpenses(List<Expense> expenses) async {
    _expenses = List<Expense>.from(expenses);
  }
}

class LocalExpenseRepository implements ExpenseRepository {
  static const String _fileName = 'expenses.json';

  Future<File> _resolveFile() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}${Platform.pathSeparator}$_fileName');
  }

  @override
  Future<List<Expense>> loadExpenses() async {
    final File file = await _resolveFile();
    if (!await file.exists()) {
      return <Expense>[];
    }

    final String contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      return <Expense>[];
    }

    final List<dynamic> decoded = jsonDecode(contents) as List<dynamic>;
    return decoded
        .map((dynamic item) => Expense.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveExpenses(List<Expense> expenses) async {
    final File file = await _resolveFile();
    final String payload = jsonEncode(
      expenses.map((Expense expense) => expense.toJson()).toList(),
    );
    await file.writeAsString(payload, flush: true);
  }
}

class ExpenseController extends StateNotifier<List<Expense>> {
  ExpenseController(this._repository) : super(<Expense>[]) {
    _loadExpenses();
  }

  final ExpenseRepository _repository;

  Future<void> _loadExpenses() async {
    final List<Expense> loadedExpenses = await _repository.loadExpenses();
    state = _normalizeExpenses(loadedExpenses);
    await _persist();
  }

  void addExpense(Expense expense) {
    state = _normalizeExpenses(<Expense>[expense, ...state]);
    _persist();
  }

  void updateExpense(Expense expense) {
    state = _normalizeExpenses(
      state
          .map((Expense current) => current.id == expense.id ? expense : current)
          .toList(),
    );
    _persist();
  }

  void deleteExpense(String id) {
    state = state.where((Expense expense) => expense.id != id).toList();
    _persist();
  }

  void markPaid(String id) {
    state = _normalizeExpenses(
      state
          .map(
            (Expense expense) => expense.id == id
                ? expense.copyWith(status: PaymentStatus.paid)
                : expense,
          )
          .toList(),
    );
    _persist();
  }

  void refreshOverdueStatuses() {
    state = _normalizeExpenses(state);
    _persist();
  }

  List<Expense> _normalizeExpenses(List<Expense> expenses) {
    final List<Expense> normalized = expenses.map((Expense expense) {
      if (expense.status == PaymentStatus.paid) {
        return expense;
      }

      if (isOverdue(expense.dueDate)) {
        return expense.copyWith(status: PaymentStatus.overdue);
      }

      return expense.copyWith(status: PaymentStatus.unpaid);
    }).toList();

    normalized.sort((Expense a, Expense b) => a.dueDate.compareTo(b.dueDate));
    return normalized;
  }

  Future<void> _persist() async {
    await _repository.saveExpenses(state);
  }
}

class ExpenseInsights {
  ExpenseInsights({
    required this.totalActualExpenses,
    required this.totalMonthlyEquivalentExpenses,
    required this.totalPaid,
    required this.totalOpen,
    required this.dueTodayCount,
    required this.dueThisWeekCount,
    required this.overdueCount,
    required this.paidCount,
    required this.openCount,
  });

  final double totalActualExpenses;
  final double totalMonthlyEquivalentExpenses;
  final double totalPaid;
  final double totalOpen;
  final int dueTodayCount;
  final int dueThisWeekCount;
  final int overdueCount;
  final int paidCount;
  final int openCount;

  double get paidProgress =>
      totalActualExpenses == 0 ? 0 : (totalPaid / totalActualExpenses).clamp(0, 1);

  int get totalCount => paidCount + openCount;

  factory ExpenseInsights.fromExpenses(List<Expense> expenses) {
    final Iterable<Expense> openExpenses =
        expenses.where((Expense expense) => expense.status != PaymentStatus.paid);

    return ExpenseInsights(
      totalActualExpenses: expenses.fold<double>(
        0,
        (double sum, Expense expense) => sum + expense.amount,
      ),
      totalMonthlyEquivalentExpenses: expenses.fold<double>(
        0,
        (double sum, Expense expense) => sum + expenseMonthlyEquivalent(expense),
      ),
      totalPaid: expenses
          .where((Expense expense) => expense.status == PaymentStatus.paid)
          .fold<double>(0, (double sum, Expense expense) => sum + expense.amount),
      totalOpen: openExpenses.fold<double>(
        0,
        (double sum, Expense expense) => sum + expense.amount,
      ),
      dueTodayCount: openExpenses
          .where((Expense expense) => isSameDate(expense.dueDate, DateTime.now()))
          .length,
      dueThisWeekCount: openExpenses
          .where((Expense expense) => isThisWeek(expense.dueDate))
          .length,
      overdueCount: openExpenses
          .where((Expense expense) => expense.status == PaymentStatus.overdue)
          .length,
      paidCount: expenses
          .where((Expense expense) => expense.status == PaymentStatus.paid)
          .length,
      openCount: openExpenses.length,
    );
  }
}

double expenseMonthlyEquivalent(Expense expense) {
  switch (expense.recurrence) {
    case RecurrenceType.monthly:
      return expense.amount;
    case RecurrenceType.weekly:
      return expense.amount * 52 / 12;
    case RecurrenceType.oneTime:
      return isThisMonth(expense.dueDate) ? expense.amount : 0;
  }
}
