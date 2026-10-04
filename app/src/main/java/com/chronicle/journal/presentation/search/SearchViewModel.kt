package com.chronicle.journal.presentation.search

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronicle.journal.domain.model.JournalWithDetails
import com.chronicle.journal.domain.model.Mood
import com.chronicle.journal.domain.model.Tag
import com.chronicle.journal.domain.repository.JournalRepository
import com.chronicle.journal.domain.usecase.EntryFilterCriteria
import com.chronicle.journal.domain.usecase.SearchEntriesUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import javax.inject.Inject

data class SearchUiState(
    val query: String = "",
    val results: List<JournalWithDetails> = emptyList(),
    val filterCriteria: EntryFilterCriteria = EntryFilterCriteria(),
    val availableTags: List<Tag> = emptyList(),
    val isSearching: Boolean = false,
    val hasSearched: Boolean = false,
)

@HiltViewModel
class SearchViewModel
    @Inject
    constructor(
        private val journalRepository: JournalRepository,
        private val searchEntriesUseCase: SearchEntriesUseCase,
    ) : ViewModel() {
        private val _uiState = MutableStateFlow(SearchUiState())
        val uiState: StateFlow<SearchUiState> = _uiState.asStateFlow()

        private var searchJob: Job? = null

        init {
            viewModelScope.launch {
                journalRepository.getAllTags().collectLatest { tags ->
                    _uiState.value = _uiState.value.copy(availableTags = tags)
                }
            }
        }

        fun onQueryChange(newQuery: String) {
            _uiState.value = _uiState.value.copy(query = newQuery)
            searchJob?.cancel()
            searchJob =
                viewModelScope.launch {
                    delay(300) // Debounce
                    executeSearch()
                }
        }

        fun setFilterMood(mood: Mood?) {
            val updated = _uiState.value.filterCriteria.copy(mood = mood)
            _uiState.value = _uiState.value.copy(filterCriteria = updated)
            executeSearch()
        }

        fun setFilterTag(tagId: Long?) {
            val updated = _uiState.value.filterCriteria.copy(tagId = tagId)
            _uiState.value = _uiState.value.copy(filterCriteria = updated)
            executeSearch()
        }

        fun toggleFavoritesOnly() {
            val updated =
                _uiState.value.filterCriteria.copy(
                    onlyFavorites = !_uiState.value.filterCriteria.onlyFavorites,
                )
            _uiState.value = _uiState.value.copy(filterCriteria = updated)
            executeSearch()
        }

        fun togglePhotosOnly() {
            val updated =
                _uiState.value.filterCriteria.copy(
                    onlyWithPhotos = !_uiState.value.filterCriteria.onlyWithPhotos,
                )
            _uiState.value = _uiState.value.copy(filterCriteria = updated)
            executeSearch()
        }

        fun toggleAudioOnly() {
            val updated =
                _uiState.value.filterCriteria.copy(
                    onlyWithAudio = !_uiState.value.filterCriteria.onlyWithAudio,
                )
            _uiState.value = _uiState.value.copy(filterCriteria = updated)
            executeSearch()
        }

        fun clearFilters() {
            _uiState.value = _uiState.value.copy(filterCriteria = EntryFilterCriteria())
            executeSearch()
        }

        private fun executeSearch() {
            val q = _uiState.value.query.trim()
            if (q.isBlank() && _uiState.value.filterCriteria == EntryFilterCriteria()) {
                _uiState.value =
                    _uiState.value.copy(
                        results = emptyList(),
                        isSearching = false,
                        hasSearched = false,
                    )
                return
            }

            _uiState.value = _uiState.value.copy(isSearching = true, hasSearched = true)
            viewModelScope.launch {
                searchEntriesUseCase.execute(q, _uiState.value.filterCriteria).collectLatest { list ->
                    _uiState.value =
                        _uiState.value.copy(
                            results = list,
                            isSearching = false,
                        )
                }
            }
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
