package com.chronicle.journal.presentation.calendar

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.chronicle.journal.core.common.TimeUtils
import com.chronicle.journal.core.designsystem.components.EmptyState
import com.chronicle.journal.core.designsystem.components.JournalCard
import com.chronicle.journal.core.designsystem.components.SectionHeader
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.core.designsystem.theme.PaperBackground
import com.chronicle.journal.core.designsystem.theme.VintageGold
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.time.format.TextStyle
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CalendarScreen(
    onNavigateToEditorWithDate: (Long) -> Unit,
    onNavigateToDetail: (Long) -> Unit,
    viewModel: CalendarViewModel = hiltViewModel(),
) {
    val state by viewModel.uiState.collectAsState()
    val colors = LocalChronicleColors.current

    val monthFormatter = DateTimeFormatter.ofPattern("MMMM yyyy", Locale.getDefault())
    val selectedDateFormatted = state.selectedDate.format(DateTimeFormatter.ofPattern("EEEE, MMM d, yyyy"))

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Calendar",
                        fontFamily = FontFamily.Serif,
                        fontWeight = FontWeight.Bold,
                        fontSize = 20.sp,
                        color = colors.inkPrimary,
                    )
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = colors.paperBackground),
            )
        },
    ) { paddingValues ->
        PaperBackground(modifier = Modifier.padding(paddingValues)) {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 10.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp),
            ) {
                // Calendar Card
                item {
                    Box(
                        modifier =
                            Modifier
                                .fillMaxWidth()
                                .border(1.dp, colors.paperCardBorder, RoundedCornerShape(8.dp))
                                .background(colors.paperCard, RoundedCornerShape(8.dp))
                                .padding(14.dp),
                    ) {
                        Column {
                            // Month Header with Prev / Next Navigation
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically,
                            ) {
                                IconButton(onClick = { viewModel.previousMonth() }) {
                                    Icon(
                                        imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                                        contentDescription = "Previous Month",
                                        tint = colors.inkPrimary,
                                    )
                                }

                                Text(
                                    text = state.selectedYearMonth.format(monthFormatter),
                                    fontFamily = FontFamily.Serif,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 17.sp,
                                    color = colors.inkPrimary,
                                )

                                IconButton(onClick = { viewModel.nextMonth() }) {
                                    Icon(
                                        imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                                        contentDescription = "Next Month",
                                        tint = colors.inkPrimary,
                                    )
                                }
                            }

                            Spacer(modifier = Modifier.height(10.dp))

                            // Day of Week Header (S M T W T F S)
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceAround,
                            ) {
                                val daysOfWeek =
                                    listOf(
                                        DayOfWeek.SUNDAY,
                                        DayOfWeek.MONDAY,
                                        DayOfWeek.TUESDAY,
                                        DayOfWeek.WEDNESDAY,
                                        DayOfWeek.THURSDAY,
                                        DayOfWeek.FRIDAY,
                                        DayOfWeek.SATURDAY,
                                    )
                                daysOfWeek.forEach { day ->
                                    Text(
                                        text = day.getDisplayName(TextStyle.NARROW, Locale.getDefault()),
                                        fontSize = 12.sp,
                                        fontFamily = FontFamily.Monospace,
                                        fontWeight = FontWeight.Bold,
                                        color = colors.inkMuted,
                                    )
                                }
                            }

                            Spacer(modifier = Modifier.height(8.dp))

                            // Month Grid Days
                            val firstDayOfMonth = state.selectedYearMonth.atDay(1)
                            val firstDayOfWeekIndex = firstDayOfMonth.dayOfWeek.value % 7 // Sunday = 0
                            val daysInMonth = state.selectedYearMonth.lengthOfMonth()
                            val totalSlots = ((firstDayOfWeekIndex + daysInMonth + 6) / 7) * 7

                            val rows = totalSlots / 7
                            for (row in 0 until rows) {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceAround,
                                ) {
                                    for (col in 0 until 7) {
                                        val slotIndex = row * 7 + col
                                        val dayNumber = slotIndex - firstDayOfWeekIndex + 1

                                        if (dayNumber in 1..daysInMonth) {
                                            val date = state.selectedYearMonth.atDay(dayNumber)
                                            val isSelected = date == state.selectedDate
                                            val isToday = date == LocalDate.now()
                                            val entriesForDay = state.monthEntriesMap[date] ?: emptyList()
                                            val hasEntries = entriesForDay.isNotEmpty()

                                            Box(
                                                modifier =
                                                    Modifier
                                                        .size(38.dp)
                                                        .aspectRatio(1f)
                                                        .border(
                                                            if (isToday) 1.dp else 0.dp,
                                                            if (isToday) VintageGold else Color.Transparent,
                                                            CircleShape,
                                                        ).background(
                                                            if (isSelected) colors.inkPrimary else Color.Transparent,
                                                            CircleShape,
                                                        ).clickable { viewModel.selectDate(date) },
                                                contentAlignment = Alignment.Center,
                                            ) {
                                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                                    Text(
                                                        text = "$dayNumber",
                                                        fontSize = 13.sp,
                                                        fontWeight = if (isSelected || isToday) FontWeight.Bold else FontWeight.Normal,
                                                        fontFamily = FontFamily.Monospace,
                                                        color = if (isSelected) colors.paperCard else colors.inkPrimary,
                                                    )

                                                    if (hasEntries) {
                                                        // Mood or entry indicator dot
                                                        val primaryMood = entriesForDay.first().entry.mood
                                                        val dotColor = if (isSelected) colors.paperCard else VintageGold
                                                        Box(
                                                            modifier =
                                                                Modifier
                                                                    .size(4.dp)
                                                                    .background(dotColor, CircleShape),
                                                        )
                                                    }
                                                }
                                            }
                                        } else {
                                            // Empty padding cell
                                            Box(modifier = Modifier.size(38.dp))
                                        }
                                    }
                                }
                                Spacer(modifier = Modifier.height(4.dp))
                            }
                        }
                    }
                }

                // Selected Date Header
                item {
                    SectionHeader(
                        title = selectedDateFormatted,
                        actionLabel = "+ WRITE FOR THIS DAY",
                        onActionClick = {
                            val epoch = TimeUtils.fromLocalDate(state.selectedDate)
                            onNavigateToEditorWithDate(epoch)
                        },
                    )
                }

                // Entries on selected date
                if (state.selectedDateEntries.isEmpty()) {
                    item {
                        EmptyState(
                            title = "No pages on this date",
                            message = "No stories recorded for $selectedDateFormatted.",
                            actionLabel = "Write Entry for Date",
                            onActionClick = {
                                val epoch = TimeUtils.fromLocalDate(state.selectedDate)
                                onNavigateToEditorWithDate(epoch)
                            },
                        )
                    }
                } else {
                    items(state.selectedDateEntries) { details ->
                        JournalCard(
                            details = details,
                            onFavoriteToggle = {
                                viewModel.toggleFavorite(details.entry.id, !details.entry.isFavorite)
                            },
                            onClick = { onNavigateToDetail(details.entry.id) },
                        )
                    }
                }

                item {
                    Spacer(modifier = Modifier.height(60.dp))
                }
            }
        }
    }
}
