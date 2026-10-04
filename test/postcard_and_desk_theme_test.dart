import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chronicle/core/theme/desk_theme.dart';
import 'package:chronicle/core/widgets/postcard_editor_dialog.dart';
import 'package:chronicle/core/widgets/vintage_postcard_widget.dart';
import 'package:chronicle/presentation/providers/desk_theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeskTheme Tests', () {
    test('DeskThemeData contains 5 distinct physical desk themes', () {
      expect(DeskThemeType.values.length, 5);

      final slate = DeskThemeData.getTheme(DeskThemeType.slateBlue);
      expect(slate.name, contains('Slate Blue'));
      expect(slate.deskColor, const Color(0xFF384756));

      final walnut = DeskThemeData.getTheme(DeskThemeType.walnutTimber);
      expect(walnut.name, contains('Walnut'));
      expect(walnut.deskColor, const Color(0xFF3E2718));

      final cozy = DeskThemeData.getTheme(DeskThemeType.cozyStudy);
      expect(cozy.name, contains('Cozy Study'));

      final green = DeskThemeData.getTheme(DeskThemeType.vintageGreen);
      expect(green.name, contains('Library Felt Green'));

      final midnight = DeskThemeData.getTheme(DeskThemeType.midnightCharcoal);
      expect(midnight.name, contains('Midnight Charcoal'));
    });

    test('DeskThemeNotifier updates state correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();

      expect(container.read(deskThemeProvider), DeskThemeType.slateBlue);

      await container
          .read(deskThemeProvider.notifier)
          .setTheme(DeskThemeType.walnutTimber);
      expect(container.read(deskThemeProvider), DeskThemeType.walnutTimber);

      await container
          .read(deskThemeProvider.notifier)
          .setTheme(DeskThemeType.vintageGreen);
      expect(container.read(deskThemeProvider), DeskThemeType.vintageGreen);

      container.dispose();
    });
  });

  group('Postcard Customization & Editor Tests', () {
    test('PostcardCustomizationData copyWith works accurately', () {
      final initial = PostcardCustomizationData(
        message: 'Hello future self',
        recipient: 'To: Future Self',
        location: 'PARIS',
        date: DateTime(2026, 10, 4),
      );

      final updated = initial.copyWith(
        message: 'New message written',
        location: 'KYOTO',
      );

      expect(updated.message, 'New message written');
      expect(updated.location, 'KYOTO');
      expect(updated.recipient, 'To: Future Self');
      expect(updated.date, DateTime(2026, 10, 4));
    });

    testWidgets('VintagePostcardWidget with isEditable triggers onEdit', (
      tester,
    ) async {
      bool editTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VintagePostcardWidget(
                message: 'Scenic memories',
                date: DateTime(2026, 10, 4),
                isEditable: true,
                onEdit: () {
                  editTapped = true;
                },
              ),
            ),
          ),
        ),
      );

      final editButton = find.byTooltip('Edit Postcard');
      expect(editButton, findsOneWidget);

      await tester.tap(editButton);
      await tester.pumpAndSettle();

      expect(editTapped, isTrue);
    });

    testWidgets(
      'PostcardEditorDialog renders live preview and allows editing',
      (tester) async {
        PostcardCustomizationData? savedData;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PostcardEditorDialog(
                initialData: PostcardCustomizationData(
                  message: 'Original draft message',
                  recipient: 'To: Explorer',
                  location: 'PARIS, FRANCE',
                  date: DateTime(2026, 10, 4),
                ),
                onSave: (data) {
                  savedData = data;
                },
              ),
            ),
          ),
        );

        expect(find.text('Customize Vintage Postcard'), findsOneWidget);
        expect(find.text('Original draft message'), findsWidgets);

        // Verify Save Postcard button is visible
        final saveBtn = find.text('Save Postcard');
        expect(saveBtn, findsOneWidget);

        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        expect(savedData, isNotNull);
        expect(savedData!.message, 'Original draft message');
        expect(savedData!.recipient, 'To: Explorer');
      },
    );
  });
}
