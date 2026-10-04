package com.chronicle.journal.presentation.journal

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronicle.journal.domain.model.JournalWithDetails
import com.chronicle.journal.domain.repository.JournalRepository
import com.chronicle.journal.domain.usecase.DeleteEntryUseCase
import com.chronicle.journal.domain.usecase.GetEntryByIdUseCase
import com.chronicle.journal.presentation.media.AudioPlayerHelper
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import javax.inject.Inject

data class EntryDetailUiState(
    val entryWithDetails: JournalWithDetails? = null,
    val isLoading: Boolean = true,
)

@HiltViewModel
class EntryDetailViewModel
    @Inject
    constructor(
        savedStateHandle: SavedStateHandle,
        private val getEntryByIdUseCase: GetEntryByIdUseCase,
        private val deleteEntryUseCase: DeleteEntryUseCase,
        private val journalRepository: JournalRepository,
        val audioPlayerHelper: AudioPlayerHelper,
    ) : ViewModel() {
        private val entryId: Long = savedStateHandle.get<String>("entryId")?.toLongOrNull() ?: -1L

        private val _uiState = MutableStateFlow(EntryDetailUiState())
        val uiState: StateFlow<EntryDetailUiState> = _uiState.asStateFlow()

        private val _entryDeletedEvent = MutableSharedFlow<Unit>()
        val entryDeletedEvent: SharedFlow<Unit> = _entryDeletedEvent.asSharedFlow()

        init {
            loadEntry()
        }

        private fun loadEntry() {
            if (entryId <= 0) return
            viewModelScope.launch {
                getEntryByIdUseCase.execute(entryId).collectLatest { details ->
                    _uiState.value =
                        EntryDetailUiState(
                            entryWithDetails = details,
                            isLoading = false,
                        )
                }
            }
        }

        fun toggleFavorite() {
            val details = _uiState.value.entryWithDetails ?: return
            viewModelScope.launch {
                journalRepository.toggleFavorite(details.entry.id, !details.entry.isFavorite)
            }
        }

        fun deleteEntry() {
            if (entryId > 0) {
                viewModelScope.launch {
                    deleteEntryUseCase.execute(entryId)
                    _entryDeletedEvent.emit(Unit)
                }
            }
        }

        override fun onCleared() {
            super.onCleared()
            audioPlayerHelper.stop()
        }
    }
