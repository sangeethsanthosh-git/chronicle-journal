import 'package:chronicle/features/journal_stack/domain/models/journal_stack_item.dart';
import 'package:chronicle/features/journal_stack/presentation/widgets/journal_book_cover.dart';
import 'package:chronicle/features/journal_stack/presentation/widgets/journal_book_preview.dart';
import 'package:chronicle/features/journal_stack/presentation/widgets/journal_book_spine.dart';
import 'package:chronicle/features/journal_stack/presentation/widgets/journal_empty_state.dart';
import 'package:chronicle/features/journal_stack/presentation/widgets/journal_shelf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JournalStackItem Domain Model Tests', () {
    test('Calculates deterministic physical variation from id', () {
      final book1 = JournalStackItem(
        id: 'book-autumn-2026',
        title: 'Autumn Reflections',
        description: 'Quiet moments in the forest',
        category: JournalCategory.personal,
        spineColor: const Color(0xFFC86D51),
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 10, 4),
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 10, 4),
        entryCount: 12,
        photoCount: 8,
      );

      final book2 = JournalStackItem(
        id: 'book-travel-tokyo',
        title: 'Tokyo Notes',
        category: JournalCategory.travel,
        spineColor: const Color(0xFF3D6B7D),
        createdAt: DateTime(2026, 4, 1),
        updatedAt: DateTime(2026, 5, 1),
        entryCount: 20,
        photoCount: 45,
      );

      expect(book1.spineHeight, inInclusiveRange(150.0, 185.0));
      expect(book2.spineHeight, inInclusiveRange(150.0, 185.0));

      expect(book1.spineThickness, inInclusiveRange(28.0, 38.0));
      expect(book2.spineThickness, inInclusiveRange(28.0, 38.0));

      expect(book1.tiltAngle, inInclusiveRange(-0.04, 0.04));
      expect(book1.spineBandCount, inInclusiveRange(1, 3));

      expect(book1.dateRangeText, contains('Sep 2026'));
      expect(book1.semanticLabel, contains('Autumn Reflections'));
      expect(book1.semanticLabel, contains('12 entries'));
    });

    test('JournalCategory parses strings safely', () {
      expect(
        JournalCategory.fromString('TRAVEL'),
        equals(JournalCategory.travel),
      );
      expect(
        JournalCategory.fromString('study'),
        equals(JournalCategory.study),
      );
      expect(
        JournalCategory.fromString('UNKNOWN_XYZ'),
        equals(JournalCategory.custom),
      );
      expect(
        JournalCategory.fromString(null),
        equals(JournalCategory.personal),
      );
    });
  });

  group('Journal Stack Widgets Tests', () {
    late JournalStackItem testItem;

    setUp(() {
      testItem = JournalStackItem(
        id: 'test-volume-1',
        title: 'Morning Pages',
        description: 'Daily reflections before sunrise',
        category: JournalCategory.personal,
        spineColor: const Color(0xFFC86D51),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 10, 4),
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 10, 4),
        entryCount: 42,
        photoCount: 15,
        moodSummary: 'Mostly Peaceful',
      );
    });

    testWidgets(
      'JournalBookSpine renders title, entry count, and responds to tap',
      (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: JournalBookSpine(
                  item: testItem,
                  isSelected: false,
                  isDimmed: false,
                  showFloatingTag: true,
                  onTap: () => tapped = true,
                ),
              ),
            ),
          ),
        );

        expect(find.text('MORNING PAGES'), findsOneWidget);
        expect(find.text('42'), findsOneWidget);
        expect(
          find.text('Morning Pages'),
          findsOneWidget,
        ); // Floating paper pill tag

        await tester.tap(find.byType(JournalBookSpine));
        await tester.pump();

        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'JournalBookCover displays prominent title, category, and date range',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: JournalBookCover(
                  item: testItem,
                  width: 200,
                  height: 280,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Morning Pages'), findsOneWidget);
        expect(find.text('PERSONAL'), findsOneWidget);
        expect(find.text('Daily reflections before sunrise'), findsOneWidget);
        expect(find.textContaining('42 ENTRIES'), findsOneWidget);
      },
    );

    testWidgets('JournalShelf renders books and add slot', (tester) async {
      bool added = false;
      String? selectedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JournalShelf(
              books: [testItem],
              selectedJournalId: null,
              onSelectBook: (id) => selectedId = id,
              onAddBook: () => added = true,
            ),
          ),
        ),
      );

      expect(find.byType(JournalBookSpine), findsOneWidget);
      expect(find.text('NEW VOLUME'), findsOneWidget);

      await tester.tap(find.text('NEW VOLUME'));
      await tester.pump();
      expect(added, isTrue);

      await tester.tap(find.byType(JournalBookSpine));
      await tester.pump();
      expect(selectedId, equals('test-volume-1'));
    });

    testWidgets(
      'JournalEmptyState displays cozy character message and button',
      (tester) async {
        bool createTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JournalEmptyState(
                onCreateJournal: () => createTapped = true,
                isArchivedMode: false,
              ),
            ),
          ),
        );

        expect(
          find.text('Your shelf is waiting for its first story.'),
          findsOneWidget,
        );
        expect(find.text('CREATE FIRST JOURNAL'), findsOneWidget);

        await tester.tap(find.text('CREATE FIRST JOURNAL'));
        await tester.pump();
        expect(createTapped, isTrue);
      },
    );

    testWidgets(
      'JournalBookPreview shows complete stats and OPEN JOURNAL button',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        bool opened = false;
        bool edited = false;
        bool archived = false;
        bool deleted = false;
        bool closed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JournalBookPreview(
                item: testItem,
                onOpenJournal: () => opened = true,
                onEdit: () => edited = true,
                onToggleArchive: () => archived = true,
                onDelete: () => deleted = true,
                onClose: () => closed = true,
              ),
            ),
          ),
        );

        expect(find.text('Morning Pages'), findsWidgets);
        expect(find.text('42'), findsOneWidget);
        expect(find.text('15'), findsOneWidget);
        expect(find.text('Mostly Peaceful'), findsOneWidget);
        expect(find.text('OPEN JOURNAL'), findsOneWidget);

        await tester.tap(find.text('OPEN JOURNAL'));
        await tester.pump();
        expect(opened, isTrue);

        await tester.tap(find.text('Edit'));
        await tester.pump();
        expect(edited, isTrue);

        await tester.tap(find.text('Archive'));
        await tester.pump();
        expect(archived, isTrue);

        await tester.tap(find.text('Delete'));
        await tester.pump();
        expect(deleted, isTrue);

        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();
        expect(closed, isTrue);
      },
    );
  });
}
