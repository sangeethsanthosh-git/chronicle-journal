package com.chronicle.journal.presentation.calendar

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronicle.journal.core.common.TimeUtils
import com.chronicle.journal.domain.model.JournalWithDetails
import com.chronicle.journal.domain.repository.JournalRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import java.time.LocalDate
import java.time.YearMonth
import javax.inject.Inject

data class CalendarUiState(
    val selectedYearMonth: YearMonth = YearMonth.now(),
    val selectedDate: LocalDate = LocalDate.now(),
    val monthEntriesMap: Map<LocalDate, List<JournalWithDetails>> = emptyMap(),
    val selectedDateEntries: List<JournalWithDetails> = emptyList(),
    val isLoading: Boolean = true,
)

@HiltViewModel
class CalendarViewModel
    @Inject
    constructor(
        private val journalRepository: JournalRepository,
    ) : ViewModel() {
        private val _uiState = MutableStateFlow(CalendarUiState())
        val uiState: StateFlow<CalendarUiState> = _uiState.asStateFlow()

        init {
            loadMonthEntries()
        }

        private fun loadMonthEntries() {
            val ym = _uiState.value.selectedYearMonth
            val startOfMonth =
                ym
                    .atDay(1)
                    .atStartOfDay(java.time.ZoneId.systemDefault())
                    .toInstant()
                    .toEpochMilli()
            val endOfMonth =
                ym
                    .atEndOfMonth()
                    .atTime(23, 59, 59)
                    .atZone(java.time.ZoneId.systemDefault())
                    .toInstant()
                    .toEpochMilli()

            viewModelScope.launch {
                journalRepository.getEntriesByDateRange(startOfMonth, endOfMonth).collectLatest { entries ->
                    val map = mutableMapOf<LocalDate, MutableList<JournalWithDetails>>()
                    entries.forEach { details ->
                        val date = TimeUtils.toLocalDate(details.entry.entryDate)
                        map.getOrPut(date) { mutableListOf() }.add(details)
                    }

                    val currentSelectedDate = _uiState.value.selectedDate
                    val selectedList = map[currentSelectedDate] ?: emptyList()

                    _uiState.value =
                        _uiState.value.copy(
                            monthEntriesMap = map,
                            selectedDateEntries = selectedList,
                            isLoading = false,
                        )
                }
            }
        }

        fun selectDate(date: LocalDate) {
            val entriesForDate = _uiState.value.monthEntriesMap[date] ?: emptyList()
            _uiState.value =
                _uiState.value.copy(
                    selectedDate = date,
                    selectedDateEntries = entriesForDate,
                )
        }

        fun nextMonth() {
            _uiState.value =
                _uiState.value.copy(
                    selectedYearMonth = _uiState.value.selectedYearMonth.plusMonths(1),
                )
            loadMonthEntries()
        }

        fun previousMonth() {
            _uiState.value =
                _uiState.value.copy(
                    selectedYearMonth = _uiState.value.selectedYearMonth.minusMonths(1),
                )
            loadMonthEntries()
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
