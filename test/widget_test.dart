import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simopiso/app.dart';
import 'package:simopiso/data/repositories/expense_repository.dart';

void main() {
  testWidgets('renders dashboard shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          expenseRepositoryProvider.overrideWithValue(MemoryExpenseRepository()),
        ],
        child: SimoPisoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your monthly load'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
  });
}
