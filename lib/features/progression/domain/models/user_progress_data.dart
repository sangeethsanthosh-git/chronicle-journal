/// Model representing the user's sanctuary progression and Thought XP.
class UserProgressData {
  final int totalXp;
  final int currentLevel;
  final int totalEntriesWritten;
  final int totalMemoriesSaved;
  final int totalScrapbooksCreated;
  final DateTime? lastJournalDate;

  const UserProgressData({
    this.totalXp = 0,
    this.currentLevel = 1,
    this.totalEntriesWritten = 0,
    this.totalMemoriesSaved = 0,
    this.totalScrapbooksCreated = 0,
    this.lastJournalDate,
  });

  /// Titles for Sanctuary Tiers.
  String get sanctuaryTitle {
    if (currentLevel < 3) return 'The Novice Study';
    if (currentLevel < 5) return 'The Cozy Nook';
    if (currentLevel < 10) return 'The Flourishing Study';
    if (currentLevel < 15) return 'The Scholar\'s Haven';
    return 'The Celestial Archive';
  }

  /// XP threshold needed to reach the next level.
  int get xpForNextLevel => currentLevel * 100;

  /// Progress fraction towards next level (0.0 to 1.0).
  double get levelProgress {
    final currentLevelBaseXp = (currentLevel - 1) * 100;
    final xpInCurrentLevel = totalXp - currentLevelBaseXp;
    final xpNeeded = xpForNextLevel - currentLevelBaseXp;
    if (xpNeeded <= 0) return 1.0;
    return (xpInCurrentLevel / xpNeeded).clamp(0.0, 1.0);
  }

  /// Copies instance with modified properties.
  UserProgressData copyWith({
    int? totalXp,
    int? currentLevel,
    int? totalEntriesWritten,
    int? totalMemoriesSaved,
    int? totalScrapbooksCreated,
    DateTime? lastJournalDate,
  }) {
    return UserProgressData(
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      totalEntriesWritten: totalEntriesWritten ?? this.totalEntriesWritten,
      totalMemoriesSaved: totalMemoriesSaved ?? this.totalMemoriesSaved,
      totalScrapbooksCreated:
          totalScrapbooksCreated ?? this.totalScrapbooksCreated,
      lastJournalDate: lastJournalDate ?? this.lastJournalDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalXp': totalXp,
    'currentLevel': currentLevel,
    'totalEntriesWritten': totalEntriesWritten,
    'totalMemoriesSaved': totalMemoriesSaved,
    'totalScrapbooksCreated': totalScrapbooksCreated,
    'lastJournalDate': lastJournalDate?.toIso8601String(),
  };

  factory UserProgressData.fromJson(Map<String, dynamic> json) {
    return UserProgressData(
      totalXp: json['totalXp'] as int? ?? 0,
      currentLevel: json['currentLevel'] as int? ?? 1,
      totalEntriesWritten: json['totalEntriesWritten'] as int? ?? 0,
      totalMemoriesSaved: json['totalMemoriesSaved'] as int? ?? 0,
      totalScrapbooksCreated: json['totalScrapbooksCreated'] as int? ?? 0,
      lastJournalDate: json['lastJournalDate'] != null
          ? DateTime.tryParse(json['lastJournalDate'] as String)
          : null,
    );
  }
}
