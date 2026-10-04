import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chronicle/core/theme/desk_theme.dart';
import 'package:chronicle/domain/models/mood.dart';
import 'package:chronicle/features/journal/presentation/widgets/illustrated_study_environment.dart';
import 'package:chronicle/features/journal/presentation/widgets/journal_book.dart';
import 'package:chronicle/features/journal/presentation/widgets/journal_page.dart';
import 'package:chronicle/features/journal/presentation/widgets/journal_page_spread.dart';
import 'package:chronicle/features/journal/presentation/widgets/page_turn_controller.dart';
import 'package:chronicle/features/journal/presentation/widgets/paper_peel_engine.dart';

void main() {
  group('PageTurnController Tests', () {
    test('initializes with default values', () {
      final controller = PageTurnController();
      expect(controller.currentSpreadIndex, 0);
      expect(controller.totalSpreads, 1);
      expect(controller.dragProgress, 0.0);
      expect(controller.isDragging, false);
      expect(controller.isAnimating, false);
      expect(controller.canTurnBackward, false);
      expect(controller.canTurnForward, false);
    });

    test('updates total spreads and bounds correctly', () {
      final controller = PageTurnController();
      controller.setTotalSpreads(5);

      expect(controller.totalSpreads, 5);
      expect(controller.canTurnForward, true);
      expect(controller.canTurnBackward, false);

      controller.jumpToSpread(2);
      expect(controller.currentSpreadIndex, 2);
      expect(controller.canTurnForward, true);
      expect(controller.canTurnBackward, true);

      controller.jumpToSpread(4);
      expect(controller.currentSpreadIndex, 4);
      expect(controller.canTurnForward, false);
      expect(controller.canTurnBackward, true);
    });

    test('handles interactive drag gestures', () {
      final controller = PageTurnController();
      controller.setTotalSpreads(3);

      // Start forward drag
      controller.handleDragStart(forward: true);
      expect(controller.isDragging, true);
      expect(controller.isTurningForward, true);
      expect(controller.dragProgress, 0.0);

      // Drag update (finger moving left)
      controller.handleDragUpdate(-0.25);
      expect(controller.dragProgress, closeTo(0.25, 0.01));

      controller.handleDragUpdate(-0.5);
      expect(controller.dragProgress, closeTo(0.75, 0.01));
    });

    test('handles backward drag gesture', () {
      final controller = PageTurnController();
      controller.setTotalSpreads(3);
      controller.jumpToSpread(1);

      // Start backward drag
      controller.handleDragStart(forward: false);
      expect(controller.isDragging, true);
      expect(controller.isTurningForward, false);

      // Finger moving right
      controller.handleDragUpdate(0.3);
      expect(controller.dragProgress, closeTo(0.3, 0.01));
    });
  });

  group('Journal Page & Spread Widgets', () {
    testWidgets('JournalPage renders title and body text', (tester) async {
      final content = JournalPageContent(
        type: JournalPageType.textOpening,
        title: 'Autumn in Kyoto',
        bodyText: 'The morning mist hovered gently above the temple rooftops.',
        date: DateTime(2026, 10, 4),
        mood: Mood.all.first,
        pageNumber: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JournalPage(
              content: content,
              isLeftPage: true,
              paperColor: const Color(0xFFFAF7EE),
            ),
          ),
        ),
      );

      expect(find.text('Autumn in Kyoto'), findsOneWidget);
      expect(
        find.text(
          'The morning mist hovered gently above the temple rooftops.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.text('— 1 —'), findsOneWidget); // Page number
    });

    testWidgets('JournalPageSpread renders left and right pages', (
      tester,
    ) async {
      final leftContent = const JournalPageContent(
        type: JournalPageType.textOpening,
        title: 'Chapter I',
        bodyText: 'Beginnings of quiet reflection.',
        pageNumber: 1,
      );

      final rightContent = const JournalPageContent(
        type: JournalPageType.quoteReflection,
        quoteText: '“Every page turned preserves a piece of your journey.”',
        pageNumber: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 500,
              child: JournalPageSpread(
                leftContent: leftContent,
                rightContent: rightContent,
                paperColor: const Color(0xFFFAF7EE),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Chapter I'), findsOneWidget);
      expect(
        find.text('“Every page turned preserves a piece of your journey.”'),
        findsOneWidget,
      );
      expect(find.text('— 1 —'), findsOneWidget);
      expect(find.text('— 2 —'), findsOneWidget);
    });
  });

  group('IllustratedStudyEnvironment & JournalBook Widgets', () {
    testWidgets('IllustratedStudyEnvironment renders room environment', (
      tester,
    ) async {
      final theme = DeskThemeData.getTheme(DeskThemeType.walnutTimber);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IllustratedStudyEnvironment(
              isJournalOpen: true,
              deskTheme: theme,
              child: const Text('Journal Centerpiece'),
            ),
          ),
        ),
      );

      expect(find.text('Journal Centerpiece'), findsOneWidget);
      expect(find.byType(IllustratedStudyEnvironment), findsOneWidget);
    });

    testWidgets('JournalBook renders open journal and controls', (
      tester,
    ) async {
      final controller = PageTurnController();
      final spreads = [
        JournalPageSpread(
          leftContent: const JournalPageContent(
            type: JournalPageType.textOpening,
            title: 'My Journey',
            bodyText: 'First entry into the world.',
            pageNumber: 1,
          ),
          rightContent: const JournalPageContent(
            type: JournalPageType.quoteReflection,
            title: 'Reflection',
            bodyText: 'Small moments build a lifetime of wonder.',
            pageNumber: 2,
          ),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: JournalBook(
                spreads: spreads,
                controller: controller,
                initialOpen: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(JournalBook), findsOneWidget);
      expect(find.byType(PaperPeelPageTurn), findsOneWidget);
      expect(find.text('Spread 1 of 1'), findsOneWidget);
      expect(find.text('Landscape Spread'), findsOneWidget);
    });
  });
}
