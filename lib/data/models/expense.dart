enum RecurrenceType { monthly, weekly, oneTime }

enum ExpenseCategory { subscription, bill, loan, oneTime }

enum PaymentStatus { paid, unpaid, overdue }

class Expense {
  Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.recurrence,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    this.notes,
  });

  final String id;
  final String name;
  final double amount;
  final ExpenseCategory category;
  final RecurrenceType recurrence;
  final DateTime dueDate;
  final PaymentStatus status;
  final String? notes;
  final DateTime createdAt;

  Expense copyWith({
    String? id,
    String? name,
    double? amount,
    ExpenseCategory? category,
    RecurrenceType? recurrence,
    DateTime? dueDate,
    PaymentStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      recurrence: recurrence ?? this.recurrence,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: ExpenseCategory.values.byName(json['category'] as String),
      recurrence: RecurrenceType.values.byName(json['recurrence'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: PaymentStatus.values.byName(json['status'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'amount': amount,
      'category': category.name,
      'recurrence': recurrence.name,
      'dueDate': dueDate.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
