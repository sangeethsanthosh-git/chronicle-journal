import 'package:chronicle/core/widgets/book_spread_frame.dart';
import 'package:chronicle/core/widgets/desk_background.dart';
import 'package:chronicle/data/local/app_database.dart';
import 'package:chronicle/domain/models/journal_entry_with_details.dart';
import 'package:chronicle/domain/models/mood.dart';
import 'package:chronicle/features/journal/presentation/widgets/journal_page.dart';
import 'package:chronicle/features/journal/presentation/widgets/page_turn_controller.dart';
import 'package:chronicle/presentation/screens/book_reader/book_page_content_view.dart';
import 'package:chronicle/presentation/screens/book_reader/book_page_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookPaginator Tests', () {
    test('Paginates single long entry into chapter opening and continuation pages', () {
      final entry = JournalEntry(
        id: 'test-1',
        title: "WHAT'S THE WORST THAT COULD HAPPEN?",
        content:
            'Today was an unforgettable journey through the city streets.\n\n'
            'We met at the corner cafe just as the morning drizzle began to clear. '
            'The aroma of freshly roasted coffee and warm pastries filled the air. '
            'We talked for hours about old memories and dreams for the future.\n\n'
            'Later that afternoon, we walked through the old quarter, admiring the vintage bookshops '
            'and cobblestone alleys that felt untouched by modern time.',
        createdAt: DateTime(2026, 10, 4, 10, 0),
        updatedAt: DateTime(2026, 10, 4, 10, 0),
        entryDate: DateTime(2026, 10, 4),
        mood: 'happy',
        moodIntensity: 4,
        isFavorite: true,
        locationName: 'Paris',
        latitude: 48.8566,
        longitude: 2.3522,
        weatherSummary: 'Sunny',
        weatherTemperature: 22.0,
        paperStyle: 'ruled',
        layout: 'classic',
      );

      final entryWithDetails = JournalEntryWithDetails(
        entry: entry,
        tags: [const Tag(id: 't1', name: 'Travel', colorHex: '0xFFC5A059')],
        attachments: [
          Attachment(
            id: 'a1',
            entryId: 'test-1',
            type: 'image',
            uri: 'https://example.com/photo.jpg',
            caption: 'Cafe morning',
            createdAt: DateTime.now(),
          ),
        ],
      );

      final pages = BookPaginator.paginate(entryWithDetails);

      expect(pages.length, greaterThanOrEqualTo(2));
      expect(pages.first.type, equals(BookPageType.chapterOpening));
      expect(pages.first.hasDropCap, isTrue);
      expect(pages.first.title, equals("WHAT'S THE WORST THAT COULD HAPPEN?"));
      expect(pages.first.location, equals('Paris'));
      expect(pages.first.weather, contains('Sunny'));
      expect(pages.first.photoPath, equals('https://example.com/photo.jpg'));

      final lastPage = pages.last;
      expect(lastPage.tags, contains('Travel'));
      expect(lastPage.isFavorite, isTrue);
    });
  });

  group('Book Reader Widgets Render Tests', () {
    testWidgets('Renders DeskBackground with wooden desk props', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeskBackground(
              child: Center(child: Text('Test Desk Content')),
            ),
          ),
        ),
      );

      expect(find.text('Test Desk Content'), findsOneWidget);
    });

    testWidgets('Renders BookSpreadFrame and BookPageContentView', (
      tester,
    ) async {
      final validPageData = BookPageData(
        pageNumber: 1,
        totalPages: 2,
        type: BookPageType.chapterOpening,
        title: 'AUTUMN AFTERNOON',
        text:
            'The golden leaves swirled through the park as autumn arrived in full splendor.',
        hasDropCap: true,
        date: DateTime(2026, 10, 4),
        location: 'Central Park',
        weather: 'Crisp • 18°C',
        mood: Mood.all.first,
        moodIntensity: 4,
        tags: ['Autumn', 'Reflection'],
        isFavorite: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookSpreadFrame(
              child: BookPageContentView(page: validPageData),
            ),
          ),
        ),
      );

      expect(find.text('AUTUMN AFTERNOON'), findsOneWidget);
      expect(find.text('— 1 —'), findsOneWidget);
    });

    test('JournalPageContent.fromEntry produces at least 4 pages (2 full spreads)', () {
      final entry = JournalEntry(
        id: 'test-simple',
        title: 'Morning Walk',
        content: 'A quick quiet morning walk around the neighborhood park.',
        createdAt: DateTime(2026, 10, 4),
        updatedAt: DateTime(2026, 10, 4),
        entryDate: DateTime(2026, 10, 4),
        mood: 'happy',
        moodIntensity: 3,
        isFavorite: false,
        paperStyle: 'ruled',
        layout: 'classic',
      );

      final entryWithDetails = JournalEntryWithDetails(
        entry: entry,
        tags: const [],
        attachments: const [],
      );

      final pages = JournalPageContent.fromEntry(entryWithDetails);

      // Must have at least 4 pages (2 spreads) so canTurnForward and canTurnBackward are active
      expect(pages.length, greaterThanOrEqualTo(4));
      expect(pages[0].type, equals(JournalPageType.textOpening));
      expect(pages[1].type, equals(JournalPageType.textContinuation));
      expect(pages[2].type, equals(JournalPageType.scrapbook));
      expect(pages[3].type, equals(JournalPageType.quoteReflection));
    });

    test('PageTurnController turns forward and backward across spreads smoothly', () async {
      final controller = PageTurnController();
      controller.setTotalSpreads(3);

      expect(controller.currentSpreadIndex, equals(0));
      expect(controller.canTurnForward, isTrue);
      expect(controller.canTurnBackward, isFalse);

      // Turn forward to spread 1
      await controller.nextPage();
      expect(controller.currentSpreadIndex, equals(1));
      expect(controller.canTurnForward, isTrue);
      expect(controller.canTurnBackward, isTrue);

      // Turn forward to spread 2 (last spread)
      await controller.nextPage();
      expect(controller.currentSpreadIndex, equals(2));
      expect(controller.canTurnForward, isFalse);
      expect(controller.canTurnBackward, isTrue);

      // Turn backward to spread 1
      await controller.previousPage();
      expect(controller.currentSpreadIndex, equals(1));
      expect(controller.canTurnForward, isTrue);
      expect(controller.canTurnBackward, isTrue);

      // Turn backward to spread 0
      await controller.previousPage();
      expect(controller.currentSpreadIndex, equals(0));
      expect(controller.canTurnForward, isTrue);
      expect(controller.canTurnBackward, isFalse);
    });
  });
}
