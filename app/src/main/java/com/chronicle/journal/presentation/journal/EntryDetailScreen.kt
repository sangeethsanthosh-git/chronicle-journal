package com.chronicle.journal.presentation.journal

import android.content.Intent
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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Share
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.outlined.StarBorder
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.chronicle.journal.core.common.TimeUtils
import com.chronicle.journal.core.designsystem.components.AudioPlayerBar
import com.chronicle.journal.core.designsystem.components.DateBadge
import com.chronicle.journal.core.designsystem.components.MoodBadge
import com.chronicle.journal.core.designsystem.components.PolaroidCard
import com.chronicle.journal.core.designsystem.components.PostmarkStamp
import com.chronicle.journal.core.designsystem.components.TagChip
import com.chronicle.journal.core.designsystem.components.WashiTape
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.core.designsystem.theme.PaperBackground
import com.chronicle.journal.core.designsystem.theme.PostmarkRed
import com.chronicle.journal.core.designsystem.theme.VintageGold
import com.chronicle.journal.core.designsystem.theme.WashiTapeKraft

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun EntryDetailScreen(
    onNavigateBack: () -> Unit,
    onNavigateToEdit: (Long) -> Unit,
    viewModel: EntryDetailViewModel = hiltViewModel(),
) {
    val state by viewModel.uiState.collectAsState()
    val playbackState by viewModel.audioPlayerHelper.playbackState.collectAsState()
    val colors = LocalChronicleColors.current
    val context = LocalContext.current

    var showDeleteConfirmDialog by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        viewModel.entryDeletedEvent.collect {
            onNavigateBack()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "Back",
                            tint = colors.inkPrimary,
                        )
                    }
                },
                actions = {
                    state.entryWithDetails?.let { details ->
                        // Share Entry
                        IconButton(
                            onClick = {
                                val shareText = "${details.entry.title}\n\n${details.entry.content}\n\n— Written on ${TimeUtils.formatFullDate(
                                    details.entry.entryDate,
                                )}"
                                val sendIntent =
                                    Intent().apply {
                                        action = Intent.ACTION_SEND
                                        putExtra(Intent.EXTRA_TEXT, shareText)
                                        type = "text/plain"
                                    }
                                context.startActivity(Intent.createChooser(sendIntent, "Share Page"))
                            },
                        ) {
                            Icon(Icons.Default.Share, contentDescription = "Share", tint = colors.inkPrimary)
                        }

                        // Favorite Toggle
                        IconButton(onClick = { viewModel.toggleFavorite() }) {
                            Icon(
                                imageVector = if (details.entry.isFavorite) Icons.Filled.Star else Icons.Outlined.StarBorder,
                                contentDescription = "Favorite",
                                tint = if (details.entry.isFavorite) VintageGold else colors.inkMuted,
                            )
                        }

                        // Edit Button
                        IconButton(onClick = { onNavigateToEdit(details.entry.id) }) {
                            Icon(Icons.Default.Edit, contentDescription = "Edit", tint = colors.inkPrimary)
                        }

                        // Delete Button
                        IconButton(onClick = { showDeleteConfirmDialog = true }) {
                            Icon(Icons.Default.Delete, contentDescription = "Delete", tint = PostmarkRed)
                        }
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
            } else if (state.entryWithDetails == null) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Text("Entry not found", color = colors.inkMuted)
                }
            } else {
                val details = state.entryWithDetails!!
                val entry = details.entry

                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(horizontal = 18.dp, vertical = 12.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                ) {
                    // Page Sheet Header
                    item {
                        Box(
                            modifier =
                                Modifier
                                    .fillMaxWidth()
                                    .shadow(4.dp, RoundedCornerShape(4.dp))
                                    .background(colors.paperCard, RoundedCornerShape(4.dp))
                                    .border(1.dp, colors.paperCardBorder, RoundedCornerShape(4.dp))
                                    .padding(18.dp),
                        ) {
                            WashiTape(
                                modifier =
                                    Modifier
                                        .align(Alignment.TopEnd)
                                        .padding(top = (-24).dp, end = 12.dp),
                                rotation = 4f,
                                color = WashiTapeKraft,
                            )

                            Column {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically,
                                ) {
                                    Row(
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.spacedBy(10.dp),
                                    ) {
                                        DateBadge(dateMillis = entry.entryDate)
                                        Column {
                                            Text(
                                                text = TimeUtils.formatFullDate(entry.entryDate),
                                                fontFamily = FontFamily.Serif,
                                                fontWeight = FontWeight.Bold,
                                                fontSize = 14.sp,
                                                color = colors.inkPrimary,
                                            )
                                            Text(
                                                text = TimeUtils.formatTime(entry.createdAt),
                                                fontFamily = FontFamily.Monospace,
                                                fontSize = 11.sp,
                                                color = colors.inkMuted,
                                            )
                                        }
                                    }

                                    MoodBadge(
                                        mood = entry.mood,
                                        intensity = entry.moodIntensity,
                                        showLabel = true,
                                    )
                                }

                                Spacer(modifier = Modifier.height(14.dp))

                                // Title
                                Text(
                                    text = entry.title,
                                    fontFamily = FontFamily.Serif,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 24.sp,
                                    color = colors.inkPrimary,
                                    lineHeight = 32.sp,
                                )

                                Spacer(modifier = Modifier.height(10.dp))

                                // Content
                                Text(
                                    text = entry.content,
                                    fontFamily = FontFamily.Serif,
                                    fontSize = 16.sp,
                                    lineHeight = 26.sp,
                                    color = colors.inkPrimary,
                                )

                                // Location & Weather stamp
                                if (entry.locationName != null || entry.weatherSummary != null) {
                                    Spacer(modifier = Modifier.height(16.dp))
                                    Row(
                                        modifier = Modifier.fillMaxWidth(),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.CenterVertically,
                                    ) {
                                        if (entry.locationName != null) {
                                            Text(
                                                text = "📍 ${entry.locationName}",
                                                fontFamily = FontFamily.Monospace,
                                                fontSize = 11.sp,
                                                color = colors.inkMuted,
                                            )
                                        }
                                        if (entry.weatherSummary != null) {
                                            Text(
                                                text = "${entry.weatherIcon ?: "⛅"} ${entry.weatherSummary}${entry.weatherTemperature?.let {
                                                    " $it°C"
                                                } ?: ""}",
                                                fontFamily = FontFamily.Monospace,
                                                fontSize = 11.sp,
                                                color = colors.inkMuted,
                                            )
                                        }
                                    }
                                }

                                // Tags
                                if (details.tags.isNotEmpty()) {
                                    Spacer(modifier = Modifier.height(14.dp))
                                    FlowRow(
                                        horizontalArrangement = Arrangement.spacedBy(6.dp),
                                        verticalArrangement = Arrangement.spacedBy(6.dp),
                                    ) {
                                        details.tags.forEach { tag ->
                                            TagChip(tag = tag)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Attached Photographs (Polaroid display)
                    val photoAttachments = details.photoAttachments
                    if (photoAttachments.isNotEmpty()) {
                        item {
                            Text(
                                text = "PHOTOGRAPHS",
                                fontSize = 11.sp,
                                fontFamily = FontFamily.Monospace,
                                fontWeight = FontWeight.Bold,
                                color = colors.inkSecondary,
                                letterSpacing = 1.sp,
                            )
                        }

                        photoAttachments.forEachIndexed { index, photo ->
                            item {
                                PolaroidCard(
                                    imageUri = photo.uri,
                                    caption = photo.caption,
                                    rotation = if (index % 2 == 0) -1.5f else 1.5f,
                                    modifier = Modifier.fillMaxWidth(0.92f),
                                )
                            }
                        }
                    }

                    // Audio Memos (Cassette player display)
                    val audioAttachments = details.audioAttachments
                    if (audioAttachments.isNotEmpty()) {
                        item {
                            Text(
                                text = "VOICE RECORDINGS",
                                fontSize = 11.sp,
                                fontFamily = FontFamily.Monospace,
                                fontWeight = FontWeight.Bold,
                                color = colors.inkSecondary,
                                letterSpacing = 1.sp,
                            )
                        }

                        audioAttachments.forEach { audio ->
                            item {
                                AudioPlayerBar(
                                    isPlaying = playbackState.isPlaying && playbackState.playingUri == audio.uri,
                                    currentPositionMs = if (playbackState.playingUri == audio.uri) playbackState.currentPositionMs else 0L,
                                    totalDurationMs =
                                        audio.durationMs
                                            ?: (playbackState.totalDurationMs.takeIf { playbackState.playingUri == audio.uri } ?: 0L),
                                    onPlayPauseClick = {
                                        if (playbackState.isPlaying && playbackState.playingUri == audio.uri) {
                                            viewModel.audioPlayerHelper.pause()
                                        } else {
                                            viewModel.audioPlayerHelper.play(audio.uri)
                                        }
                                    },
                                )
                            }
                        }
                    }

                    // Cancellation Postmark Stamp
                    item {
                        Box(
                            modifier =
                                Modifier
                                    .fillMaxWidth()
                                    .padding(vertical = 12.dp),
                            contentAlignment = Alignment.Center,
                        ) {
                            PostmarkStamp(dateMillis = entry.entryDate, rotation = -4f)
                        }
                    }

                    item {
                        Spacer(modifier = Modifier.height(40.dp))
                    }
                }
            }
        }
    }

    if (showDeleteConfirmDialog) {
        AlertDialog(
            onDismissRequest = { showDeleteConfirmDialog = false },
            title = { Text("Delete Page", fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold) },
            text = { Text("Are you sure you want to permanently delete this journal page?") },
            confirmButton = {
                Button(
                    onClick = {
                        showDeleteConfirmDialog = false
                        viewModel.deleteEntry()
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = PostmarkRed),
                ) {
                    Text("Delete")
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteConfirmDialog = false }) {
                    Text("Cancel")
                }
            },
        )
    }
}
