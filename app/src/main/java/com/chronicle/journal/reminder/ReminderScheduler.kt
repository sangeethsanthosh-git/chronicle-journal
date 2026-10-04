package com.chronicle.journal.reminder

import android.content.Context
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import dagger.hilt.android.qualifiers.ApplicationContext
import java.time.Duration
import java.time.LocalDateTime
import java.util.concurrent.TimeUnit
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ReminderScheduler
    @Inject
    constructor(
        @ApplicationContext private val context: Context,
    ) {
        companion object {
            const val REMINDER_WORK_TAG = "CHRONICLE_DAILY_REMINDER"
        }

        fun scheduleDailyReminder(
            hour: Int,
            minute: Int,
        ) {
            val now = LocalDateTime.now()
            var targetTime = now.withHour(hour).withMinute(minute).withSecond(0)
            if (targetTime.isBefore(now)) {
                targetTime = targetTime.plusDays(1)
            }

            val initialDelayMinutes = Duration.between(now, targetTime).toMinutes()

            val reminderRequest =
                PeriodicWorkRequestBuilder<ReminderWorker>(24, TimeUnit.HOURS)
                    .setInitialDelay(initialDelayMinutes, TimeUnit.MINUTES)
                    .addTag(REMINDER_WORK_TAG)
                    .build()

            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                REMINDER_WORK_TAG,
                ExistingPeriodicWorkPolicy.UPDATE,
                reminderRequest,
            )
        }

        fun cancelReminder() {
            WorkManager.getInstance(context).cancelUniqueWork(REMINDER_WORK_TAG)
        }
    }
