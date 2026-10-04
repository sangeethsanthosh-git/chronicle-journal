package com.chronicle.journal.core.designsystem.components

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
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.outlined.StarBorder
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.chronicle.journal.core.common.TimeUtils
import com.chronicle.journal.core.designsystem.theme.HandwrittenCaptionStyle
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.core.designsystem.theme.VintageGold
import com.chronicle.journal.domain.model.JournalLayout
import com.chronicle.journal.domain.model.JournalWithDetails

@Composable
fun JournalCard(
    details: JournalWithDetails,
    modifier: Modifier = Modifier,
    forcedLayout: JournalLayout? = null,
    onFavoriteToggle: (() -> Unit)? = null,
    onClick: () -> Unit,
) {
    val layout = forcedLayout ?: details.entry.layoutStyle

    when (layout) {
        JournalLayout.SCRAPBOOK -> {
            ScrapbookCard(
                details = details,
                modifier = modifier,
                onFavoriteToggle = onFavoriteToggle,
                onClick = onClick,
            )
        }
        JournalLayout.POSTCARD -> {
            PostcardCard(
                details = details,
                modifier = modifier,
                onClick = onClick,
            )
        }
        JournalLayout.PHOTO_DIARY -> {
            PhotoDiaryCard(
                details = details,
                modifier = modifier,
                onFavoriteToggle = onFavoriteToggle,
                onClick = onClick,
            )
        }
        JournalLayout.MINIMAL -> {
            MinimalCard(
                details = details,
                modifier = modifier,
                onFavoriteToggle = onFavoriteToggle,
                onClick = onClick,
            )
        }
        JournalLayout.OPEN_BINDER -> {
            OpenBinderCard(
                details = details,
                modifier = modifier,
                onFavoriteToggle = onFavoriteToggle,
                onClick = onClick,
            )
        }
        JournalLayout.PANORAMA_EDITORIAL -> {
            PanoramaEditorialCard(
                details = details,
                modifier = modifier,
                onFavoriteToggle = onFavoriteToggle,
                onClick = onClick,
            )
        }
        JournalLayout.CLASSIC -> {
            ClassicJournalCard(
                details = details,
                modifier = modifier,
                onFavoriteToggle = onFavoriteToggle,
                onClick = onClick,
            )
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun ClassicJournalCard(
    details: JournalWithDetails,
    modifier: Modifier = Modifier,
    onFavoriteToggle: (() -> Unit)? = null,
    onClick: () -> Unit,
) {
    val colors = LocalChronicleColors.current
    val context = LocalContext.current
    val entry = details.entry
    val imageUri = details.primaryImageUri
    val hasAudio = details.audioAttachments.isNotEmpty()

    Box(
        modifier =
            modifier
                .shadow(2.dp, RoundedCornerShape(8.dp))
                .background(colors.paperCard, RoundedCornerShape(8.dp))
                .border(1.dp, colors.paperCardBorder, RoundedCornerShape(8.dp))
                .clickable { onClick() }
                .padding(14.dp),
    ) {
        Column(modifier = Modifier.fillMaxWidth()) {
            // Header: Date, Mood & Star
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    DateBadge(dateMillis = entry.entryDate)
                    Column {
                        Text(
                            text = TimeUtils.formatShortDate(entry.entryDate),
                            fontFamily = FontFamily.Monospace,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            color = colors.inkPrimary,
                        )
                        Text(
                            text = TimeUtils.formatTime(entry.createdAt),
                            fontFamily = FontFamily.Monospace,
                            fontSize = 10.sp,
                            color = colors.inkMuted,
                        )
                    }
                }

                Row(verticalAlignment = Alignment.CenterVertically) {
                    MoodBadge(mood = entry.mood, intensity = entry.moodIntensity, showLabel = true)
                    if (onFavoriteToggle != null) {
                        IconButton(onClick = onFavoriteToggle, modifier = Modifier.size(36.dp)) {
                            Icon(
                                imageVector = if (entry.isFavorite) Icons.Filled.Star else Icons.Outlined.StarBorder,
                                contentDescription = "Favorite",
                                tint = if (entry.isFavorite) VintageGold else colors.inkMuted,
                                modifier = Modifier.size(20.dp),
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Body: Title & Content with optional thumbnail side by side
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = entry.title,
                        fontFamily = FontFamily.Serif,
                        fontWeight = FontWeight.Bold,
                        fontSize = 17.sp,
                        color = colors.inkPrimary,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis,
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = entry.content,
                        fontSize = 14.sp,
                        fontFamily = FontFamily.Serif,
                        color = colors.inkSecondary,
                        lineHeight = 20.sp,
                        maxLines = 3,
                        overflow = TextOverflow.Ellipsis,
                    )
                }

                if (imageUri != null) {
                    AsyncImage(
                        model =
                            ImageRequest
                                .Builder(context)
                                .data(imageUri)
                                .crossfade(true)
                                .build(),
                        contentDescription = "Entry image",
                        contentScale = ContentScale.Crop,
                        modifier =
                            Modifier
                                .size(70.dp)
                                .clip(RoundedCornerShape(6.dp))
                                .border(1.dp, colors.paperCardBorder, RoundedCornerShape(6.dp)),
                    )
                }
            }

            // Footer
            Spacer(modifier = Modifier.height(8.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                if (details.tags.isNotEmpty()) {
                    FlowRow(
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        modifier = Modifier.weight(1f),
                    ) {
                        details.tags.take(3).forEach { tag ->
                            TagChip(tag = tag)
                        }
                    }
                } else {
                    Spacer(modifier = Modifier.weight(1f))
                }

                if (hasAudio) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(2.dp),
                    ) {
                        Icon(
                            imageVector = Icons.Default.Mic,
                            contentDescription = "Voice recording",
                            tint = colors.inkMuted,
                            modifier = Modifier.size(14.dp),
                        )
                        Text(
                            text = "Audio",
                            fontSize = 10.sp,
                            fontFamily = FontFamily.Monospace,
                            color = colors.inkMuted,
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun MinimalCard(
    details: JournalWithDetails,
    modifier: Modifier = Modifier,
    onFavoriteToggle: (() -> Unit)? = null,
    onClick: () -> Unit,
) {
    val colors = LocalChronicleColors.current
    val entry = details.entry

    Column(
        modifier =
            modifier
                .fillMaxWidth()
                .clickable { onClick() }
                .padding(vertical = 12.dp, horizontal = 4.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = TimeUtils.formatShortDate(entry.entryDate).uppercase(),
                fontSize = 11.sp,
                fontFamily = FontFamily.Monospace,
                color = colors.inkMuted,
                letterSpacing = 1.sp,
            )
            Row(verticalAlignment = Alignment.CenterVertically) {
                MoodBadge(mood = entry.mood, intensity = entry.moodIntensity, showLabel = false)
                if (entry.isFavorite) {
                    Icon(
                        imageVector = Icons.Filled.Star,
                        contentDescription = "Favorite",
                        tint = VintageGold,
                        modifier = Modifier.padding(start = 6.dp).size(16.dp),
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(4.dp))

        Text(
            text = entry.title,
            fontFamily = FontFamily.Serif,
            fontWeight = FontWeight.SemiBold,
            fontSize = 17.sp,
            color = colors.inkPrimary,
        )

        Spacer(modifier = Modifier.height(2.dp))

        Text(
            text = entry.content,
            fontSize = 14.sp,
            color = colors.inkSecondary,
            maxLines = 2,
            overflow = TextOverflow.Ellipsis,
        )

        Spacer(modifier = Modifier.height(8.dp))
        Box(
            modifier =
                Modifier
                    .fillMaxWidth()
                    .height(1.dp)
                    .background(colors.ruledLine),
        )
    }
}

@Composable
fun PhotoDiaryCard(
    details: JournalWithDetails,
    modifier: Modifier = Modifier,
    onFavoriteToggle: (() -> Unit)? = null,
    onClick: () -> Unit,
) {
    val colors = LocalChronicleColors.current
    val context = LocalContext.current
    val entry = details.entry
    val imageUri = details.primaryImageUri

    Box(
        modifier =
            modifier
                .shadow(4.dp, RoundedCornerShape(6.dp))
                .background(colors.paperCard, RoundedCornerShape(6.dp))
                .border(1.dp, colors.paperCardBorder, RoundedCornerShape(6.dp))
                .clickable { onClick() }
                .padding(10.dp),
    ) {
        Column(modifier = Modifier.fillMaxWidth()) {
            if (imageUri != null) {
                AsyncImage(
                    model =
                        ImageRequest
                            .Builder(context)
                            .data(imageUri)
                            .crossfade(true)
                            .build(),
                    contentDescription = entry.title,
                    contentScale = ContentScale.Crop,
                    modifier =
                        Modifier
                            .fillMaxWidth()
                            .aspectRatio(1.2f)
                            .clip(RoundedCornerShape(4.dp)),
                )
                Spacer(modifier = Modifier.height(8.dp))
            }

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = TimeUtils.formatFullDate(entry.entryDate),
                    fontSize = 11.sp,
                    fontFamily = FontFamily.Monospace,
                    color = colors.inkMuted,
                )
                MoodBadge(mood = entry.mood, intensity = entry.moodIntensity, showLabel = true)
            }

            Spacer(modifier = Modifier.height(6.dp))

            Text(
                text = entry.title,
                fontFamily = FontFamily.Serif,
                fontWeight = FontWeight.Bold,
                fontSize = 18.sp,
                color = colors.inkPrimary,
            )

            Spacer(modifier = Modifier.height(4.dp))

            Text(
                text = entry.content,
                style = HandwrittenCaptionStyle,
                fontSize = 15.sp,
                color = colors.inkSecondary,
                maxLines = 3,
                overflow = TextOverflow.Ellipsis,
            )
        }
    }
}
