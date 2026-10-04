import 'package:flutter_test/flutter_test.dart';
import 'package:chronicle/data/local/app_database.dart';
import 'package:chronicle/domain/models/journal_entry_with_details.dart';
import 'package:chronicle/domain/models/mood.dart';
import 'package:chronicle/domain/usecases/get_statistics_usecase.dart';

void main() {
  late GetStatisticsUseCase useCase;

  setUp(() {
    useCase = GetStatisticsUseCase();
  });

  test('Calculates word count, photos, audio, and mood counts accurately', () {
    final entries = [
      JournalEntryWithDetails(
        entry: JournalEntry(
          id: '1',
          title: 'Morning Sun',
          content: 'The morning breeze was refreshing and gentle on my face.',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          entryDate: DateTime.now(),
          mood: 'happy',
          moodIntensity: 4,
          isFavorite: true,
          layout: 'classic',
          paperStyle: 'plain',
        ),
        attachments: [
          Attachment(
            id: 'a1',
            entryId: '1',
            uri: '/path/photo1.jpg',
            type: 'image',
            createdAt: DateTime.now(),
          ),
          Attachment(
            id: 'a2',
            entryId: '1',
            uri: '/path/audio1.m4a',
            type: 'audio',
            createdAt: DateTime.now(),
          ),
        ],
        tags: [const Tag(id: 't1', name: 'gratitude', colorHex: '#C5A059')],
      ),
    ];

    final stats = useCase.execute(entries);
    expect(stats.totalEntries, 1);
    expect(stats.photosAdded, 1);
    expect(stats.audioRecordings, 1);
    expect(stats.totalWordCount, 10);
    expect(stats.mostCommonMood?.type, MoodType.happy);
    expect(stats.mostUsedTags['gratitude'], 1);
  });
}
