package com.chronicle.journal.presentation.editor

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronicle.journal.core.common.TimeUtils
import com.chronicle.journal.data.local.entities.DraftEntity
import com.chronicle.journal.domain.model.Attachment
import com.chronicle.journal.domain.model.AttachmentType
import com.chronicle.journal.domain.model.Collection
import com.chronicle.journal.domain.model.JournalEntry
import com.chronicle.journal.domain.model.JournalLayout
import com.chronicle.journal.domain.model.Mood
import com.chronicle.journal.domain.model.Tag
import com.chronicle.journal.domain.repository.CollectionRepository
import com.chronicle.journal.domain.repository.JournalRepository
import com.chronicle.journal.domain.usecase.DeleteEntryUseCase
import com.chronicle.journal.domain.usecase.GetEntryByIdUseCase
import com.chronicle.journal.domain.usecase.SaveEntryUseCase
import com.chronicle.journal.presentation.media.AudioPlayerHelper
import com.chronicle.journal.presentation.media.AudioRecorderHelper
import com.chronicle.journal.presentation.media.LocationHelper
import com.chronicle.journal.presentation.media.RecordingState
import com.chronicle.journal.presentation.media.WeatherHelper
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
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

data class EditorUiState(
    val entryId: Long = -1L,
    val title: String = "",
    val content: String = "",
    val entryDate: Long = System.currentTimeMillis(),
    val mood: Mood = Mood.NEUTRAL,
    val moodIntensity: Int = 3,
    val isFavorite: Boolean = false,
    val layoutStyle: JournalLayout = JournalLayout.CLASSIC,
    val locationName: String? = null,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val weatherSummary: String? = null,
    val weatherTemperature: Float? = null,
    val weatherIcon: String? = null,
    val tags: List<Tag> = emptyList(),
    val allAvailableTags: List<Tag> = emptyList(),
    val attachments: List<Attachment> = emptyList(),
    val selectedCollectionIds: List<Long> = emptyList(),
    val availableCollections: List<Collection> = emptyList(),
    val lastSavedMessage: String = "",
    val isSaving: Boolean = false,
    val isPreviewMode: Boolean = false,
    val isDraftLoaded: Boolean = false,
)

sealed interface EditorUiEvent {
    data class ShowToast(
        val message: String,
    ) : EditorUiEvent

    data object EntrySaved : EditorUiEvent

    data object EntryDeleted : EditorUiEvent
}

@HiltViewModel
class JournalEditorViewModel
    @Inject
    constructor(
        savedStateHandle: SavedStateHandle,
        private val journalRepository: JournalRepository,
        private val collectionRepository: CollectionRepository,
        private val getEntryByIdUseCase: GetEntryByIdUseCase,
        private val saveEntryUseCase: SaveEntryUseCase,
        private val deleteEntryUseCase: DeleteEntryUseCase,
        val audioRecorderHelper: AudioRecorderHelper,
        val audioPlayerHelper: AudioPlayerHelper,
        private val locationHelper: LocationHelper,
        private val weatherHelper: WeatherHelper,
    ) : ViewModel() {
        private val navEntryId: Long = savedStateHandle.get<String>("entryId")?.toLongOrNull() ?: -1L
        private val navEntryDate: Long = savedStateHandle.get<String>("entryDate")?.toLongOrNull() ?: -1L

        private val _uiState =
            MutableStateFlow(
                EditorUiState(
                    entryId = navEntryId,
                    entryDate = if (navEntryDate > 0) navEntryDate else System.currentTimeMillis(),
                ),
            )
        val uiState: StateFlow<EditorUiState> = _uiState.asStateFlow()

        private val _events = MutableSharedFlow<EditorUiEvent>()
        val events: SharedFlow<EditorUiEvent> = _events.asSharedFlow()

        private var autoSaveJob: Job? = null

        init {
            loadData()
            observeRecording()
        }

        private fun loadData() {
            // Load available tags
            viewModelScope.launch {
                journalRepository.getAllTags().collectLatest { allTags ->
                    _uiState.value = _uiState.value.copy(allAvailableTags = allTags)
                }
            }

            // Load available collections
            viewModelScope.launch {
                collectionRepository.getAllCollections().collectLatest { collections ->
                    _uiState.value = _uiState.value.copy(availableCollections = collections)
                }
            }

            if (navEntryId > 0) {
                // Load existing entry
                viewModelScope.launch {
                    val details = getEntryByIdUseCase.executeSync(navEntryId)
                    if (details != null) {
                        val e = details.entry
                        _uiState.value =
                            _uiState.value.copy(
                                entryId = e.id,
                                title = e.title,
                                content = e.content,
                                entryDate = e.entryDate,
                                mood = e.mood,
                                moodIntensity = e.moodIntensity,
                                isFavorite = e.isFavorite,
                                layoutStyle = e.layoutStyle,
                                locationName = e.locationName,
                                latitude = e.latitude,
                                longitude = e.longitude,
                                weatherSummary = e.weatherSummary,
                                weatherTemperature = e.weatherTemperature,
                                weatherIcon = e.weatherIcon,
                                tags = details.tags,
                                attachments = details.attachments,
                                selectedCollectionIds = details.collections.map { it.id },
                                isDraftLoaded = true,
                                lastSavedMessage = "Loaded entry",
                            )
                    }
                }
            } else {
                // New entry: Check for saved draft
                viewModelScope.launch {
                    val draft = journalRepository.getDraft()
                    draft.collectLatest { d ->
                        if (d != null && !_uiState.value.isDraftLoaded && (d.title.isNotBlank() || d.content.isNotBlank())) {
                            _uiState.value =
                                _uiState.value.copy(
                                    title = d.title,
                                    content = d.content,
                                    mood = Mood.fromString(d.mood),
                                    moodIntensity = d.moodIntensity,
                                    entryDate = d.entryDate,
                                    layoutStyle = JournalLayout.fromString(d.layoutStyle),
                                    locationName = d.locationName,
                                    latitude = d.latitude,
                                    longitude = d.longitude,
                                    weatherSummary = d.weatherSummary,
                                    weatherTemperature = d.weatherTemperature,
                                    isDraftLoaded = true,
                                    lastSavedMessage = "Restored draft (${TimeUtils.formatTime(d.updatedAt)})",
                                )
                        }
                    }
                }
            }
        }

        private fun observeRecording() {
            viewModelScope.launch {
                audioRecorderHelper.recordingState.collectLatest { state ->
                    if (state is RecordingState.Completed) {
                        addAudioAttachment(state.file, state.durationMs)
                    }
                }
            }
        }

        fun onTitleChange(newTitle: String) {
            _uiState.value = _uiState.value.copy(title = newTitle)
            triggerAutoSave()
        }

        fun onContentChange(newContent: String) {
            _uiState.value = _uiState.value.copy(content = newContent)
            triggerAutoSave()
        }

        fun onMoodChange(mood: Mood) {
            _uiState.value = _uiState.value.copy(mood = mood)
            triggerAutoSave()
        }

        fun onMoodIntensityChange(intensity: Int) {
            _uiState.value = _uiState.value.copy(moodIntensity = intensity)
            triggerAutoSave()
        }

        fun onDateChange(newDateMillis: Long) {
            _uiState.value = _uiState.value.copy(entryDate = newDateMillis)
            triggerAutoSave()
        }

        fun onLayoutStyleChange(layout: JournalLayout) {
            _uiState.value = _uiState.value.copy(layoutStyle = layout)
            triggerAutoSave()
        }

        fun onFavoriteToggle() {
            _uiState.value = _uiState.value.copy(isFavorite = !_uiState.value.isFavorite)
            triggerAutoSave()
        }

        fun togglePreviewMode() {
            _uiState.value = _uiState.value.copy(isPreviewMode = !_uiState.value.isPreviewMode)
        }

        fun addTag(
            name: String,
            colorHex: String? = null,
        ) {
            if (name.isBlank()) return
            val trimmed = name.trim().lowercase()
            if (_uiState.value.tags.none { it.name.equals(trimmed, ignoreCase = true) }) {
                val newTag = Tag(name = trimmed, colorHex = colorHex ?: "#8C7355")
                _uiState.value = _uiState.value.copy(tags = _uiState.value.tags + newTag)
                triggerAutoSave()
            }
        }

        fun removeTag(tag: Tag) {
            _uiState.value = _uiState.value.copy(tags = _uiState.value.tags - tag)
            triggerAutoSave()
        }

        fun addPhotoAttachment(
            uri: String,
            caption: String? = null,
        ) {
            val newAttachment =
                Attachment(
                    uri = uri,
                    type = AttachmentType.PHOTO,
                    caption = caption,
                )
            _uiState.value =
                _uiState.value.copy(
                    attachments = _uiState.value.attachments + newAttachment,
                )
            triggerAutoSave()
        }

        fun addAudioAttachment(
            file: File,
            durationMs: Long,
        ) {
            val newAttachment =
                Attachment(
                    uri = file.absolutePath,
                    type = AttachmentType.AUDIO,
                    durationMs = durationMs,
                )
            _uiState.value =
                _uiState.value.copy(
                    attachments = _uiState.value.attachments + newAttachment,
                )
            triggerAutoSave()
        }

        fun removeAttachment(attachment: Attachment) {
            _uiState.value =
                _uiState.value.copy(
                    attachments = _uiState.value.attachments - attachment,
                )
            viewModelScope.launch {
                if (attachment.id > 0) {
                    journalRepository.deleteAttachment(attachment)
                }
            }
            triggerAutoSave()
        }

        fun toggleCollection(collectionId: Long) {
            val current = _uiState.value.selectedCollectionIds
            val updated =
                if (current.contains(collectionId)) {
                    current - collectionId
                } else {
                    current + collectionId
                }
            _uiState.value = _uiState.value.copy(selectedCollectionIds = updated)
        }

        fun fetchCurrentLocationAndWeather() {
            viewModelScope.launch {
                val loc = locationHelper.getCurrentLocation()
                if (loc != null) {
                    _uiState.value =
                        _uiState.value.copy(
                            locationName = loc.name,
                            latitude = loc.latitude,
                            longitude = loc.longitude,
                        )

                    // Now fetch weather using coordinates
                    val weather = weatherHelper.fetchWeather(loc.latitude, loc.longitude)
                    if (weather != null) {
                        _uiState.value =
                            _uiState.value.copy(
                                weatherSummary = weather.summary,
                                weatherTemperature = weather.temperatureCelsius,
                                weatherIcon = weather.icon,
                            )
                    }
                    triggerAutoSave()
                } else {
                    _events.emit(EditorUiEvent.ShowToast("Location unavailable or permission not granted"))
                }
            }
        }

        private fun triggerAutoSave() {
            autoSaveJob?.cancel()
            autoSaveJob =
                viewModelScope.launch {
                    delay(1000) // 1s debounce
                    saveDraftInternal()
                }
        }

        private suspend fun saveDraftInternal() {
            val s = _uiState.value
            if (s.title.isNotBlank() || s.content.isNotBlank()) {
                val draft =
                    DraftEntity(
                        id = 1L,
                        editingEntryId = if (s.entryId > 0) s.entryId else null,
                        title = s.title,
                        content = s.content,
                        mood = s.mood.name,
                        moodIntensity = s.moodIntensity,
                        entryDate = s.entryDate,
                        layoutStyle = s.layoutStyle.name,
                        locationName = s.locationName,
                        latitude = s.latitude,
                        longitude = s.longitude,
                        weatherSummary = s.weatherSummary,
                        weatherTemperature = s.weatherTemperature,
                        updatedAt = System.currentTimeMillis(),
                    )
                journalRepository.saveDraft(draft)
                _uiState.value =
                    _uiState.value.copy(
                        lastSavedMessage = "Saved draft at ${TimeUtils.formatTime(System.currentTimeMillis())}",
                    )
            }
        }

        fun saveEntry() {
            val s = _uiState.value
            val title = s.title.trim()
            val content = s.content.trim()

            if (title.isBlank() && content.isBlank()) {
                viewModelScope.launch {
                    _events.emit(EditorUiEvent.ShowToast("Please enter a title or journal content."))
                }
                return
            }

            viewModelScope.launch {
                _uiState.value = _uiState.value.copy(isSaving = true)
                try {
                    val primaryCover = s.attachments.firstOrNull { it.type == AttachmentType.PHOTO }?.uri

                    val entry =
                        JournalEntry(
                            id = if (s.entryId > 0) s.entryId else 0L,
                            title = if (title.isBlank()) "Untitled Page" else title,
                            content = content,
                            createdAt = System.currentTimeMillis(),
                            updatedAt = System.currentTimeMillis(),
                            entryDate = s.entryDate,
                            mood = s.mood,
                            moodIntensity = s.moodIntensity,
                            isFavorite = s.isFavorite,
                            locationName = s.locationName,
                            latitude = s.latitude,
                            longitude = s.longitude,
                            weatherSummary = s.weatherSummary,
                            weatherTemperature = s.weatherTemperature,
                            weatherIcon = s.weatherIcon,
                            coverImageUri = primaryCover,
                            layoutStyle = s.layoutStyle,
                        )

                    saveEntryUseCase.execute(
                        entry = entry,
                        tags = s.tags,
                        attachments = s.attachments,
                        collectionIds = s.selectedCollectionIds,
                    )

                    _events.emit(EditorUiEvent.EntrySaved)
                } catch (e: Exception) {
                    _events.emit(EditorUiEvent.ShowToast("Failed to save: ${e.localizedMessage}"))
                } finally {
                    _uiState.value = _uiState.value.copy(isSaving = false)
                }
            }
        }

        fun deleteEntry() {
            if (_uiState.value.entryId > 0) {
                viewModelScope.launch {
                    deleteEntryUseCase.execute(_uiState.value.entryId)
                    _events.emit(EditorUiEvent.EntryDeleted)
                }
            }
        }

        override fun onCleared() {
            super.onCleared()
            audioPlayerHelper.stop()
            audioRecorderHelper.cancelRecording()
        }
    }
