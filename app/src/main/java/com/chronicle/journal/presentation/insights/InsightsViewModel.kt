package com.chronicle.journal.presentation.insights

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronicle.journal.domain.model.JournalStatistics
import com.chronicle.journal.domain.usecase.GetStatisticsUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class InsightsUiState(
    val statistics: JournalStatistics = JournalStatistics(),
    val isLoading: Boolean = true,
)

@HiltViewModel
class InsightsViewModel
    @Inject
    constructor(
        private val getStatisticsUseCase: GetStatisticsUseCase,
    ) : ViewModel() {
        private val _uiState = MutableStateFlow(InsightsUiState())
        val uiState: StateFlow<InsightsUiState> = _uiState.asStateFlow()

        init {
            loadStatistics()
        }

        fun loadStatistics() {
            viewModelScope.launch {
                _uiState.value = _uiState.value.copy(isLoading = true)
                val stats = getStatisticsUseCase.execute()
                _uiState.value =
                    InsightsUiState(
                        statistics = stats,
                        isLoading = false,
                    )
            }
        }
    }
