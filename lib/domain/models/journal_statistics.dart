import 'mood.dart';

class JournalStatistics {
  final int totalEntries;
  final int currentStreak;
  final int longestStreak;
  final int entriesThisMonth;
  final Mood? mostCommonMood;
  final Map<MoodType, int> moodDistribution;
  final Map<String, int> mostUsedTags;
  final int photosAdded;
  final int audioRecordings;
  final int totalWordCount;
  final Map<String, int> monthlyActivity; // e.g. "Jan": 12, "Feb": 18

  const JournalStatistics({
    required this.totalEntries,
    required this.currentStreak,
    required this.longestStreak,
    required this.entriesThisMonth,
    this.mostCommonMood,
    required this.moodDistribution,
    required this.mostUsedTags,
    required this.photosAdded,
    required this.audioRecordings,
    required this.totalWordCount,
    required this.monthlyActivity,
  });

  factory JournalStatistics.empty() {
    return const JournalStatistics(
      totalEntries: 0,
      currentStreak: 0,
      longestStreak: 0,
      entriesThisMonth: 0,
      mostCommonMood: null,
      moodDistribution: {},
      mostUsedTags: {},
      photosAdded: 0,
      audioRecordings: 0,
      totalWordCount: 0,
      monthlyActivity: {},
    );
  }
}
