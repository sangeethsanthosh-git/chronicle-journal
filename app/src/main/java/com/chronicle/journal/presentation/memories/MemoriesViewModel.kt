package com.chronicle.journal.presentation.memories

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronicle.journal.domain.model.MemoryItem
import com.chronicle.journal.domain.usecase.GetMemoriesUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import java.time.LocalDate
import javax.inject.Inject

data class MemoriesUiState(
    val memories: List<MemoryItem> = emptyList(),
    val isLoading: Boolean = true,
)

@HiltViewModel
class MemoriesViewModel
    @Inject
    constructor(
        private val getMemoriesUseCase: GetMemoriesUseCase,
    ) : ViewModel() {
        private val _uiState = MutableStateFlow(MemoriesUiState())
        val uiState: StateFlow<MemoriesUiState> = _uiState.asStateFlow()

        init {
            loadMemories()
        }

        private fun loadMemories() {
            viewModelScope.launch {
                getMemoriesUseCase.execute(LocalDate.now()).collectLatest { list ->
                    _uiState.value = MemoriesUiState(memories = list, isLoading = false)
                }
            }
        }
    }
