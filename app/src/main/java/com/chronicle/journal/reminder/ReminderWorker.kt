package com.chronicle.journal.reminder

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.hilt.work.HiltWorker
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.chronicle.journal.MainActivity
import com.chronicle.journal.R
import dagger.assisted.Assisted
import dagger.assisted.AssistedInject

@HiltWorker
class ReminderWorker
    @AssistedInject
    constructor(
        @Assisted private val context: Context,
        @Assisted workerParams: WorkerParameters,
    ) : CoroutineWorker(context, workerParams) {
        companion object {
            const val CHANNEL_ID = "chronicle_journal_reminders"
            const val NOTIFICATION_ID = 1001
        }

        override suspend fun doWork(): Result {
            createNotificationChannel()

            val intent =
                Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                }

            val pendingIntent =
                PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )

            val prompts =
                listOf(
                    "How was your day? Take a quiet moment to write it down.",
                    "What made you smile today? Chronicle your memories.",
                    "A blank page is waiting for your reflections.",
                    "Preserve today's thoughts before they slip away.",
                )
            val selectedPrompt = prompts.random()

            val notification =
                NotificationCompat
                    .Builder(context, CHANNEL_ID)
                    .setSmallIcon(R.drawable.ic_launcher_foreground)
                    .setContentTitle("Daily Journal Reflection")
                    .setContentText(selectedPrompt)
                    .setStyle(NotificationCompat.BigTextStyle().bigText(selectedPrompt))
                    .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                    .setContentIntent(pendingIntent)
                    .setAutoCancel(true)
                    .build()

            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            notificationManager?.notify(NOTIFICATION_ID, notification)

            return Result.success()
        }

        private fun createNotificationChannel() {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val name = "Daily Reflections"
                val descriptionText = "Reminders to reflect and capture moments in your journal"
                val importance = NotificationManager.IMPORTANCE_DEFAULT
                val channel =
                    NotificationChannel(CHANNEL_ID, name, importance).apply {
                        description = descriptionText
                    }
                val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.createNotificationChannel(channel)
            }
        }
    }
