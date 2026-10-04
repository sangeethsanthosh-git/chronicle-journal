package com.chronicle.journal.presentation.memories

import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.CircularProgressIndicator
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
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.chronicle.journal.core.designsystem.components.EmptyState
import com.chronicle.journal.core.designsystem.components.JournalCard
import com.chronicle.journal.core.designsystem.components.WashiTape
import com.chronicle.journal.core.designsystem.theme.HandwrittenCaptionStyle
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.core.designsystem.theme.PaperBackground
import com.chronicle.journal.core.designsystem.theme.VintageGold
import com.chronicle.journal.core.designsystem.theme.WashiTapeRose

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MemoriesScreen(
    onNavigateBack: () -> Unit,
    onNavigateToDetail: (Long) -> Unit,
    viewModel: MemoriesViewModel = hiltViewModel(),
) {
    val state by viewModel.uiState.collectAsState()
    val colors = LocalChronicleColors.current

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            text = "Memories",
                            fontFamily = FontFamily.Serif,
                            fontWeight = FontWeight.Bold,
                            fontSize = 20.sp,
                            color = colors.inkPrimary,
                        )
                        Text(
                            text = "Glimpses into your past pages",
                            fontFamily = FontFamily.Monospace,
                            fontSize = 10.sp,
                            color = colors.inkMuted,
                        )
                    }
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
            if (state.isLoading) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = colors.inkPrimary)
                }
            } else if (state.memories.isEmpty()) {
                Box(modifier = Modifier.fillMaxSize().padding(16.dp), contentAlignment = Alignment.Center) {
                    EmptyState(
                        title = "Your memories will appear here",
                        message = "As time unfolds, past entries on this day will resurface like nostalgic postcards.",
                        emoji = "⏳",
                    )
                }
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
                    verticalArrangement = Arrangement.spacedBy(18.dp),
                ) {
                    item {
                        Box(
                            modifier =
                                Modifier
                                    .fillMaxWidth()
                                    .shadow(2.dp, RoundedCornerShape(6.dp))
                                    .background(colors.paperCard, RoundedCornerShape(6.dp))
                                    .border(1.dp, colors.paperCardBorder, RoundedCornerShape(6.dp))
                                    .padding(14.dp),
                        ) {
                            WashiTape(
                                modifier =
                                    Modifier
                                        .align(Alignment.TopEnd)
                                        .padding(top = (-20).dp, end = 12.dp),
                                rotation = 6f,
                                color = WashiTapeRose,
                            )
                            Column {
                                Text(
                                    text = "TIME CAPSULE",
                                    fontFamily = FontFamily.Monospace,
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = VintageGold,
                                    letterSpacing = 1.sp,
                                )
                                Spacer(modifier = Modifier.height(4.dp))
                                Text(
                                    text = "“We do not remember days, we remember moments.”",
                                    style = HandwrittenCaptionStyle,
                                    fontSize = 16.sp,
                                    color = colors.inkPrimary,
                                )
                            }
                        }
                    }

                    items(state.memories) { memory ->
                        Column {
                            Row(
                                modifier =
                                    Modifier
                                        .fillMaxWidth()
                                        .padding(bottom = 6.dp),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically,
                            ) {
                                Text(
                                    text = "⭐ " + memory.formattedDate.uppercase(),
                                    fontFamily = FontFamily.Monospace,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 12.sp,
                                    color = VintageGold,
                                    letterSpacing = 1.sp,
                                )
                            }

                            JournalCard(
                                details = memory.entryWithDetails,
                                onClick = { onNavigateToDetail(memory.entryWithDetails.entry.id) },
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
}
