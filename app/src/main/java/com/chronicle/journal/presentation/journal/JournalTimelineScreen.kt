package com.chronicle.journal.presentation.journal

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Sort
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.FilterList
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.chronicle.journal.core.designsystem.components.EmptyState
import com.chronicle.journal.core.designsystem.components.JournalCard
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.core.designsystem.theme.PaperBackground
import com.chronicle.journal.core.designsystem.theme.VintageGold
import com.chronicle.journal.domain.model.JournalLayout
import com.chronicle.journal.domain.model.Mood
import com.chronicle.journal.domain.usecase.EntrySortOption

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun JournalTimelineScreen(
    onNavigateToEditor: (Long) -> Unit,
    onNavigateToDetail: (Long) -> Unit,
    viewModel: JournalTimelineViewModel = hiltViewModel(),
) {
    val state by viewModel.uiState.collectAsState()
    val colors = LocalChronicleColors.current

    var showSortMenu by remember { mutableStateOf(false) }
    var showFilterPanel by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            text = "Journal Timeline",
                            fontFamily = FontFamily.Serif,
                            fontWeight = FontWeight.Bold,
                            fontSize = 20.sp,
                            color = colors.inkPrimary,
                        )
                        Text(
                            text = "${state.entries.size} pages preserved",
                            fontFamily = FontFamily.Monospace,
                            fontSize = 10.sp,
                            color = colors.inkMuted,
                        )
                    }
                },
                actions = {
                    IconButton(onClick = { showFilterPanel = !showFilterPanel }) {
                        Icon(
                            imageVector = Icons.Default.FilterList,
                            contentDescription = "Filter",
                            tint =
                                if (state.filterCriteria.mood != null ||
                                    state.filterCriteria.tagId != null ||
                                    state.filterCriteria.onlyFavorites
                                ) {
                                    VintageGold
                                } else {
                                    colors.inkPrimary
                                },
                        )
                    }
                    Box {
                        IconButton(onClick = { showSortMenu = true }) {
                            Icon(
                                imageVector = Icons.AutoMirrored.Filled.Sort,
                                contentDescription = "Sort",
                                tint = colors.inkPrimary,
                            )
                        }
                        DropdownMenu(
                            expanded = showSortMenu,
                            onDismissRequest = { showSortMenu = false },
                        ) {
                            EntrySortOption.entries.forEach { option ->
                                DropdownMenuItem(
                                    text = { Text(option.displayName) },
                                    onClick = {
                                        viewModel.setSortOption(option)
                                        showSortMenu = false
                                    },
                                )
                            }
                        }
                    }
                },
                colors =
                    TopAppBarDefaults.topAppBarColors(
                        containerColor = colors.paperBackground,
                    ),
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = { onNavigateToEditor(-1L) },
                containerColor = colors.inkPrimary,
                contentColor = colors.paperCard,
                shape = RoundedCornerShape(16.dp),
            ) {
                Icon(imageVector = Icons.Default.Add, contentDescription = "New Entry")
            }
        },
    ) { paddingValues ->
        PaperBackground(modifier = Modifier.padding(paddingValues)) {
            if (state.isLoading) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = colors.inkPrimary)
                }
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp),
                ) {
                    // View Mode Switcher
                    item {
                        LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            items(TimelineViewMode.entries) { mode ->
                                FilterChip(
                                    selected = state.viewMode == mode,
                                    onClick = { viewModel.setViewMode(mode) },
                                    label = {
                                        Text(
                                            text = mode.displayName,
                                            fontFamily = FontFamily.Monospace,
                                            fontSize = 11.sp,
                                        )
                                    },
                                    colors =
                                        FilterChipDefaults.filterChipColors(
                                            selectedContainerColor = colors.inkPrimary,
                                            selectedLabelColor = colors.paperCard,
                                        ),
                                )
                            }
                        }
                    }

                    // Collapsible Filter Panel
                    item {
                        AnimatedVisibility(visible = showFilterPanel) {
                            Box(
                                modifier =
                                    Modifier
                                        .fillMaxWidth()
                                        .border(1.dp, colors.paperCardBorder, RoundedCornerShape(8.dp))
                                        .background(colors.paperCard, RoundedCornerShape(8.dp))
                                        .padding(12.dp),
                            ) {
                                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                    Row(
                                        modifier = Modifier.fillMaxWidth(),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.CenterVertically,
                                    ) {
                                        Text(
                                            text = "FILTERS",
                                            fontFamily = FontFamily.Monospace,
                                            fontSize = 11.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = colors.inkSecondary,
                                        )
                                        TextButton(onClick = { viewModel.clearFilters() }) {
                                            Text(
                                                text = "Reset",
                                                fontSize = 11.sp,
                                                fontFamily = FontFamily.Monospace,
                                                color = VintageGold,
                                            )
                                        }
                                    }

                                    // Quick toggle chips
                                    Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                                        FilterChip(
                                            selected = state.filterCriteria.onlyFavorites,
                                            onClick = { viewModel.toggleFavoritesOnly() },
                                            label = { Text("★ Favorites", fontSize = 11.sp) },
                                        )
                                        FilterChip(
                                            selected = state.filterCriteria.onlyWithPhotos,
                                            onClick = { viewModel.togglePhotosOnly() },
                                            label = { Text("📷 Photos", fontSize = 11.sp) },
                                        )
                                        FilterChip(
                                            selected = state.filterCriteria.onlyWithAudio,
                                            onClick = { viewModel.toggleAudioOnly() },
                                            label = { Text("🎙️ Audio", fontSize = 11.sp) },
                                        )
                                    }

                                    // Mood filters
                                    Text(
                                        text = "Filter by mood:",
                                        fontSize = 10.sp,
                                        fontFamily = FontFamily.Monospace,
                                        color = colors.inkMuted,
                                    )
                                    FlowRow(
                                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                                        verticalArrangement = Arrangement.spacedBy(4.dp),
                                    ) {
                                        Mood.entries.forEach { mood ->
                                            val isSelected = state.filterCriteria.mood == mood
                                            FilterChip(
                                                selected = isSelected,
                                                onClick = {
                                                    viewModel.filterByMood(if (isSelected) null else mood)
                                                },
                                                label = { Text("${mood.emoji} ${mood.displayName}", fontSize = 10.sp) },
                                            )
                                        }
                                    }

                                    // Tag filters
                                    if (state.availableTags.isNotEmpty()) {
                                        Text(
                                            text = "Filter by tag:",
                                            fontSize = 10.sp,
                                            fontFamily = FontFamily.Monospace,
                                            color = colors.inkMuted,
                                        )
                                        FlowRow(
                                            horizontalArrangement = Arrangement.spacedBy(4.dp),
                                            verticalArrangement = Arrangement.spacedBy(4.dp),
                                        ) {
                                            state.availableTags.forEach { tag ->
                                                val isSelected = state.filterCriteria.tagId == tag.id
                                                FilterChip(
                                                    selected = isSelected,
                                                    onClick = {
                                                        viewModel.filterByTag(if (isSelected) null else tag.id)
                                                    },
                                                    label = { Text("#${tag.name}", fontSize = 10.sp) },
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Entries List
                    if (state.entries.isEmpty()) {
                        item {
                            EmptyState(
                                title = "No pages found",
                                message = "No journal entries match your filter or search criteria.",
                                actionLabel = "Clear Filters",
                                onActionClick = { viewModel.clearFilters() },
                            )
                        }
                    } else {
                        items(state.entries, key = { it.entry.id }) { details ->
                            val forcedLayout =
                                when (state.viewMode) {
                                    TimelineViewMode.SCRAPBOOK -> JournalLayout.SCRAPBOOK
                                    TimelineViewMode.POSTCARD -> JournalLayout.POSTCARD
                                    TimelineViewMode.BINDER -> JournalLayout.OPEN_BINDER
                                    TimelineViewMode.PANORAMA -> JournalLayout.PANORAMA_EDITORIAL
                                    TimelineViewMode.LIST -> JournalLayout.MINIMAL
                                    TimelineViewMode.CARD -> null // respects entry's own layout style
                                }

                            JournalCard(
                                details = details,
                                forcedLayout = forcedLayout,
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
}
