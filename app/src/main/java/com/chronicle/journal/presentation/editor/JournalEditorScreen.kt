package com.chronicle.journal.presentation.editor

import android.net.Uri
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
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
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.AddLocation
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material.icons.outlined.StarBorder
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.chronicle.journal.core.common.TimeUtils
import com.chronicle.journal.core.designsystem.components.AudioPlayerBar
import com.chronicle.journal.core.designsystem.components.JournalCard
import com.chronicle.journal.core.designsystem.components.MoodSelector
import com.chronicle.journal.core.designsystem.components.SectionHeader
import com.chronicle.journal.core.designsystem.theme.HandwrittenCaptionStyle
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.core.designsystem.theme.PaperBackground
import com.chronicle.journal.core.designsystem.theme.PostmarkRed
import com.chronicle.journal.core.designsystem.theme.VintageGold
import com.chronicle.journal.domain.model.AttachmentType
import com.chronicle.journal.domain.model.JournalEntry
import com.chronicle.journal.domain.model.JournalLayout
import com.chronicle.journal.domain.model.JournalWithDetails
import com.chronicle.journal.presentation.media.RecordingState

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun JournalEditorScreen(
    onNavigateBack: () -> Unit,
    viewModel: JournalEditorViewModel = hiltViewModel(),
) {
    val state by viewModel.uiState.collectAsState()
    val recordingState by viewModel.audioRecorderHelper.recordingState.collectAsState()
    val playbackState by viewModel.audioPlayerHelper.playbackState.collectAsState()
    val colors = LocalChronicleColors.current
    val context = LocalContext.current

    var showDeleteConfirmDialog by remember { mutableStateOf(false) }
    var showAddTagDialog by remember { mutableStateOf(false) }
    var newTagInput by remember { mutableStateOf("") }

    // Modern Android Photo Picker
    val photoPickerLauncher =
        rememberLauncherForActivityResult(
            contract = ActivityResultContracts.PickMultipleVisualMedia(),
        ) { uris: List<Uri> ->
            uris.forEach { uri ->
                viewModel.addPhotoAttachment(uri.toString())
            }
        }

    LaunchedEffect(Unit) {
        viewModel.events.collect { event ->
            when (event) {
                is EditorUiEvent.ShowToast -> {
                    Toast.makeText(context, event.message, Toast.LENGTH_SHORT).show()
                }
                is EditorUiEvent.EntrySaved, is EditorUiEvent.EntryDeleted -> {
                    onNavigateBack()
                }
            }
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            text = if (state.entryId > 0) "Edit Page" else "New Entry",
                            fontFamily = FontFamily.Serif,
                            fontWeight = FontWeight.Bold,
                            fontSize = 18.sp,
                            color = colors.inkPrimary,
                        )
                        if (state.lastSavedMessage.isNotBlank()) {
                            Text(
                                text = state.lastSavedMessage,
                                fontFamily = FontFamily.Monospace,
                                fontSize = 10.sp,
                                color = colors.inkMuted,
                            )
                        }
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
                actions = {
                    // Preview Toggle
                    IconButton(onClick = { viewModel.togglePreviewMode() }) {
                        Icon(
                            imageVector = if (state.isPreviewMode) Icons.Default.VisibilityOff else Icons.Default.Visibility,
                            contentDescription = "Toggle Preview",
                            tint = colors.inkPrimary,
                        )
                    }

                    // Favorite Toggle
                    IconButton(onClick = { viewModel.onFavoriteToggle() }) {
                        Icon(
                            imageVector = if (state.isFavorite) Icons.Filled.Star else Icons.Outlined.StarBorder,
                            contentDescription = "Favorite",
                            tint = if (state.isFavorite) VintageGold else colors.inkMuted,
                        )
                    }

                    // Delete button if existing entry
                    if (state.entryId > 0) {
                        IconButton(onClick = { showDeleteConfirmDialog = true }) {
                            Icon(
                                imageVector = Icons.Default.Delete,
                                contentDescription = "Delete",
                                tint = PostmarkRed,
                            )
                        }
                    }

                    // Save Button
                    IconButton(
                        onClick = { viewModel.saveEntry() },
                        enabled = !state.isSaving,
                    ) {
                        if (state.isSaving) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(20.dp),
                                color = colors.inkPrimary,
                                strokeWidth = 2.dp,
                            )
                        } else {
                            Icon(
                                imageVector = Icons.Default.Check,
                                contentDescription = "Save",
                                tint = colors.inkPrimary,
                            )
                        }
                    }
                },
                colors =
                    TopAppBarDefaults.topAppBarColors(
                        containerColor = colors.paperBackground,
                    ),
            )
        },
    ) { paddingValues ->
        PaperBackground(modifier = Modifier.padding(paddingValues)) {
            if (state.isPreviewMode) {
                // Live Layout Preview
                val previewDetails =
                    JournalWithDetails(
                        entry =
                            JournalEntry(
                                id = state.entryId,
                                title = state.title.ifBlank { "Untitled Page" },
                                content = state.content,
                                entryDate = state.entryDate,
                                mood = state.mood,
                                moodIntensity = state.moodIntensity,
                                isFavorite = state.isFavorite,
                                locationName = state.locationName,
                                weatherSummary = state.weatherSummary,
                                weatherTemperature = state.weatherTemperature,
                                coverImageUri = state.attachments.firstOrNull { it.type == AttachmentType.PHOTO }?.uri,
                                layoutStyle = state.layoutStyle,
                            ),
                        tags = state.tags,
                        attachments = state.attachments,
                    )

                LazyColumn(
                    modifier =
                        Modifier
                            .fillMaxSize()
                            .padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                ) {
                    item {
                        Text(
                            text = "PREVIEW MODE (${state.layoutStyle.displayName})",
                            fontSize = 11.sp,
                            fontFamily = FontFamily.Monospace,
                            fontWeight = FontWeight.Bold,
                            color = VintageGold,
                            letterSpacing = 1.sp,
                        )
                    }
                    item {
                        JournalCard(
                            details = previewDetails,
                            forcedLayout = state.layoutStyle,
                            onClick = {},
                        )
                    }
                }
            } else {
                // Editor Form
                LazyColumn(
                    modifier =
                        Modifier
                            .fillMaxSize()
                            .padding(horizontal = 16.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp),
                ) {
                    // Date & Layout selector header
                    item {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Text(
                                text = "📅 " + TimeUtils.formatFullDate(state.entryDate),
                                fontFamily = FontFamily.Monospace,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Bold,
                                color = colors.inkSecondary,
                            )
                        }
                    }

                    // Layout Style Chips
                    item {
                        Column {
                            Text(
                                text = "LAYOUT STYLE",
                                fontSize = 10.sp,
                                fontFamily = FontFamily.Monospace,
                                color = colors.inkMuted,
                                letterSpacing = 1.sp,
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            LazyRow(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                                items(JournalLayout.entries) { layout ->
                                    FilterChip(
                                        selected = state.layoutStyle == layout,
                                        onClick = { viewModel.onLayoutStyleChange(layout) },
                                        label = {
                                            Text(
                                                text = layout.displayName,
                                                fontSize = 11.sp,
                                                fontFamily = FontFamily.Monospace,
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
                    }

                    // Title Input
                    item {
                        BasicTextField(
                            value = state.title,
                            onValueChange = { viewModel.onTitleChange(it) },
                            textStyle =
                                TextStyle(
                                    fontFamily = FontFamily.Serif,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 22.sp,
                                    color = colors.inkPrimary,
                                ),
                            cursorBrush = SolidColor(colors.inkPrimary),
                            decorationBox = { innerTextField ->
                                Box(modifier = Modifier.fillMaxWidth()) {
                                    if (state.title.isEmpty()) {
                                        Text(
                                            text = "Title of your story...",
                                            fontFamily = FontFamily.Serif,
                                            fontWeight = FontWeight.Bold,
                                            fontSize = 22.sp,
                                            color = colors.inkMuted,
                                        )
                                    }
                                    innerTextField()
                                }
                            },
                            modifier = Modifier.fillMaxWidth(),
                        )
                    }

                    // Content Input
                    item {
                        Box(
                            modifier =
                                Modifier
                                    .fillMaxWidth()
                                    .border(1.dp, colors.paperCardBorder, RoundedCornerShape(6.dp))
                                    .background(colors.paperCard, RoundedCornerShape(6.dp))
                                    .padding(14.dp),
                        ) {
                            BasicTextField(
                                value = state.content,
                                onValueChange = { viewModel.onContentChange(it) },
                                textStyle =
                                    TextStyle(
                                        fontFamily = FontFamily.Serif,
                                        fontSize = 16.sp,
                                        lineHeight = 24.sp,
                                        color = colors.inkPrimary,
                                    ),
                                cursorBrush = SolidColor(colors.inkPrimary),
                                minLines = 8,
                                decorationBox = { innerTextField ->
                                    Box(modifier = Modifier.fillMaxWidth()) {
                                        if (state.content.isEmpty()) {
                                            Text(
                                                text = "What was on your mind today? Write freely...",
                                                fontFamily = FontFamily.Serif,
                                                fontSize = 16.sp,
                                                color = colors.inkMuted,
                                            )
                                        }
                                        innerTextField()
                                    }
                                },
                                modifier = Modifier.fillMaxWidth(),
                            )
                        }
                    }

                    // Mood Selector
                    item {
                        MoodSelector(
                            selectedMood = state.mood,
                            intensity = state.moodIntensity,
                            onMoodSelected = { viewModel.onMoodChange(it) },
                            onIntensityChanged = { viewModel.onMoodIntensityChange(it) },
                        )
                    }

                    // Location & Weather Optional Card
                    item {
                        Box(
                            modifier =
                                Modifier
                                    .fillMaxWidth()
                                    .border(1.dp, colors.paperCardBorder, RoundedCornerShape(6.dp))
                                    .background(colors.paperCard, RoundedCornerShape(6.dp))
                                    .padding(12.dp),
                        ) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically,
                            ) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(
                                        text = "LOCATION & WEATHER",
                                        fontSize = 10.sp,
                                        fontFamily = FontFamily.Monospace,
                                        color = colors.inkMuted,
                                    )
                                    if (state.locationName != null || state.weatherSummary != null) {
                                        Text(
                                            text =
                                                buildString {
                                                    state.locationName?.let { append("📍 $it  ") }
                                                    state.weatherSummary?.let {
                                                        append("${state.weatherIcon ?: "⛅"} $it")
                                                        state.weatherTemperature?.let { temp -> append(" $temp°C") }
                                                    }
                                                },
                                            fontSize = 12.sp,
                                            fontFamily = FontFamily.Monospace,
                                            color = colors.inkPrimary,
                                        )
                                    } else {
                                        Text(
                                            text = "None attached (optional)",
                                            fontSize = 12.sp,
                                            style = HandwrittenCaptionStyle,
                                            color = colors.inkMuted,
                                        )
                                    }
                                }

                                TextButton(onClick = { viewModel.fetchCurrentLocationAndWeather() }) {
                                    Icon(
                                        imageVector = Icons.Default.AddLocation,
                                        contentDescription = null,
                                        modifier = Modifier.size(16.dp),
                                    )
                                    Spacer(modifier = Modifier.width(4.dp))
                                    Text(
                                        text = if (state.locationName != null) "Refresh" else "Add",
                                        fontSize = 12.sp,
                                        fontFamily = FontFamily.Monospace,
                                    )
                                }
                            }
                        }
                    }

                    // Photos Section
                    item {
                        SectionHeader(
                            title = "Photographs",
                            actionLabel = "+ ADD PHOTO",
                            onActionClick = {
                                photoPickerLauncher.launch(
                                    PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly),
                                )
                            },
                        )

                        val photoAttachments = state.attachments.filter { it.type == AttachmentType.PHOTO }
                        if (photoAttachments.isNotEmpty()) {
                            LazyRow(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                                items(photoAttachments) { photo ->
                                    Box(
                                        modifier =
                                            Modifier
                                                .size(width = 110.dp, height = 130.dp)
                                                .border(1.dp, colors.paperCardBorder, RoundedCornerShape(4.dp))
                                                .background(colors.paperCard, RoundedCornerShape(4.dp))
                                                .padding(6.dp),
                                    ) {
                                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                            AsyncImage(
                                                model =
                                                    ImageRequest
                                                        .Builder(context)
                                                        .data(photo.uri)
                                                        .crossfade(true)
                                                        .build(),
                                                contentDescription = "Attachment",
                                                contentScale = ContentScale.Crop,
                                                modifier =
                                                    Modifier
                                                        .fillMaxWidth()
                                                        .height(90.dp)
                                                        .clip(RoundedCornerShape(2.dp)),
                                            )
                                        }

                                        IconButton(
                                            onClick = { viewModel.removeAttachment(photo) },
                                            modifier =
                                                Modifier
                                                    .align(Alignment.TopEnd)
                                                    .size(24.dp)
                                                    .background(Color.Black.copy(alpha = 0.6f), CircleShape),
                                        ) {
                                            Icon(
                                                imageVector = Icons.Default.Close,
                                                contentDescription = "Remove photo",
                                                tint = Color.White,
                                                modifier = Modifier.size(14.dp),
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Audio Journal Section
                    item {
                        SectionHeader(title = "Voice Notes")

                        // Existing audio attachments
                        val audioAttachments = state.attachments.filter { it.type == AttachmentType.AUDIO }
                        audioAttachments.forEach { audio ->
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
                                onDeleteClick = { viewModel.removeAttachment(audio) },
                            )
                            Spacer(modifier = Modifier.height(6.dp))
                        }

                        // Voice Recorder Controls
                        Box(
                            modifier =
                                Modifier
                                    .fillMaxWidth()
                                    .border(1.dp, colors.paperCardBorder, RoundedCornerShape(6.dp))
                                    .background(colors.paperCard, RoundedCornerShape(6.dp))
                                    .padding(12.dp),
                        ) {
                            when (recordingState) {
                                is RecordingState.Idle -> {
                                    Row(
                                        modifier = Modifier.fillMaxWidth(),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.CenterVertically,
                                    ) {
                                        Text(
                                            text = "Record an audio memo",
                                            fontSize = 13.sp,
                                            fontFamily = FontFamily.Monospace,
                                            color = colors.inkSecondary,
                                        )
                                        Button(
                                            onClick = { viewModel.audioRecorderHelper.startRecording() },
                                            colors =
                                                ButtonDefaults.buttonColors(
                                                    containerColor = PostmarkRed,
                                                    contentColor = Color.White,
                                                ),
                                            shape = RoundedCornerShape(16.dp),
                                        ) {
                                            Icon(
                                                imageVector = Icons.Default.Mic,
                                                contentDescription = null,
                                                modifier = Modifier.size(16.dp),
                                            )
                                            Spacer(modifier = Modifier.width(4.dp))
                                            Text("Record", fontSize = 12.sp)
                                        }
                                    }
                                }
                                is RecordingState.Recording -> {
                                    val duration = (recordingState as RecordingState.Recording).durationMs
                                    Row(
                                        modifier = Modifier.fillMaxWidth(),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.CenterVertically,
                                    ) {
                                        Row(
                                            verticalAlignment = Alignment.CenterVertically,
                                            horizontalArrangement = Arrangement.spacedBy(6.dp),
                                        ) {
                                            Box(
                                                modifier =
                                                    Modifier
                                                        .size(10.dp)
                                                        .background(PostmarkRed, CircleShape),
                                            )
                                            Text(
                                                text = "Recording: ${TimeUtils.formatDuration(duration)}",
                                                fontFamily = FontFamily.Monospace,
                                                fontSize = 13.sp,
                                                fontWeight = FontWeight.Bold,
                                                color = PostmarkRed,
                                            )
                                        }

                                        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                                            IconButton(
                                                onClick = { viewModel.audioRecorderHelper.pauseRecording() },
                                                modifier = Modifier.size(32.dp),
                                            ) {
                                                Icon(
                                                    imageVector = Icons.Default.Pause,
                                                    contentDescription = "Pause",
                                                    tint = colors.inkPrimary,
                                                )
                                            }
                                            IconButton(
                                                onClick = { viewModel.audioRecorderHelper.stopRecording() },
                                                modifier = Modifier.size(32.dp),
                                            ) {
                                                Icon(
                                                    imageVector = Icons.Default.Stop,
                                                    contentDescription = "Stop",
                                                    tint = PostmarkRed,
                                                )
                                            }
                                        }
                                    }
                                }
                                is RecordingState.Paused -> {
                                    val duration = (recordingState as RecordingState.Paused).durationMs
                                    Row(
                                        modifier = Modifier.fillMaxWidth(),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.CenterVertically,
                                    ) {
                                        Text(
                                            text = "Paused: ${TimeUtils.formatDuration(duration)}",
                                            fontFamily = FontFamily.Monospace,
                                            fontSize = 13.sp,
                                            color = colors.inkMuted,
                                        )
                                        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                                            IconButton(onClick = { viewModel.audioRecorderHelper.resumeRecording() }) {
                                                Icon(Icons.Default.PlayArrow, contentDescription = "Resume")
                                            }
                                            IconButton(onClick = { viewModel.audioRecorderHelper.stopRecording() }) {
                                                Icon(Icons.Default.Stop, contentDescription = "Stop", tint = PostmarkRed)
                                            }
                                        }
                                    }
                                }
                                else -> {}
                            }
                        }
                    }

                    // Tags Section
                    item {
                        SectionHeader(
                            title = "Tags",
                            actionLabel = "+ ADD TAG",
                            onActionClick = { showAddTagDialog = true },
                        )

                        FlowRow(
                            horizontalArrangement = Arrangement.spacedBy(6.dp),
                            verticalArrangement = Arrangement.spacedBy(6.dp),
                        ) {
                            state.tags.forEach { tag ->
                                FilterChip(
                                    selected = true,
                                    onClick = { viewModel.removeTag(tag) },
                                    label = { Text("#${tag.name}", fontSize = 12.sp) },
                                    trailingIcon = {
                                        Icon(
                                            imageVector = Icons.Default.Close,
                                            contentDescription = "Remove tag",
                                            modifier = Modifier.size(12.dp),
                                        )
                                    },
                                )
                            }
                        }
                    }

                    // Collections Section
                    if (state.availableCollections.isNotEmpty()) {
                        item {
                            SectionHeader(title = "Collections")
                            FlowRow(
                                horizontalArrangement = Arrangement.spacedBy(6.dp),
                                verticalArrangement = Arrangement.spacedBy(6.dp),
                            ) {
                                state.availableCollections.forEach { collection ->
                                    val isSelected = state.selectedCollectionIds.contains(collection.id)
                                    FilterChip(
                                        selected = isSelected,
                                        onClick = { viewModel.toggleCollection(collection.id) },
                                        label = { Text(collection.name, fontSize = 12.sp) },
                                        colors =
                                            FilterChipDefaults.filterChipColors(
                                                selectedContainerColor = colors.inkPrimary,
                                                selectedLabelColor = colors.paperCard,
                                            ),
                                    )
                                }
                            }
                        }
                    }

                    item {
                        Spacer(modifier = Modifier.height(40.dp))
                    }
                }
            }
        }
    }

    // Add Tag Dialog
    if (showAddTagDialog) {
        AlertDialog(
            onDismissRequest = { showAddTagDialog = false },
            title = {
                Text(
                    text = "Add Tag",
                    fontFamily = FontFamily.Serif,
                    fontWeight = FontWeight.Bold,
                )
            },
            text = {
                Column {
                    OutlinedTextField(
                        value = newTagInput,
                        onValueChange = { newTagInput = it },
                        label = { Text("Tag Name (e.g. travel, thoughts)") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth(),
                    )

                    // Predefined Tag suggestions
                    if (state.allAvailableTags.isNotEmpty()) {
                        Spacer(modifier = Modifier.height(10.dp))
                        Text(
                            text = "Existing tags:",
                            fontSize = 11.sp,
                            fontFamily = FontFamily.Monospace,
                            color = colors.inkMuted,
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        FlowRow(
                            horizontalArrangement = Arrangement.spacedBy(4.dp),
                            verticalArrangement = Arrangement.spacedBy(4.dp),
                        ) {
                            state.allAvailableTags.forEach { existing ->
                                Text(
                                    text = "#${existing.name}",
                                    fontSize = 11.sp,
                                    color = colors.inkSecondary,
                                    modifier =
                                        Modifier
                                            .background(colors.paperSurface, RoundedCornerShape(8.dp))
                                            .clickable {
                                                viewModel.addTag(existing.name, existing.colorHex)
                                                showAddTagDialog = false
                                                newTagInput = ""
                                            }.padding(horizontal = 6.dp, vertical = 2.dp),
                                )
                            }
                        }
                    }
                }
            },
            confirmButton = {
                Button(
                    onClick = {
                        if (newTagInput.isNotBlank()) {
                            viewModel.addTag(newTagInput)
                            newTagInput = ""
                            showAddTagDialog = false
                        }
                    },
                ) {
                    Text("Add")
                }
            },
            dismissButton = {
                TextButton(onClick = { showAddTagDialog = false }) {
                    Text("Cancel")
                }
            },
        )
    }

    // Delete Confirmation Dialog
    if (showDeleteConfirmDialog) {
        AlertDialog(
            onDismissRequest = { showDeleteConfirmDialog = false },
            title = { Text("Delete Entry?", fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold) },
            text = { Text("Are you sure you want to delete this journal page? This will move it to archive.") },
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
