import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/utils/currency_formatters.dart';
import '../../core/utils/date_helpers.dart';
import '../models/expense.dart';

final Provider<ExportService> exportServiceProvider =
    Provider<ExportService>((Ref ref) => ExportService());

class ExportService {
  Future<void> shareMonthlyPdf(List<Expense> expenses) async {
    final Uint8List bytes = await buildMonthlyPdf(expenses);
    final String monthLabel = formatMonthLabel(DateTime.now());
    final File file = await _writeTempFile(
      'simopiso-$monthLabel.pdf',
      bytes,
    );
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(file.path)],
        text: 'SimoPiso monthly PDF report',
      ),
    );
  }

  Future<void> shareMonthlyCsv(List<Expense> expenses) async {
    final String csv = buildMonthlyCsv(expenses);
    final File file = await _writeTempFile(
      'simopiso-${formatMonthLabel(DateTime.now())}.csv',
      Uint8List.fromList(csv.codeUnits),
    );
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(file.path)],
        text: 'SimoPiso monthly CSV export',
      ),
    );
  }

  Future<Uint8List> buildMonthlyPdf(List<Expense> expenses) async {
    final pw.Document document = pw.Document();
    final List<Expense> monthExpenses = expenses
        .where((Expense expense) => isThisMonth(expense.dueDate))
        .toList();
    final double total = monthExpenses.fold<double>(
      0,
      (double sum, Expense expense) => sum + expense.amount,
    );

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(28),
          theme: pw.ThemeData.base(),
        ),
        build: (pw.Context context) => <pw.Widget>[
          pw.Text(
            'SimoPiso Monthly Report',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green700,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(formatMonthLabel(DateTime.now())),
          pw.SizedBox(height: 18),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: <pw.Widget>[
                pw.Text('Total due this month'),
                pw.Text(
                  formatPhp(total),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
            headers: const <String>['Name', 'Due', 'Category', 'Status', 'Amount'],
            data: monthExpenses
                .map(
                  (Expense expense) => <String>[
                    expense.name,
                    formatShortDate(expense.dueDate),
                    expense.category.name,
                    expense.status.name,
                    formatPhp(expense.amount),
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    return document.save();
  }

  String buildMonthlyCsv(List<Expense> expenses) {
    final List<Expense> monthExpenses = expenses
        .where((Expense expense) => isThisMonth(expense.dueDate))
        .toList();
    final StringBuffer buffer = StringBuffer()
      ..writeln('Name,Amount,Category,Recurrence,Due Date,Status,Notes');

    for (final Expense expense in monthExpenses) {
      buffer.writeln(
        '"${expense.name.replaceAll('"', '""')}",${expense.amount},${expense.category.name},${expense.recurrence.name},${expense.dueDate.toIso8601String()},${expense.status.name},"${(expense.notes ?? '').replaceAll('"', '""')}"',
      );
    }

    return buffer.toString();
  }

  Future<File> _writeTempFile(String fileName, Uint8List bytes) async {
    final Directory directory = await getTemporaryDirectory();
    final String safeFileName = fileName.replaceAll(' ', '-');
    final File file = File('${directory.path}${Platform.pathSeparator}$safeFileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
