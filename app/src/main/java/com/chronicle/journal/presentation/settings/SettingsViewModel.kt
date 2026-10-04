package com.chronicle.journal.presentation.settings

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronicle.journal.core.utils.SecurityUtils
import com.chronicle.journal.data.backup.BackupManager
import com.chronicle.journal.data.backup.BackupResult
import com.chronicle.journal.data.preferences.AppTheme
import com.chronicle.journal.data.preferences.UserPreferences
import com.chronicle.journal.data.preferences.UserPreferencesRepository
import com.chronicle.journal.domain.model.JournalLayout
import com.chronicle.journal.domain.model.PaperStyle
import com.chronicle.journal.reminder.ReminderScheduler
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import java.io.File
import javax.inject.Inject

sealed interface SettingsEvent {
    data class ShowMessage(
        val message: String,
    ) : SettingsEvent

    data class BackupSuccess(
        val filePath: String,
    ) : SettingsEvent
}

@HiltViewModel
class SettingsViewModel
    @Inject
    constructor(
        @ApplicationContext private val context: Context,
        private val preferencesRepository: UserPreferencesRepository,
        private val backupManager: BackupManager,
        private val reminderScheduler: ReminderScheduler,
    ) : ViewModel() {
        private val _userPreferences = MutableStateFlow(UserPreferences())
        val userPreferences: StateFlow<UserPreferences> = _userPreferences.asStateFlow()

        private val _events = MutableSharedFlow<SettingsEvent>()
        val events: SharedFlow<SettingsEvent> = _events.asSharedFlow()

        init {
            viewModelScope.launch {
                preferencesRepository.userPreferencesFlow.collectLatest { prefs ->
                    _userPreferences.value = prefs
                }
            }
        }

        fun setTheme(theme: AppTheme) {
            viewModelScope.launch { preferencesRepository.setTheme(theme) }
        }

        fun setDefaultLayout(layout: JournalLayout) {
            viewModelScope.launch { preferencesRepository.setDefaultLayout(layout) }
        }

        fun setPaperStyle(style: PaperStyle) {
            viewModelScope.launch { preferencesRepository.setPaperStyle(style) }
        }

        fun setPinLock(pin: String) {
            viewModelScope.launch {
                val hash = SecurityUtils.hashPin(pin)
                preferencesRepository.setAppLock(enabled = true, pinHash = hash)
                _events.emit(SettingsEvent.ShowMessage("App lock PIN set successfully"))
            }
        }

        fun disableAppLock() {
            viewModelScope.launch {
                preferencesRepository.setAppLock(enabled = false, pinHash = null)
                _events.emit(SettingsEvent.ShowMessage("App lock disabled"))
            }
        }

        fun setBiometricEnabled(enabled: Boolean) {
            viewModelScope.launch { preferencesRepository.setBiometricEnabled(enabled) }
        }

        fun setReminder(
            enabled: Boolean,
            hour: Int,
            minute: Int,
        ) {
            viewModelScope.launch {
                preferencesRepository.setReminder(enabled, hour, minute)
                if (enabled) {
                    reminderScheduler.scheduleDailyReminder(hour, minute)
                    _events.emit(SettingsEvent.ShowMessage("Daily reminder set for %02d:%02d".format(hour, minute)))
                } else {
                    reminderScheduler.cancelReminder()
                    _events.emit(SettingsEvent.ShowMessage("Daily reminder disabled"))
                }
            }
        }

        fun exportToJson() {
            viewModelScope.launch {
                val exportDir = File(context.cacheDir, "exports").apply { if (!exists()) mkdirs() }
                val file = File(exportDir, "chronicle_export_${System.currentTimeMillis()}.json")
                val ok = backupManager.exportToJson(file)
                if (ok) {
                    _events.emit(SettingsEvent.BackupSuccess(file.absolutePath))
                    _events.emit(SettingsEvent.ShowMessage("Exported to ${file.name}"))
                } else {
                    _events.emit(SettingsEvent.ShowMessage("Failed to export JSON"))
                }
            }
        }

        fun exportToTxt() {
            viewModelScope.launch {
                val exportDir = File(context.cacheDir, "exports").apply { if (!exists()) mkdirs() }
                val file = File(exportDir, "chronicle_export_${System.currentTimeMillis()}.txt")
                val ok = backupManager.exportToTxt(file)
                if (ok) {
                    _events.emit(SettingsEvent.BackupSuccess(file.absolutePath))
                    _events.emit(SettingsEvent.ShowMessage("Exported text journal to ${file.name}"))
                } else {
                    _events.emit(SettingsEvent.ShowMessage("Failed to export TXT"))
                }
            }
        }

        fun createZipBackup() {
            viewModelScope.launch {
                val backupDir = File(context.filesDir, "backups").apply { if (!exists()) mkdirs() }
                val zipFile = File(backupDir, "chronicle_full_backup_${System.currentTimeMillis()}.zip")
                val success = backupManager.createZipBackup(zipFile)
                if (success) {
                    _events.emit(SettingsEvent.BackupSuccess(zipFile.absolutePath))
                    _events.emit(SettingsEvent.ShowMessage("Complete backup created: ${zipFile.name}"))
                } else {
                    _events.emit(SettingsEvent.ShowMessage("Failed to create ZIP backup"))
                }
            }
        }

        fun restoreFromZip(zipFile: File) {
            viewModelScope.launch {
                val result: BackupResult = backupManager.restoreFromZip(zipFile)
                _events.emit(SettingsEvent.ShowMessage(result.message))
            }
        }

        fun restoreFromJson(jsonFile: File) {
            viewModelScope.launch {
                val result: BackupResult = backupManager.restoreFromJsonFile(jsonFile)
                _events.emit(SettingsEvent.ShowMessage(result.message))
            }
        }
    }
