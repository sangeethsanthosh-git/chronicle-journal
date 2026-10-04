package com.chronicle.journal.data.preferences

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.chronicle.journal.domain.model.JournalLayout
import com.chronicle.journal.domain.model.PaperStyle
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "chronicle_preferences")

enum class AppTheme {
    SYSTEM,
    LIGHT,
    DARK,
}

data class UserPreferences(
    val theme: AppTheme = AppTheme.SYSTEM,
    val defaultLayout: JournalLayout = JournalLayout.CLASSIC,
    val paperStyle: PaperStyle = PaperStyle.PLAIN,
    val isAppLockEnabled: Boolean = false,
    val pinHash: String? = null,
    val isBiometricEnabled: Boolean = false,
    val isReminderEnabled: Boolean = false,
    val reminderHour: Int = 21,
    val reminderMinute: Int = 0,
    val isOnboardingCompleted: Boolean = false,
    val showQuotes: Boolean = true,
)

@Singleton
class UserPreferencesRepository
    @Inject
    constructor(
        @ApplicationContext private val context: Context,
    ) {
        private object PreferencesKeys {
            val THEME = stringPreferencesKey("app_theme")
            val DEFAULT_LAYOUT = stringPreferencesKey("default_journal_layout")
            val PAPER_STYLE = stringPreferencesKey("paper_style")
            val APP_LOCK_ENABLED = booleanPreferencesKey("app_lock_enabled")
            val PIN_HASH = stringPreferencesKey("pin_hash")
            val BIOMETRIC_ENABLED = booleanPreferencesKey("biometric_enabled")
            val REMINDER_ENABLED = booleanPreferencesKey("reminder_enabled")
            val REMINDER_HOUR = intPreferencesKey("reminder_hour")
            val REMINDER_MINUTE = intPreferencesKey("reminder_minute")
            val ONBOARDING_COMPLETED = booleanPreferencesKey("onboarding_completed")
            val SHOW_QUOTES = booleanPreferencesKey("show_quotes")
        }

        val userPreferencesFlow: Flow<UserPreferences> =
            context.dataStore.data.map { prefs ->
                UserPreferences(
                    theme =
                        try {
                            AppTheme.valueOf(prefs[PreferencesKeys.THEME] ?: AppTheme.SYSTEM.name)
                        } catch (e: Exception) {
                            AppTheme.SYSTEM
                        },
                    defaultLayout = JournalLayout.fromString(prefs[PreferencesKeys.DEFAULT_LAYOUT]),
                    paperStyle = PaperStyle.fromString(prefs[PreferencesKeys.PAPER_STYLE]),
                    isAppLockEnabled = prefs[PreferencesKeys.APP_LOCK_ENABLED] ?: false,
                    pinHash = prefs[PreferencesKeys.PIN_HASH],
                    isBiometricEnabled = prefs[PreferencesKeys.BIOMETRIC_ENABLED] ?: false,
                    isReminderEnabled = prefs[PreferencesKeys.REMINDER_ENABLED] ?: false,
                    reminderHour = prefs[PreferencesKeys.REMINDER_HOUR] ?: 21,
                    reminderMinute = prefs[PreferencesKeys.REMINDER_MINUTE] ?: 0,
                    isOnboardingCompleted = prefs[PreferencesKeys.ONBOARDING_COMPLETED] ?: false,
                    showQuotes = prefs[PreferencesKeys.SHOW_QUOTES] ?: true,
                )
            }

        suspend fun setTheme(theme: AppTheme) {
            context.dataStore.edit { it[PreferencesKeys.THEME] = theme.name }
        }

        suspend fun setDefaultLayout(layout: JournalLayout) {
            context.dataStore.edit { it[PreferencesKeys.DEFAULT_LAYOUT] = layout.name }
        }

        suspend fun setPaperStyle(style: PaperStyle) {
            context.dataStore.edit { it[PreferencesKeys.PAPER_STYLE] = style.name }
        }

        suspend fun setAppLock(
            enabled: Boolean,
            pinHash: String?,
        ) {
            context.dataStore.edit {
                it[PreferencesKeys.APP_LOCK_ENABLED] = enabled
                if (pinHash != null) {
                    it[PreferencesKeys.PIN_HASH] = pinHash
                } else if (!enabled) {
                    it.remove(PreferencesKeys.PIN_HASH)
                }
            }
        }

        suspend fun setBiometricEnabled(enabled: Boolean) {
            context.dataStore.edit { it[PreferencesKeys.BIOMETRIC_ENABLED] = enabled }
        }

        suspend fun setReminder(
            enabled: Boolean,
            hour: Int = 21,
            minute: Int = 0,
        ) {
            context.dataStore.edit {
                it[PreferencesKeys.REMINDER_ENABLED] = enabled
                it[PreferencesKeys.REMINDER_HOUR] = hour
                it[PreferencesKeys.REMINDER_MINUTE] = minute
            }
        }

        suspend fun setOnboardingCompleted(completed: Boolean) {
            context.dataStore.edit { it[PreferencesKeys.ONBOARDING_COMPLETED] = completed }
        }

        suspend fun setShowQuotes(show: Boolean) {
            context.dataStore.edit { it[PreferencesKeys.SHOW_QUOTES] = show }
        }
    }
