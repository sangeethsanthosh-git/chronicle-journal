package com.chronicle.journal.core.common

import java.text.SimpleDateFormat
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.util.Date
import java.util.Locale

object TimeUtils {
    private val fullDateFormatter = SimpleDateFormat("EEEE, MMMM d, yyyy", Locale.getDefault())
    private val shortDateFormatter = SimpleDateFormat("MMM d, yyyy", Locale.getDefault())
    private val monthYearFormatter = SimpleDateFormat("MMMM yyyy", Locale.getDefault())
    private val timeFormatter = SimpleDateFormat("h:mm a", Locale.getDefault())
    private val dayOfMonthFormatter = SimpleDateFormat("d", Locale.getDefault())
    private val dayOfWeekFormatter = SimpleDateFormat("EEE", Locale.getDefault())
    private val postmarkDateFormatter = SimpleDateFormat("MMM dd ''yy", Locale.US)

    fun formatFullDate(epochMillis: Long): String = fullDateFormatter.format(Date(epochMillis))

    fun formatShortDate(epochMillis: Long): String = shortDateFormatter.format(Date(epochMillis))

    fun formatMonthYear(epochMillis: Long): String = monthYearFormatter.format(Date(epochMillis))

    fun formatTime(epochMillis: Long): String = timeFormatter.format(Date(epochMillis))

    fun formatDayOfMonth(epochMillis: Long): String = dayOfMonthFormatter.format(Date(epochMillis))

    fun formatDayOfWeek(epochMillis: Long): String = dayOfWeekFormatter.format(Date(epochMillis)).uppercase(Locale.getDefault())

    fun formatPostmarkDate(epochMillis: Long): String = postmarkDateFormatter.format(Date(epochMillis)).uppercase(Locale.US)

    fun formatDuration(durationMs: Long): String {
        val totalSeconds = durationMs / 1000
        val minutes = totalSeconds / 60
        val seconds = totalSeconds % 60
        return String.format(Locale.US, "%02d:%02d", minutes, seconds)
    }

    fun getStartOfDay(epochMillis: Long): Long {
        val localDate =
            Instant
                .ofEpochMilli(epochMillis)
                .atZone(ZoneId.systemDefault())
                .toLocalDate()
        return localDate.atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli()
    }

    fun getEndOfDay(epochMillis: Long): Long {
        val localDate =
            Instant
                .ofEpochMilli(epochMillis)
                .atZone(ZoneId.systemDefault())
                .toLocalDate()
        return localDate
            .plusDays(1)
            .atStartOfDay(ZoneId.systemDefault())
            .toInstant()
            .toEpochMilli() - 1
    }

    fun getGreeting(nowMillis: Long = System.currentTimeMillis()): String {
        val hour =
            Instant
                .ofEpochMilli(nowMillis)
                .atZone(ZoneId.systemDefault())
                .hour
        return when (hour) {
            in 4..11 -> "Good morning"
            in 12..16 -> "Good afternoon"
            in 17..21 -> "Good evening"
            else -> "Late night reflections"
        }
    }

    fun isSameDay(
        time1: Long,
        time2: Long,
    ): Boolean {
        val date1 = Instant.ofEpochMilli(time1).atZone(ZoneId.systemDefault()).toLocalDate()
        val date2 = Instant.ofEpochMilli(time2).atZone(ZoneId.systemDefault()).toLocalDate()
        return date1 == date2
    }

    fun toLocalDate(epochMillis: Long): LocalDate = Instant.ofEpochMilli(epochMillis).atZone(ZoneId.systemDefault()).toLocalDate()

    fun fromLocalDate(localDate: LocalDate): Long = localDate.atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli()
}
