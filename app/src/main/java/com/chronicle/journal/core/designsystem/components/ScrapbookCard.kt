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
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.chronicle.journal.core.common.TimeUtils
import com.chronicle.journal.core.designsystem.theme.HandwrittenCaptionStyle
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.core.designsystem.theme.VintageGold
import com.chronicle.journal.core.designsystem.theme.WashiTapeSage
import com.chronicle.journal.domain.model.JournalWithDetails

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun ScrapbookCard(
    details: JournalWithDetails,
    modifier: Modifier = Modifier,
    onFavoriteToggle: (() -> Unit)? = null,
    onClick: () -> Unit,
) {
    val colors = LocalChronicleColors.current
    val entry = details.entry
    val hasPhotos = details.photoAttachments.isNotEmpty() || entry.coverImageUri != null
    val hasAudio = details.audioAttachments.isNotEmpty()

    Box(
        modifier =
            modifier
                .shadow(4.dp, RoundedCornerShape(4.dp))
                .background(colors.paperCard, RoundedCornerShape(4.dp))
                .border(1.dp, colors.paperCardBorder, RoundedCornerShape(4.dp))
                .clickable { onClick() }
                .padding(14.dp),
    ) {
        // Washi Tape at Top Corner
        WashiTape(
            modifier =
                Modifier
                    .align(Alignment.TopEnd)
                    .padding(top = (-18).dp, end = 12.dp),
            rotation = 8f,
            color = WashiTapeSage,
        )

        Column(modifier = Modifier.fillMaxWidth()) {
            // Header: Date & Mood & Favorite
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
                            fontSize = 12.sp,
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
                    MoodBadge(
                        mood = entry.mood,
                        intensity = entry.moodIntensity,
                        showLabel = false,
                    )

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

            // Title
            Text(
                text = entry.title,
                fontFamily = FontFamily.Serif,
                fontWeight = FontWeight.Bold,
                fontSize = 18.sp,
                color = colors.inkPrimary,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
            )

            Spacer(modifier = Modifier.height(4.dp))

            // If entry has a photo, show mini polaroid preview inside card
            val photoUri = details.primaryImageUri
            if (photoUri != null) {
                Spacer(modifier = Modifier.height(6.dp))
                PolaroidCard(
                    imageUri = photoUri,
                    caption = null,
                    rotation = -1.5f,
                    showTape = false,
                    modifier =
                        Modifier
                            .fillMaxWidth(0.85f)
                            .align(Alignment.CenterHorizontally),
                )
                Spacer(modifier = Modifier.height(10.dp))
            }

            // Excerpt in handwritten note style
            Text(
                text = entry.content,
                style = HandwrittenCaptionStyle,
                fontSize = 15.sp,
                color = colors.inkSecondary,
                maxLines = if (hasPhotos) 2 else 4,
                overflow = TextOverflow.Ellipsis,
            )

            // Audio & Location indicator
            if (hasAudio || entry.locationName != null || entry.weatherSummary != null) {
                Spacer(modifier = Modifier.height(8.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    if (hasAudio) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(3.dp),
                            modifier =
                                Modifier
                                    .border(1.dp, colors.paperCardBorder, RoundedCornerShape(10.dp))
                                    .background(colors.paperSurface, RoundedCornerShape(10.dp))
                                    .padding(horizontal = 6.dp, vertical = 2.dp),
                        ) {
                            Icon(
                                imageVector = Icons.Default.Mic,
                                contentDescription = "Audio note",
                                tint = colors.inkSecondary,
                                modifier = Modifier.size(12.dp),
                            )
                            Text(
                                text = "Voice memo",
                                fontSize = 10.sp,
                                fontFamily = FontFamily.Monospace,
                                color = colors.inkSecondary,
                            )
                        }
                    }
                    if (entry.locationName != null) {
                        Text(
                            text = "📍 ${entry.locationName}",
                            fontSize = 10.sp,
                            color = colors.inkMuted,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                    }
                    if (entry.weatherSummary != null) {
                        Text(
                            text = "⛅ ${entry.weatherSummary}${entry.weatherTemperature?.let { " $it°C" } ?: ""}",
                            fontSize = 10.sp,
                            color = colors.inkMuted,
                        )
                    }
                }
            }

            // Tags flow
            if (details.tags.isNotEmpty()) {
                Spacer(modifier = Modifier.height(8.dp))
                FlowRow(
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp),
                ) {
                    details.tags.forEach { tag ->
                        TagChip(tag = tag)
                    }
                }
            }
        }
    }
}
