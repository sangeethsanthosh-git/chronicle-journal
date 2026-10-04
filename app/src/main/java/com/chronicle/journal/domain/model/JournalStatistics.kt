package com.chronicle.journal.domain.model

data class StreakInfo(
    val currentStreak: Int = 0,
    val longestStreak: Int = 0,
    val totalActiveDays: Int = 0,
    val lastEntryDate: Long? = null,
)

data class JournalStatistics(
    val totalEntries: Int = 0,
    val entriesThisMonth: Int = 0,
    val entriesThisYear: Int = 0,
    val streakInfo: StreakInfo = StreakInfo(),
    val totalWordsWritten: Int = 0,
    val totalPhotosCount: Int = 0,
    val totalAudioCount: Int = 0,
    val mostCommonMood: Mood? = null,
    val moodDistribution: Map<Mood, Int> = emptyMap(),
    val topTags: List<Pair<Tag, Int>> = emptyList(),
    val monthlyActivity: Map<String, Int> = emptyMap(), // e.g. "Jan" -> 5, "Feb" -> 12
)

data class MemoryItem(
    val entryWithDetails: JournalWithDetails,
    val yearsAgo: Int,
    val formattedDate: String,
)
