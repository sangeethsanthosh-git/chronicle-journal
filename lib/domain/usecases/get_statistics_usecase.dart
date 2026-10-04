import 'package:intl/intl.dart';
import '../models/journal_entry_with_details.dart';
import '../models/journal_statistics.dart';
import '../models/mood.dart';
import 'calculate_streak_usecase.dart';

class GetStatisticsUseCase {
  final CalculateStreakUseCase calculateStreakUseCase;

  GetStatisticsUseCase({CalculateStreakUseCase? calculateStreak})
    : calculateStreakUseCase = calculateStreak ?? CalculateStreakUseCase();

  JournalStatistics execute(List<JournalEntryWithDetails> entries) {
    if (entries.isEmpty) {
      return JournalStatistics.empty();
    }

    final entryDates = entries.map((e) => e.entry.entryDate).toList();
    final streak = calculateStreakUseCase.execute(entryDates);

    final now = DateTime.now();
    final entriesThisMonth = entries.where((e) {
      final d = e.entry.entryDate;
      return d.year == now.year && d.month == now.month;
    }).length;

    // Mood distribution
    final Map<MoodType, int> moodMap = {};
    for (final e in entries) {
      final moodType = e.mood.type;
      moodMap[moodType] = (moodMap[moodType] ?? 0) + 1;
    }

    Mood? mostCommonMood;
    int maxMoodCount = 0;
    moodMap.forEach((type, count) {
      if (count > maxMoodCount) {
        maxMoodCount = count;
        mostCommonMood = Mood.all.firstWhere((m) => m.type == type);
      }
    });

    // Tag counts
    final Map<String, int> tagMap = {};
    for (final e in entries) {
      for (final t in e.tags) {
        tagMap[t.name] = (tagMap[t.name] ?? 0) + 1;
      }
    }

    int photosCount = 0;
    int audioCount = 0;
    int wordsCount = 0;
    final Map<String, int> monthlyActivity = {};

    final monthFormat = DateFormat('MMM yyyy');

    for (final e in entries) {
      photosCount += e.photoAttachments.length;
      audioCount += e.audioAttachments.length;
      wordsCount += e.wordCount;

      final monthKey = monthFormat.format(e.entry.entryDate);
      monthlyActivity[monthKey] = (monthlyActivity[monthKey] ?? 0) + 1;
    }

    return JournalStatistics(
      totalEntries: entries.length,
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      entriesThisMonth: entriesThisMonth,
      mostCommonMood: mostCommonMood,
      moodDistribution: moodMap,
      mostUsedTags: tagMap,
      photosAdded: photosCount,
      audioRecordings: audioCount,
      totalWordCount: wordsCount,
      monthlyActivity: monthlyActivity,
    );
  }
}
