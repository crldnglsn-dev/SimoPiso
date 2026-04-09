import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/expense.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/services/export_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _dailySummary = true;
  bool _isExporting = false;

  Future<void> _sharePdf() async {
    setState(() => _isExporting = true);
    try {
      final List<Expense> expenses = ref.read(expenseControllerProvider);
      await ref.read(exportServiceProvider).shareMonthlyPdf(expenses);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF report ready to share.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create the PDF report.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _shareCsv() async {
    setState(() => _isExporting = true);
    try {
      final List<Expense> expenses = ref.read(expenseControllerProvider);
      await ref.read(exportServiceProvider).shareMonthlyCsv(expenses);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV export ready to share.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create the CSV export.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ExpenseInsights insights = ref.watch(expenseInsightsProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: <Widget>[
          Text(
            'Settings',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Android-first preferences for reminders, exports, and display.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Your data',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Expenses are stored locally on this device. You currently have ${insights.totalCount} saved item(s).',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  value: _notificationsEnabled,
                  activeThumbColor: AppColors.emerald,
                  onChanged: (bool value) {
                    setState(() => _notificationsEnabled = value);
                  },
                  title: const Text('Due date reminders'),
                  subtitle: const Text('3 days before and 1 day before'),
                ),
                const Divider(height: 1, color: AppColors.border),
                SwitchListTile(
                  value: _dailySummary,
                  activeThumbColor: AppColors.emerald,
                  onChanged: (bool value) {
                    setState(() => _dailySummary = value);
                  },
                  title: const Text('Daily 8AM summary'),
                  subtitle: const Text('Weekly due total at a glance'),
                ),
                const Divider(height: 1, color: AppColors.border),
                const ListTile(
                  title: Text('Currency'),
                  subtitle: Text('PHP (Philippine Peso)'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  title: Text('Export monthly report'),
                  subtitle: Text(
                    _isExporting
                        ? 'Preparing export...'
                        : 'PDF / CSV share sheet',
                  ),
                  trailing: _isExporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.ios_share_rounded),
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  enabled: !_isExporting,
                  onTap: _sharePdf,
                  title: const Text('Share PDF report'),
                  subtitle: const Text('Clean monthly summary for budgeting'),
                  trailing: const Icon(Icons.picture_as_pdf_outlined),
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  enabled: !_isExporting,
                  onTap: _shareCsv,
                  title: const Text('Share CSV export'),
                  subtitle: const Text('Spreadsheet-friendly expense data'),
                  trailing: const Icon(Icons.table_chart_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
