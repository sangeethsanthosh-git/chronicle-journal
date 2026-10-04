package com.chronicle.journal.presentation.collections

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronicle.journal.domain.model.Collection
import com.chronicle.journal.domain.model.JournalWithDetails
import com.chronicle.journal.domain.repository.CollectionRepository
import com.chronicle.journal.domain.repository.JournalRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import javax.inject.Inject

data class CollectionDetailUiState(
    val collection: Collection? = null,
    val entries: List<JournalWithDetails> = emptyList(),
    val isLoading: Boolean = true,
)

@HiltViewModel
class CollectionDetailViewModel
    @Inject
    constructor(
        savedStateHandle: SavedStateHandle,
        private val collectionRepository: CollectionRepository,
        private val journalRepository: JournalRepository,
    ) : ViewModel() {
        private val collectionId: Long = savedStateHandle.get<String>("collectionId")?.toLongOrNull() ?: -1L

        private val _uiState = MutableStateFlow(CollectionDetailUiState())
        val uiState: StateFlow<CollectionDetailUiState> = _uiState.asStateFlow()

        init {
            loadData()
        }

        private fun loadData() {
            if (collectionId <= 0) return

            viewModelScope.launch {
                collectionRepository.getCollectionById(collectionId).collectLatest { col ->
                    _uiState.value = _uiState.value.copy(collection = col)
                }
            }

            viewModelScope.launch {
                collectionRepository.getEntriesForCollection(collectionId).collectLatest { list ->
                    _uiState.value = _uiState.value.copy(entries = list, isLoading = false)
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
