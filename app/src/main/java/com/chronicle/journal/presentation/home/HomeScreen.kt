package com.chronicle.journal.presentation.home

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Bookmarks
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Mood
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.chronicle.journal.core.designsystem.components.EmptyState
import com.chronicle.journal.core.designsystem.components.JournalCard
import com.chronicle.journal.core.designsystem.components.SectionHeader
import com.chronicle.journal.core.designsystem.components.WashiTape
import com.chronicle.journal.core.designsystem.theme.HandwrittenCaptionStyle
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.core.designsystem.theme.PaperBackground
import com.chronicle.journal.core.designsystem.theme.VintageGold
import com.chronicle.journal.core.designsystem.theme.WashiTapeKraft
import com.chronicle.journal.core.designsystem.theme.WashiTapeSage

@Composable
fun HomeScreen(
    onNavigateToEditor: (Long) -> Unit,
    onNavigateToEntryDetail: (Long) -> Unit,
    onNavigateToSearch: () -> Unit,
    onNavigateToCollections: () -> Unit,
    onNavigateToMemories: () -> Unit,
    onNavigateToJournal: () -> Unit,
    viewModel: HomeViewModel = hiltViewModel(),
) {
    val state by viewModel.uiState.collectAsState()
    val colors = LocalChronicleColors.current

    PaperBackground {
        if (state.isLoading) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = colors.inkPrimary)
            }
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 20.dp),
                verticalArrangement = Arrangement.spacedBy(18.dp),
            ) {
                // Top Editorial Bar
                item {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Column {
                            Text(
                                text = "CHRONICLE",
                                fontFamily = FontFamily.Serif,
                                fontWeight = FontWeight.Bold,
                                fontSize = 24.sp,
                                letterSpacing = 2.sp,
                                color = colors.inkPrimary,
                            )
                            Text(
                                text = state.todayFormatted.uppercase(),
                                fontFamily = FontFamily.Monospace,
                                fontSize = 11.sp,
                                color = colors.inkMuted,
                                letterSpacing = 1.sp,
                            )
                        }

                        Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                            IconButton(onClick = onNavigateToSearch) {
                                Icon(
                                    imageVector = Icons.Default.Search,
                                    contentDescription = "Search",
                                    tint = colors.inkPrimary,
                                )
                            }
                            IconButton(onClick = onNavigateToCollections) {
                                Icon(
                                    imageVector = Icons.Default.Bookmarks,
                                    contentDescription = "Collections",
                                    tint = colors.inkPrimary,
                                )
                            }
                        }
                    }
                }

                // Greeting & Reflective Quote Card
                item {
                    Box(
                        modifier =
                            Modifier
                                .fillMaxWidth()
                                .shadow(3.dp, RoundedCornerShape(6.dp))
                                .background(colors.paperCard, RoundedCornerShape(6.dp))
                                .border(1.dp, colors.paperCardBorder, RoundedCornerShape(6.dp))
                                .padding(16.dp),
                    ) {
                        WashiTape(
                            modifier =
                                Modifier
                                    .align(Alignment.TopEnd)
                                    .padding(top = (-24).dp, end = 16.dp),
                            rotation = -4f,
                            color = WashiTapeKraft,
                        )

                        Column {
                            Text(
                                text = "${state.greeting},",
                                fontFamily = FontFamily.Serif,
                                fontWeight = FontWeight.SemiBold,
                                fontSize = 20.sp,
                                color = colors.inkPrimary,
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = "“${state.dailyQuote}”",
                                style = HandwrittenCaptionStyle,
                                fontSize = 16.sp,
                                color = colors.inkSecondary,
                                lineHeight = 22.sp,
                            )

                            // Streak Pill
                            if (state.streakInfo.currentStreak > 0) {
                                Spacer(modifier = Modifier.height(10.dp))
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                                    modifier =
                                        Modifier
                                            .background(colors.paperSurface, RoundedCornerShape(12.dp))
                                            .padding(horizontal = 10.dp, vertical = 4.dp),
                                ) {
                                    Text(
                                        text = "🔥 ${state.streakInfo.currentStreak} day streak",
                                        fontFamily = FontFamily.Monospace,
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = VintageGold,
                                    )
                                    Text(
                                        text = "• ${state.streakInfo.totalActiveDays} days penned",
                                        fontFamily = FontFamily.Monospace,
                                        fontSize = 11.sp,
                                        color = colors.inkMuted,
                                    )
                                }
                            }
                        }
                    }
                }

                // Quick Action Bar
                item {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                    ) {
                        QuickActionButton(
                            icon = Icons.Default.Add,
                            label = "New Page",
                            onClick = { onNavigateToEditor(-1L) },
                        )
                        QuickActionButton(
                            icon = Icons.Default.Image,
                            label = "Photo Story",
                            onClick = { onNavigateToEditor(-1L) },
                        )
                        QuickActionButton(
                            icon = Icons.Default.Mic,
                            label = "Voice Memo",
                            onClick = { onNavigateToEditor(-1L) },
                        )
                        QuickActionButton(
                            icon = Icons.Default.Mood,
                            label = "Mood Log",
                            onClick = { onNavigateToEditor(-1L) },
                        )
                    }
                }

                // Today's Journal Card
                item {
                    SectionHeader(
                        title = "Today's Story",
                        actionLabel = if (state.todayEntry != null) "EDIT" else null,
                        onActionClick = {
                            state.todayEntry?.let { onNavigateToEditor(it.entry.id) }
                        },
                    )

                    if (state.todayEntry != null) {
                        JournalCard(
                            details = state.todayEntry!!,
                            onFavoriteToggle = {
                                viewModel.toggleFavorite(
                                    state.todayEntry!!.entry.id,
                                    !state.todayEntry!!.entry.isFavorite,
                                )
                            },
                            onClick = { onNavigateToEntryDetail(state.todayEntry!!.entry.id) },
                        )
                    } else {
                        // Empty Today prompt
                        Box(
                            modifier =
                                Modifier
                                    .fillMaxWidth()
                                    .shadow(2.dp, RoundedCornerShape(8.dp))
                                    .background(colors.paperCard, RoundedCornerShape(8.dp))
                                    .border(1.dp, colors.paperCardBorder, RoundedCornerShape(8.dp))
                                    .clickable { onNavigateToEditor(-1L) }
                                    .padding(18.dp),
                        ) {
                            Column(
                                horizontalAlignment = Alignment.CenterHorizontally,
                                modifier = Modifier.fillMaxWidth(),
                            ) {
                                Text(text = "✍️", fontSize = 28.sp)
                                Spacer(modifier = Modifier.height(6.dp))
                                Text(
                                    text = "Haven't written today yet?",
                                    fontFamily = FontFamily.Serif,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 16.sp,
                                    color = colors.inkPrimary,
                                )
                                Text(
                                    text = "Pen a fleeting thought or memory to keep your streak going.",
                                    style = HandwrittenCaptionStyle,
                                    fontSize = 14.sp,
                                    color = colors.inkSecondary,
                                )
                                Spacer(modifier = Modifier.height(10.dp))
                                Button(
                                    onClick = { onNavigateToEditor(-1L) },
                                    colors =
                                        ButtonDefaults.buttonColors(
                                            containerColor = colors.inkPrimary,
                                            contentColor = colors.paperCard,
                                        ),
                                    shape = RoundedCornerShape(20.dp),
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.Edit,
                                        contentDescription = null,
                                        modifier = Modifier.size(16.dp),
                                    )
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(
                                        text = "Write Today's Page",
                                        fontFamily = FontFamily.Monospace,
                                        fontSize = 12.sp,
                                    )
                                }
                            }
                        }
                    }
                }

                // Recent Memories ("On This Day")
                if (state.memories.isNotEmpty()) {
                    item {
                        SectionHeader(
                            title = "Recent Memories",
                            actionLabel = "VIEW ALL",
                            onActionClick = onNavigateToMemories,
                        )

                        LazyRow(
                            horizontalArrangement = Arrangement.spacedBy(14.dp),
                            contentPadding = PaddingValues(horizontal = 2.dp),
                        ) {
                            items(state.memories.take(4)) { memory ->
                                Box(
                                    modifier =
                                        Modifier
                                            .width(260.dp)
                                            .shadow(3.dp, RoundedCornerShape(6.dp))
                                            .background(colors.paperCard, RoundedCornerShape(6.dp))
                                            .border(1.dp, colors.paperCardBorder, RoundedCornerShape(6.dp))
                                            .clickable { onNavigateToEntryDetail(memory.entryWithDetails.entry.id) }
                                            .padding(12.dp),
                                ) {
                                    WashiTape(
                                        modifier =
                                            Modifier
                                                .align(Alignment.TopEnd)
                                                .padding(top = (-18).dp, end = 8.dp),
                                        rotation = 5f,
                                        color = WashiTapeSage,
                                    )

                                    Column {
                                        Text(
                                            text = memory.formattedDate.uppercase(),
                                            fontFamily = FontFamily.Monospace,
                                            fontSize = 10.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = VintageGold,
                                            letterSpacing = 1.sp,
                                        )
                                        Spacer(modifier = Modifier.height(4.dp))
                                        Text(
                                            text = memory.entryWithDetails.entry.title,
                                            fontFamily = FontFamily.Serif,
                                            fontWeight = FontWeight.Bold,
                                            fontSize = 15.sp,
                                            color = colors.inkPrimary,
                                            maxLines = 1,
                                        )
                                        Spacer(modifier = Modifier.height(2.dp))
                                        Text(
                                            text = memory.entryWithDetails.entry.content,
                                            style = HandwrittenCaptionStyle,
                                            fontSize = 13.sp,
                                            color = colors.inkSecondary,
                                            maxLines = 2,
                                        )
                                    }
                                }
                            }
                        }
                    }
                }

                // Recent Entries
                item {
                    SectionHeader(
                        title = "Recent Pages",
                        actionLabel = "TIMELINE",
                        onActionClick = onNavigateToJournal,
                    )
                }

                if (state.recentEntries.isEmpty()) {
                    item {
                        EmptyState(
                            title = "Your story starts here",
                            message = "Tap '+ New Page' to write your first journal entry.",
                            actionLabel = "Create First Entry",
                            onActionClick = { onNavigateToEditor(-1L) },
                        )
                    }
                } else {
                    items(state.recentEntries) { details ->
                        JournalCard(
                            details = details,
                            onFavoriteToggle = {
                                viewModel.toggleFavorite(details.entry.id, !details.entry.isFavorite)
                            },
                            onClick = { onNavigateToEntryDetail(details.entry.id) },
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun QuickActionButton(
    icon: ImageVector,
    label: String,
    onClick: () -> Unit,
) {
    val colors = LocalChronicleColors.current

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.clickable { onClick() },
    ) {
        Box(
            modifier =
                Modifier
                    .size(50.dp)
                    .shadow(2.dp, CircleShape)
                    .background(colors.paperCard, CircleShape)
                    .border(1.dp, colors.paperCardBorder, CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                imageVector = icon,
                contentDescription = label,
                tint = colors.inkPrimary,
                modifier = Modifier.size(22.dp),
            )
        }
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = label,
            fontSize = 11.sp,
            fontFamily = FontFamily.Monospace,
            color = colors.inkSecondary,
        )
    }
}
