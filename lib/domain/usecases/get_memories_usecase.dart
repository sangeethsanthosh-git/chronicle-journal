import '../models/journal_entry_with_details.dart';

class MemoryFlashback {
  final int yearsAgo;
  final JournalEntryWithDetails entry;

  const MemoryFlashback({required this.yearsAgo, required this.entry});

  String get timeAgoDescription {
    if (yearsAgo == 1) return '1 year ago today';
    return '$yearsAgo years ago today';
  }
}

class GetMemoriesUseCase {
  List<MemoryFlashback> execute(
    List<JournalEntryWithDetails> entries, {
    DateTime? targetDate,
  }) {
    final now = targetDate ?? DateTime.now();
    final List<MemoryFlashback> memories = [];

    for (final e in entries) {
      final entryDate = e.entry.entryDate;
      // Must match day and month, but be in a prior year
      if (entryDate.day == now.day &&
          entryDate.month == now.month &&
          entryDate.year < now.year) {
        final yearsAgo = now.year - entryDate.year;
        memories.add(MemoryFlashback(yearsAgo: yearsAgo, entry: e));
      }
    }

    memories.sort((a, b) => b.yearsAgo.compareTo(a.yearsAgo));
    return memories;
  }
}
