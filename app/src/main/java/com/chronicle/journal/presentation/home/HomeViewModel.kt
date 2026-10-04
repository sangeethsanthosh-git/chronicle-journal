package com.chronicle.journal.presentation.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronicle.journal.core.common.TimeUtils
import com.chronicle.journal.domain.model.JournalWithDetails
import com.chronicle.journal.domain.model.MemoryItem
import com.chronicle.journal.domain.model.StreakInfo
import com.chronicle.journal.domain.repository.JournalRepository
import com.chronicle.journal.domain.usecase.CalculateStreakUseCase
import com.chronicle.journal.domain.usecase.GetMemoriesUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import java.time.LocalDate
import javax.inject.Inject

data class HomeUiState(
    val greeting: String = TimeUtils.getGreeting(),
    val todayFormatted: String = TimeUtils.formatFullDate(System.currentTimeMillis()),
    val dailyQuote: String = "Every day is a page in the book of your life. Make it worth reading.",
    val todayEntry: JournalWithDetails? = null,
    val recentEntries: List<JournalWithDetails> = emptyList(),
    val memories: List<MemoryItem> = emptyList(),
    val streakInfo: StreakInfo = StreakInfo(),
    val isLoading: Boolean = true,
)

@HiltViewModel
class HomeViewModel
    @Inject
    constructor(
        private val journalRepository: JournalRepository,
        private val getMemoriesUseCase: GetMemoriesUseCase,
        private val calculateStreakUseCase: CalculateStreakUseCase,
    ) : ViewModel() {
        private val _uiState = MutableStateFlow(HomeUiState())
        val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

        init {
            loadHomeData()
        }

        private fun loadHomeData() {
            val quotes =
                listOf(
                    "Write it down, and the magic of that moment will never fade.",
                    "In every walk with nature one receives far more than he seeks.",
                    "The art of life lies in a constant readjustment to our surroundings.",
                    "Collect moments, not things.",
                    "Your story is what you have, what you will always have. It is something to own.",
                )

            viewModelScope.launch {
                _uiState.value = _uiState.value.copy(dailyQuote = quotes.random())

                // Observe all entries
                journalRepository.getAllEntries().collectLatest { allEntries ->
                    val startOfDay = TimeUtils.getStartOfDay(System.currentTimeMillis())
                    val endOfDay = TimeUtils.getEndOfDay(System.currentTimeMillis())

                    val todayEntry =
                        allEntries.firstOrNull {
                            it.entry.entryDate in startOfDay..endOfDay
                        }

                    val allDates = allEntries.map { it.entry.entryDate }
                    val streakInfo = calculateStreakUseCase.execute(allDates, LocalDate.now())

                    _uiState.value =
                        _uiState.value.copy(
                            todayEntry = todayEntry,
                            recentEntries = allEntries.take(5),
                            streakInfo = streakInfo,
                            isLoading = false,
                        )
                }
            }

            viewModelScope.launch {
                getMemoriesUseCase.execute(LocalDate.now()).collectLatest { memoriesList ->
                    _uiState.value = _uiState.value.copy(memories = memoriesList)
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
