package com.chronicle.journal.presentation.search

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
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
import com.chronicle.journal.domain.model.Mood

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun SearchScreen(
    onNavigateBack: () -> Unit,
    onNavigateToDetail: (Long) -> Unit,
    viewModel: SearchViewModel = hiltViewModel(),
) {
    val state by viewModel.uiState.collectAsState()
    val colors = LocalChronicleColors.current

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Search Archive",
                        fontFamily = FontFamily.Serif,
                        fontWeight = FontWeight.Bold,
                        fontSize = 20.sp,
                        color = colors.inkPrimary,
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "Back",
                            tint = colors.inkPrimary,
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = colors.paperBackground),
            )
        },
    ) { paddingValues ->
        PaperBackground(modifier = Modifier.padding(paddingValues)) {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 10.dp),
                verticalArrangement = Arrangement.spacedBy(14.dp),
            ) {
                // Search Input Field
                item {
                    OutlinedTextField(
                        value = state.query,
                        onValueChange = { viewModel.onQueryChange(it) },
                        placeholder = { Text("Search title, content, location, tags...", color = colors.inkMuted) },
                        leadingIcon = {
                            Icon(imageVector = Icons.Default.Search, contentDescription = null, tint = colors.inkPrimary)
                        },
                        trailingIcon = {
                            if (state.query.isNotEmpty()) {
                                IconButton(onClick = { viewModel.onQueryChange("") }) {
                                    Icon(imageVector = Icons.Default.Close, contentDescription = "Clear")
                                }
                            }
                        },
                        shape = RoundedCornerShape(24.dp),
                        colors =
                            OutlinedTextFieldDefaults.colors(
                                focusedContainerColor = colors.paperCard,
                                unfocusedContainerColor = colors.paperCard,
                                focusedBorderColor = colors.inkPrimary,
                                unfocusedBorderColor = colors.paperCardBorder,
                            ),
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth(),
                    )
                }

                // Filter Chips Row
                item {
                    LazyRow(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                        item {
                            FilterChip(
                                selected = state.filterCriteria.onlyFavorites,
                                onClick = { viewModel.toggleFavoritesOnly() },
                                label = { Text("★ Favorites") },
                            )
                        }
                        item {
                            FilterChip(
                                selected = state.filterCriteria.onlyWithPhotos,
                                onClick = { viewModel.togglePhotosOnly() },
                                label = { Text("📷 Photos") },
                            )
                        }
                        item {
                            FilterChip(
                                selected = state.filterCriteria.onlyWithAudio,
                                onClick = { viewModel.toggleAudioOnly() },
                                label = { Text("🎙️ Audio") },
                            )
                        }
                    }
                }

                // Mood Filters Row
                item {
                    FlowRow(
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        verticalArrangement = Arrangement.spacedBy(4.dp),
                    ) {
                        Mood.entries.forEach { mood ->
                            val isSelected = state.filterCriteria.mood == mood
                            FilterChip(
                                selected = isSelected,
                                onClick = { viewModel.setFilterMood(if (isSelected) null else mood) },
                                label = { Text("${mood.emoji} ${mood.displayName}", fontSize = 11.sp) },
                            )
                        }
                    }
                }

                // Results status bar
                if (state.hasSearched) {
                    item {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Text(
                                text = if (state.isSearching) "Searching..." else "${state.results.size} matches found",
                                fontSize = 11.sp,
                                fontFamily = FontFamily.Monospace,
                                color = colors.inkMuted,
                            )
                            TextButton(onClick = {
                                viewModel.clearFilters()
                                viewModel.onQueryChange("")
                            }) {
                                Text("Reset All", fontSize = 11.sp, color = VintageGold)
                            }
                        }
                    }
                }

                // Search Results or Empty State
                if (state.isSearching) {
                    item {
                        Box(modifier = Modifier.fillMaxWidth().padding(32.dp), contentAlignment = Alignment.Center) {
                            CircularProgressIndicator(color = colors.inkPrimary)
                        }
                    }
                } else if (state.hasSearched && state.results.isEmpty()) {
                    item {
                        EmptyState(
                            title = "No pages found",
                            message = "Try searching for a different keyword or relaxing your filter options.",
                            actionLabel = "Clear Filters",
                            onActionClick = {
                                viewModel.clearFilters()
                                viewModel.onQueryChange("")
                            },
                        )
                    }
                } else if (!state.hasSearched) {
                    item {
                        EmptyState(
                            title = "Explore your memories",
                            message = "Type in keywords above or tap a mood/tag to filter your journal archive.",
                            emoji = "🔍",
                        )
                    }
                } else {
                    items(state.results) { details ->
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
                    Spacer(modifier = Modifier.height(40.dp))
                }
            }
        }
    }
}
