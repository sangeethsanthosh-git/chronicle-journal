package com.chronicle.journal.domain.usecase

import com.chronicle.journal.core.common.TimeUtils
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Before
import org.junit.Test
import java.time.LocalDate

class CalculateStreakUseCaseTest {
    private lateinit var useCase: CalculateStreakUseCase
    private val today = LocalDate.of(2026, 10, 4)

    @Before
    fun setUp() {
        useCase = CalculateStreakUseCase()
    }

    @Test
    fun `empty timestamps returns zero streak`() {
        val result = useCase.execute(emptyList(), today)
        assertEquals(0, result.currentStreak)
        assertEquals(0, result.longestStreak)
        assertEquals(0, result.totalActiveDays)
        assertNull(result.lastEntryDate)
    }

    @Test
    fun `entry today gives streak of 1`() {
        val todayMillis = TimeUtils.fromLocalDate(today)
        val result = useCase.execute(listOf(todayMillis), today)

        assertEquals(1, result.currentStreak)
        assertEquals(1, result.longestStreak)
        assertEquals(1, result.totalActiveDays)
        assertEquals(todayMillis, result.lastEntryDate)
    }

    @Test
    fun `entry yesterday without today entry gives streak of 1`() {
        val yesterdayMillis = TimeUtils.fromLocalDate(today.minusDays(1))
        val result = useCase.execute(listOf(yesterdayMillis), today)

        assertEquals(1, result.currentStreak)
        assertEquals(1, result.longestStreak)
        assertEquals(1, result.totalActiveDays)
    }

    @Test
    fun `entry 3 days ago gives current streak of 0`() {
        val threeDaysAgo = TimeUtils.fromLocalDate(today.minusDays(3))
        val result = useCase.execute(listOf(threeDaysAgo), today)

        assertEquals(0, result.currentStreak)
        assertEquals(1, result.longestStreak)
        assertEquals(1, result.totalActiveDays)
    }

    @Test
    fun `consecutive consecutive days build current streak`() {
        val timestamps =
            listOf(
                TimeUtils.fromLocalDate(today),
                TimeUtils.fromLocalDate(today.minusDays(1)),
                TimeUtils.fromLocalDate(today.minusDays(2)),
                TimeUtils.fromLocalDate(today.minusDays(3)),
            )
        val result = useCase.execute(timestamps, today)

        assertEquals(4, result.currentStreak)
        assertEquals(4, result.longestStreak)
        assertEquals(4, result.totalActiveDays)
    }

    @Test
    fun `longest streak preserved even when current streak breaks`() {
        val timestamps =
            listOf(
                // Current streak: 2 days (yesterday and day before)
                TimeUtils.fromLocalDate(today.minusDays(1)),
                TimeUtils.fromLocalDate(today.minusDays(2)),
                // Historical 5-day streak
                TimeUtils.fromLocalDate(today.minusDays(10)),
                TimeUtils.fromLocalDate(today.minusDays(11)),
                TimeUtils.fromLocalDate(today.minusDays(12)),
                TimeUtils.fromLocalDate(today.minusDays(13)),
                TimeUtils.fromLocalDate(today.minusDays(14)),
            )
        val result = useCase.execute(timestamps, today)

        assertEquals(2, result.currentStreak)
        assertEquals(5, result.longestStreak)
        assertEquals(7, result.totalActiveDays)
    }

    @Test
    fun `multiple entries on the same day count once for streak`() {
        val todayMorning = TimeUtils.fromLocalDate(today) + 1000
        val todayEvening = TimeUtils.fromLocalDate(today) + 3600000
        val yesterday = TimeUtils.fromLocalDate(today.minusDays(1))

        val result = useCase.execute(listOf(todayMorning, todayEvening, yesterday), today)

        assertEquals(2, result.currentStreak)
        assertEquals(2, result.longestStreak)
        assertEquals(2, result.totalActiveDays)
    }
}
