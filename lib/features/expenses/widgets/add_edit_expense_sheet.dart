import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/expense.dart';
import '../../../data/repositories/expense_repository.dart';

Future<void> showAddEditExpenseSheet(
  BuildContext context,
  WidgetRef ref, {
  Expense? expense,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return AddEditExpenseSheet(expense: expense);
    },
  );
}

class AddEditExpenseSheet extends ConsumerStatefulWidget {
  const AddEditExpenseSheet({super.key, this.expense});

  final Expense? expense;

  @override
  ConsumerState<AddEditExpenseSheet> createState() =>
      _AddEditExpenseSheetState();
}

class _AddEditExpenseSheetState extends ConsumerState<AddEditExpenseSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late final FocusNode _nameFocusNode;
  late final FocusNode _amountFocusNode;
  late final FocusNode _notesFocusNode;
  late ExpenseCategory _category;
  late RecurrenceType _recurrence;
  late DateTime _dueDate;
  late PaymentStatus _status;
  String? _suggestedLabel;

  static const Map<String, ExpenseCategory> _smartSuggestions =
      <String, ExpenseCategory>{
    'netflix': ExpenseCategory.subscription,
    'spotify': ExpenseCategory.subscription,
    'youtube': ExpenseCategory.subscription,
    'meralco': ExpenseCategory.bill,
    'water': ExpenseCategory.bill,
    'loan': ExpenseCategory.loan,
  };

  @override
  void initState() {
    super.initState();
    final Expense? expense = widget.expense;
    _nameController = TextEditingController(text: expense?.name ?? '');
    _amountController = TextEditingController(
      text: expense?.amount.toStringAsFixed(0) ?? '',
    );
    _notesController = TextEditingController(text: expense?.notes ?? '');
    _category = expense?.category ?? ExpenseCategory.subscription;
    _recurrence = expense?.recurrence ?? RecurrenceType.monthly;
    _dueDate = expense?.dueDate ?? DateTime.now().add(const Duration(days: 3));
    _status = expense?.status ?? PaymentStatus.unpaid;
    _nameFocusNode = FocusNode();
    _amountFocusNode = FocusNode();
    _notesFocusNode = FocusNode();
    _nameController.addListener(_applySuggestion);
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_applySuggestion)
      ..dispose();
    _amountController.dispose();
    _notesController.dispose();
    _nameFocusNode.dispose();
    _amountFocusNode.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  void _applySuggestion() {
    final String value = _nameController.text.trim().toLowerCase();
    for (final MapEntry<String, ExpenseCategory> entry
        in _smartSuggestions.entries) {
      if (value.contains(entry.key)) {
        setState(() {
          _category = entry.value;
          _suggestedLabel = _categoryLabel(entry.value);
        });
        break;
      }
    }
  }

  Future<void> _pickDueDate() async {
    final DateTime now = DateTime.now();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.emerald,
                ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      setState(() => _dueDate = selected);
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double? amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      return;
    }

    final Expense draft = Expense(
      id: widget.expense?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      amount: amount,
      category: _category,
      recurrence: _recurrence,
      dueDate: _dueDate,
      status: _status,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: widget.expense?.createdAt ?? DateTime.now(),
    );

    if (widget.expense == null) {
      ref.read(expenseControllerProvider.notifier).addExpense(draft);
    } else {
      ref.read(expenseControllerProvider.notifier).updateExpense(draft);
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.expense != null ? 'Expense updated.' : 'Expense added.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.expense != null;
    final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: AppColors.border),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 54,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isEditing ? 'Edit expense' : 'Add expense',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keep it quick: name, amount, category, and due date.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    autofocus: widget.expense == null,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _amountFocusNode.requestFocus(),
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Netflix, Rent, Meralco...',
                    ),
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter an expense name.';
                      }
                      return null;
                    },
                  ),
                  if (_suggestedLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Suggested category: $_suggestedLabel',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.emerald,
                            ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _amountController,
                    focusNode: _amountFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _notesFocusNode.requestFocus(),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Amount in PHP',
                      prefixText: 'PHP ',
                    ),
                    validator: (String? value) {
                      final double? amount = double.tryParse(value?.trim() ?? '');
                      if (amount == null || amount <= 0) {
                        return 'Enter a valid amount.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownMenu<ExpenseCategory>(
                    key: ValueKey<ExpenseCategory>(_category),
                    initialSelection: _category,
                    width: double.infinity,
                    label: const Text('Category'),
                    inputDecorationTheme: const InputDecorationTheme(
                      border: OutlineInputBorder(),
                    ),
                    textStyle: Theme.of(context).textTheme.titleMedium,
                    dropdownMenuEntries: ExpenseCategory.values
                        .map(
                          (ExpenseCategory item) => DropdownMenuEntry(
                            value: item,
                            label: _categoryLabel(item),
                          ),
                        )
                        .toList(),
                    onSelected: (ExpenseCategory? value) {
                      if (value != null) {
                        setState(() {
                          _category = value;
                          _suggestedLabel = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<RecurrenceType>(
                    showSelectedIcon: false,
                    segments: RecurrenceType.values
                        .map(
                          (RecurrenceType item) => ButtonSegment<RecurrenceType>(
                            value: item,
                            label: Text(_recurrenceLabel(item)),
                          ),
                        )
                        .toList(),
                    selected: <RecurrenceType>{_recurrence},
                    onSelectionChanged: (Set<RecurrenceType> value) {
                      setState(() => _recurrence = value.first);
                    },
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: _pickDueDate,
                    borderRadius: BorderRadius.circular(18),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Due date'),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '${_dueDate.month}/${_dueDate.day}/${_dueDate.year}',
                            ),
                          ),
                          const Icon(Icons.calendar_month_rounded),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile.adaptive(
                    value: _status == PaymentStatus.paid,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.emerald,
                    title: const Text('Mark as paid'),
                    subtitle: Text(
                      _status == PaymentStatus.paid
                          ? 'This expense will stay out of open dues.'
                          : 'Keep this off if the payment is still pending.',
                    ),
                    onChanged: (bool value) {
                      setState(() {
                        _status = value
                            ? PaymentStatus.paid
                            : (_dueDate.isBefore(DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                              ))
                                ? PaymentStatus.overdue
                                : PaymentStatus.unpaid);
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    focusNode: _notesFocusNode,
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Optional details',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submit,
                      child: Text(isEditing ? 'Save changes' : 'Create expense'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _categoryLabel(ExpenseCategory category) {
  switch (category) {
    case ExpenseCategory.subscription:
      return 'Subscription';
    case ExpenseCategory.bill:
      return 'Bill';
    case ExpenseCategory.loan:
      return 'Loan';
    case ExpenseCategory.oneTime:
      return 'One-time';
  }
}

String _recurrenceLabel(RecurrenceType recurrence) {
  switch (recurrence) {
    case RecurrenceType.monthly:
      return 'Monthly';
    case RecurrenceType.weekly:
      return 'Weekly';
    case RecurrenceType.oneTime:
      return 'One-time';
  }
}
