package com.chronicle.journal.domain.usecase

import com.chronicle.journal.core.common.TimeUtils
import com.chronicle.journal.domain.model.JournalStatistics
import com.chronicle.journal.domain.model.Mood
import com.chronicle.journal.domain.repository.JournalRepository
import kotlinx.coroutines.flow.first
import java.time.LocalDate
import java.time.YearMonth
import java.time.format.DateTimeFormatter
import java.util.Locale
import javax.inject.Inject

class GetStatisticsUseCase
    @Inject
    constructor(
        private val journalRepository: JournalRepository,
        private val calculateStreakUseCase: CalculateStreakUseCase,
    ) {
        suspend fun execute(): JournalStatistics {
            val entries = journalRepository.getAllEntries().first()
            val totalPhotos = journalRepository.getTotalPhotosCount()
            val totalAudio = journalRepository.getTotalAudioCount()
            val allDates = journalRepository.getAllEntryDates()

            val now = LocalDate.now()
            val currentYearMonth = YearMonth.now()
            val currentYear = now.year

            var entriesThisMonth = 0
            var entriesThisYear = 0
            var totalWords = 0
            val moodCounts = mutableMapOf<Mood, Int>()
            val tagCounts = mutableMapOf<Pair<Long, String>, Int>()
            val tagMap = mutableMapOf<Pair<Long, String>, com.chronicle.journal.domain.model.Tag>()
            val monthlyCounts = mutableMapOf<String, Int>()

            // Initialize last 6 months in order
            for (i in 5 downTo 0) {
                val ym = currentYearMonth.minusMonths(i.toLong())
                val label = ym.format(DateTimeFormatter.ofPattern("MMM", Locale.getDefault()))
                monthlyCounts[label] = 0
            }

            entries.forEach { details ->
                val entry = details.entry
                val entryDate = TimeUtils.toLocalDate(entry.entryDate)

                // Month and Year counts
                if (entryDate.year == currentYear) {
                    entriesThisYear++
                    if (entryDate.month == now.month) {
                        entriesThisMonth++
                    }
                }

                // Monthly activity distribution
                val monthLabel = entryDate.format(DateTimeFormatter.ofPattern("MMM", Locale.getDefault()))
                if (monthlyCounts.containsKey(monthLabel)) {
                    monthlyCounts[monthLabel] = (monthlyCounts[monthLabel] ?: 0) + 1
                }

                // Word count
                val words = entry.content.split("\\s+".toRegex()).count { it.isNotBlank() }
                totalWords += words

                // Mood counts
                moodCounts[entry.mood] = (moodCounts[entry.mood] ?: 0) + 1

                // Tag counts
                details.tags.forEach { tag ->
                    val key = Pair(tag.id, tag.name)
                    tagCounts[key] = (tagCounts[key] ?: 0) + 1
                    tagMap[key] = tag
                }
            }

            val mostCommonMood = moodCounts.maxByOrNull { it.value }?.key
            val topTags =
                tagCounts.entries
                    .sortedByDescending { it.value }
                    .take(5)
                    .map { (key, count) ->
                        tagMap[key]!! to count
                    }

            val streakInfo = calculateStreakUseCase.execute(allDates, now)

            return JournalStatistics(
                totalEntries = entries.size,
                entriesThisMonth = entriesThisMonth,
                entriesThisYear = entriesThisYear,
                streakInfo = streakInfo,
                totalWordsWritten = totalWords,
                totalPhotosCount = totalPhotos,
                totalAudioCount = totalAudio,
                mostCommonMood = mostCommonMood,
                moodDistribution = moodCounts,
                topTags = topTags,
                monthlyActivity = monthlyCounts,
            )
        }
    }
