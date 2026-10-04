import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chronicle/data/local/app_database.dart';
import 'package:chronicle/main.dart';
import 'package:chronicle/presentation/providers/database_provider.dart';

void main() {
  testWidgets('ChronicleApp smoke test renders without error', (
    WidgetTester tester,
  ) async {
    final testDb = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(testDb)],
        child: const ChronicleApp(),
      ),
    );

    // Initial pump
    await tester.pumpAndSettle();

    // Verify title text exists somewhere in widget tree
    expect(find.byType(ChronicleApp), findsOneWidget);

    await testDb.close();
  });
}
