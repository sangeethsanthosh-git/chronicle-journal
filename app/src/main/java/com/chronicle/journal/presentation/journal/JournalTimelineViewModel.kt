package com.chronicle.journal.presentation.journal

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronicle.journal.domain.model.JournalWithDetails
import com.chronicle.journal.domain.model.Mood
import com.chronicle.journal.domain.model.Tag
import com.chronicle.journal.domain.repository.JournalRepository
import com.chronicle.journal.domain.usecase.EntryFilterCriteria
import com.chronicle.journal.domain.usecase.EntrySortOption
import com.chronicle.journal.domain.usecase.GetEntriesUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import javax.inject.Inject

enum class TimelineViewMode(
    val displayName: String,
) {
    CARD("Cards"),
    SCRAPBOOK("Scrapbook"),
    POSTCARD("Postcards"),
    LIST("Compact List"),
}

data class JournalTimelineUiState(
    val entries: List<JournalWithDetails> = emptyList(),
    val viewMode: TimelineViewMode = TimelineViewMode.CARD,
    val sortOption: EntrySortOption = EntrySortOption.NEWEST,
    val filterCriteria: EntryFilterCriteria = EntryFilterCriteria(),
    val availableTags: List<Tag> = emptyList(),
    val isLoading: Boolean = true,
)

@HiltViewModel
class JournalTimelineViewModel
    @Inject
    constructor(
        private val journalRepository: JournalRepository,
        private val getEntriesUseCase: GetEntriesUseCase,
    ) : ViewModel() {
        private val _uiState = MutableStateFlow(JournalTimelineUiState())
        val uiState: StateFlow<JournalTimelineUiState> = _uiState.asStateFlow()

        init {
            loadData()
        }

        private fun loadData() {
            // Load tags
            viewModelScope.launch {
                journalRepository.getAllTags().collectLatest { tags ->
                    _uiState.value = _uiState.value.copy(availableTags = tags)
                }
            }

            observeEntries()
        }

        private fun observeEntries() {
            viewModelScope.launch {
                getEntriesUseCase
                    .execute(
                        sortOption = _uiState.value.sortOption,
                        filterCriteria = _uiState.value.filterCriteria,
                    ).collectLatest { list ->
                        _uiState.value =
                            _uiState.value.copy(
                                entries = list,
                                isLoading = false,
                            )
                    }
            }
        }

        fun setViewMode(mode: TimelineViewMode) {
            _uiState.value = _uiState.value.copy(viewMode = mode)
        }

        fun setSortOption(sort: EntrySortOption) {
            _uiState.value = _uiState.value.copy(sortOption = sort)
            observeEntries()
        }

        fun filterByMood(mood: Mood?) {
            val updated = _uiState.value.filterCriteria.copy(mood = mood)
            _uiState.value = _uiState.value.copy(filterCriteria = updated)
            observeEntries()
        }

        fun filterByTag(tagId: Long?) {
            val updated = _uiState.value.filterCriteria.copy(tagId = tagId)
            _uiState.value = _uiState.value.copy(filterCriteria = updated)
            observeEntries()
        }

        fun toggleFavoritesOnly() {
            val updated =
                _uiState.value.filterCriteria.copy(
                    onlyFavorites = !_uiState.value.filterCriteria.onlyFavorites,
                )
            _uiState.value = _uiState.value.copy(filterCriteria = updated)
            observeEntries()
        }

        fun togglePhotosOnly() {
            val updated =
                _uiState.value.filterCriteria.copy(
                    onlyWithPhotos = !_uiState.value.filterCriteria.onlyWithPhotos,
                )
            _uiState.value = _uiState.value.copy(filterCriteria = updated)
            observeEntries()
        }

        fun toggleAudioOnly() {
            val updated =
                _uiState.value.filterCriteria.copy(
                    onlyWithAudio = !_uiState.value.filterCriteria.onlyWithAudio,
                )
            _uiState.value = _uiState.value.copy(filterCriteria = updated)
            observeEntries()
        }

        fun clearFilters() {
            _uiState.value = _uiState.value.copy(filterCriteria = EntryFilterCriteria())
            observeEntries()
        }

        fun toggleFavorite(
            entryId: Long,
            isFavorite: Boolean,
        ) {
            viewModelScope.launch {
                journalRepository.toggleFavorite(entryId, isFavorite)
            }
        }
    }
