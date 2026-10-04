import 'package:flutter_test/flutter_test.dart';
import 'package:chronicle/data/local/app_database.dart';
import 'package:chronicle/domain/models/journal_entry_with_details.dart';
import 'package:chronicle/domain/usecases/get_memories_usecase.dart';

void main() {
  late GetMemoriesUseCase useCase;

  setUp(() {
    useCase = GetMemoriesUseCase();
  });

  test('Finds exact day/month anniversaries from prior years', () {
    final now = DateTime(2026, 10, 4, 12, 0);

    final entries = [
      JournalEntryWithDetails(
        entry: JournalEntry(
          id: '1',
          title: 'Memory 1',
          content: 'One year ago memory',
          createdAt: DateTime(2025, 10, 4),
          updatedAt: DateTime(2025, 10, 4),
          entryDate: DateTime(2025, 10, 4, 10, 0),
          moodIntensity: 3,
          isFavorite: false,
          layout: 'classic',
          paperStyle: 'plain',
        ),
      ),
      JournalEntryWithDetails(
        entry: JournalEntry(
          id: '2',
          title: 'Memory 2',
          content: 'Two years ago memory',
          createdAt: DateTime(2024, 10, 4),
          updatedAt: DateTime(2024, 10, 4),
          entryDate: DateTime(2024, 10, 4, 15, 0),
          moodIntensity: 3,
          isFavorite: false,
          layout: 'classic',
          paperStyle: 'plain',
        ),
      ),
      JournalEntryWithDetails(
        entry: JournalEntry(
          id: '3',
          title: 'Today Entry',
          content: 'Current year entry (not a memory flashback)',
          createdAt: DateTime(2026, 10, 4),
          updatedAt: DateTime(2026, 10, 4),
          entryDate: DateTime(2026, 10, 4, 8, 0),
          moodIntensity: 3,
          isFavorite: false,
          layout: 'classic',
          paperStyle: 'plain',
        ),
      ),
    ];

    final memories = useCase.execute(entries, targetDate: now);
    expect(memories.length, 2);
    expect(memories.first.yearsAgo, 2);
    expect(memories.first.timeAgoDescription, '2 years ago today');
    expect(memories.last.yearsAgo, 1);
    expect(memories.last.timeAgoDescription, '1 year ago today');
  });
}
