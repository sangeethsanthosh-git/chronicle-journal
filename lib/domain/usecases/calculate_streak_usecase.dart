class StreakResult {
  final int currentStreak;
  final int longestStreak;

  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
  });
}

class CalculateStreakUseCase {
  StreakResult execute(List<DateTime> entryDates) {
    if (entryDates.isEmpty) {
      return const StreakResult(currentStreak: 0, longestStreak: 0);
    }

    // Normalize dates to year-month-day set
    final uniqueDays =
        entryDates.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList()
          ..sort((a, b) => b.compareTo(a)); // Newest first

    if (uniqueDays.isEmpty) {
      return const StreakResult(currentStreak: 0, longestStreak: 0);
    }

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final yesterdayNormalized = todayNormalized.subtract(
      const Duration(days: 1),
    );

    // Calculate current streak
    int current = 0;
    final latest = uniqueDays.first;

    if (latest == todayNormalized || latest == yesterdayNormalized) {
      DateTime checkDate = latest;
      for (final date in uniqueDays) {
        if (date == checkDate) {
          current++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else if (date.isBefore(checkDate)) {
          break;
        }
      }
    }

    // Calculate longest streak across all history
    int longest = 0;
    int streakTracker = 0;
    DateTime? expected;

    for (final date in uniqueDays) {
      if (expected == null || date == expected) {
        streakTracker++;
        expected = date.subtract(const Duration(days: 1));
      } else {
        if (streakTracker > longest) {
          longest = streakTracker;
        }
        streakTracker = 1;
        expected = date.subtract(const Duration(days: 1));
      }
    }

    if (streakTracker > longest) {
      longest = streakTracker;
    }

    return StreakResult(
      currentStreak: current,
      longestStreak: longest > current ? longest : current,
    );
  }
}
