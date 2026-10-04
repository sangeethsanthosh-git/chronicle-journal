import 'package:chronicle/data/local/app_database.dart';
import 'package:chronicle/domain/models/journal_entry_with_details.dart';
import 'package:chronicle/features/achievements/domain/usecases/evaluate_achievements_usecase.dart';
import 'package:chronicle/features/journal_reader/presentation/widgets/codex_achievements_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Achievements Evaluation Tests', () {
    late EvaluateAchievementsUseCase useCase;

    setUp(() {
      useCase = EvaluateAchievementsUseCase();
    });

    test('Evaluates empty activity as locked initial achievements', () {
      final achievements = useCase.execute(
        entries: [],
        streak: 0,
        journalVolumeCount: 0,
      );

      expect(achievements.length, equals(10));
      expect(achievements.every((a) => !a.isUnlocked), isTrue);
      expect(achievements.first.title, equals('First Page'));
    });

    test(
      'Unlocks First Page, Gentle Rhythm, and Photo Collector when criteria met',
      () {
        final entry = JournalEntry(
          id: 'e1',
          title: 'Morning in Munnar',
          content:
              'A wonderful journey across green hills with fresh cool mist.',
          createdAt: DateTime(2026, 9, 1),
          updatedAt: DateTime(2026, 9, 1),
          entryDate: DateTime(2026, 9, 1),
          locationName: 'Munnar',
          layout: 'classic',
          paperStyle: 'plain',
          isFavorite: false,
          moodIntensity: 3,
        );

        final entryWithDetails = JournalEntryWithDetails(
          entry: entry,
          tags: [],
          attachments: List.generate(
            5,
            (i) => Attachment(
              id: 'a$i',
              entryId: 'e1',
              uri: 'path/to/photo$i.jpg',
              type: 'image',
              createdAt: DateTime.now(),
            ),
          ),
        );

        final achievements = useCase.execute(
          entries: [entryWithDetails],
          streak: 3,
          journalVolumeCount: 2,
        );

        final firstPage = achievements.firstWhere((a) => a.id == 'first_page');
        final gentleRhythm = achievements.firstWhere((a) => a.id == 'streak_3');
        final photoCollector = achievements.firstWhere(
          (a) => a.id == 'photo_collector',
        );
        final libraryArchitect = achievements.firstWhere(
          (a) => a.id == 'library_architect',
        );

        expect(firstPage.isUnlocked, isTrue);
        expect(gentleRhythm.isUnlocked, isTrue);
        expect(photoCollector.isUnlocked, isTrue);
        expect(libraryArchitect.isUnlocked, isTrue);
      },
    );

    testWidgets(
      'CodexAchievementsPage renders streak, progress bar, and seals',
      (tester) async {
        final achievements = useCase.execute(
          entries: [],
          streak: 5,
          journalVolumeCount: 1,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CodexAchievementsPage(
                achievements: achievements,
                streak: 5,
                totalEntries: 12,
              ),
            ),
          ),
        );

        expect(find.text('MIORA CODEX'), findsOneWidget);
        expect(find.text('5 d'), findsOneWidget);
        expect(find.text('12 Entries'), findsOneWidget);
        expect(find.text('Writing Rhythm'), findsOneWidget);
      },
    );
  });
}
