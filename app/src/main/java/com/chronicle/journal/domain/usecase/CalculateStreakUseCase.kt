package com.chronicle.journal.domain.usecase

import com.chronicle.journal.core.common.TimeUtils
import com.chronicle.journal.domain.model.StreakInfo
import java.time.LocalDate
import java.time.temporal.ChronoUnit
import javax.inject.Inject

class CalculateStreakUseCase
    @Inject
    constructor() {
        fun execute(
            entryTimestamps: List<Long>,
            referenceDate: LocalDate = LocalDate.now(),
        ): StreakInfo {
            if (entryTimestamps.isEmpty()) {
                return StreakInfo(0, 0, 0, null)
            }

            // Distinct local dates sorted descending
            val dates =
                entryTimestamps
                    .map { TimeUtils.toLocalDate(it) }
                    .distinct()
                    .sortedDescending()

            val totalActiveDays = dates.size
            val latestEntryDate = dates.firstOrNull()

            // Calculate Current Streak
            var currentStreak = 0
            if (dates.isNotEmpty()) {
                val mostRecent = dates.first()
                val daysDiff = ChronoUnit.DAYS.between(mostRecent, referenceDate)

                // Current streak is valid if the most recent entry is today (0) or yesterday (1)
                if (daysDiff <= 1) {
                    currentStreak = 1
                    var previousDate = mostRecent

                    for (i in 1 until dates.size) {
                        val date = dates[i]
                        val gap = ChronoUnit.DAYS.between(date, previousDate)
                        if (gap == 1L) {
                            currentStreak++
                            previousDate = date
                        } else if (gap > 1L) {
                            break
                        }
                    }
                }
            }

            // Calculate Longest Streak
            val ascendingDates = dates.sorted()
            var longestStreak = if (ascendingDates.isNotEmpty()) 1 else 0
            var tempStreak = 1

            for (i in 1 until ascendingDates.size) {
                val prev = ascendingDates[i - 1]
                val curr = ascendingDates[i]
                val gap = ChronoUnit.DAYS.between(prev, curr)
                if (gap == 1L) {
                    tempStreak++
                    if (tempStreak > longestStreak) {
                        longestStreak = tempStreak
                    }
                } else if (gap > 1L) {
                    tempStreak = 1
                }
            }

            if (currentStreak > longestStreak) {
                longestStreak = currentStreak
            }

            val lastTimestamp = entryTimestamps.maxOrNull()

            return StreakInfo(
                currentStreak = currentStreak,
                longestStreak = longestStreak,
                totalActiveDays = totalActiveDays,
                lastEntryDate = lastTimestamp,
            )
        }
    }
