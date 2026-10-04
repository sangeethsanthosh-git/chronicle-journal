package com.chronicle.journal.core.designsystem.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
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
import com.chronicle.journal.domain.model.JournalWithDetails

@Composable
fun PostcardCard(
    details: JournalWithDetails,
    modifier: Modifier = Modifier,
    onClick: () -> Unit,
) {
    val colors = LocalChronicleColors.current
    val context = LocalContext.current
    val entry = details.entry
    val imageUri = details.primaryImageUri

    Box(
        modifier =
            modifier
                .shadow(4.dp, RoundedCornerShape(4.dp))
                .background(colors.paperCard, RoundedCornerShape(4.dp))
                .border(1.dp, colors.paperCardBorder, RoundedCornerShape(4.dp))
                .clickable { onClick() }
                .padding(12.dp),
    ) {
        Column(modifier = Modifier.fillMaxWidth()) {
            // Optional Top Photo
            if (imageUri != null) {
                Box(
                    modifier =
                        Modifier
                            .fillMaxWidth()
                            .aspectRatio(1.8f)
                            .border(1.dp, colors.paperCardBorder, RoundedCornerShape(2.dp))
                            .background(Color(0xFF201E1C), RoundedCornerShape(2.dp)),
                ) {
                    AsyncImage(
                        model =
                            ImageRequest
                                .Builder(context)
                                .data(imageUri)
                                .crossfade(true)
                                .build(),
                        contentDescription = "Postcard image",
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.fillMaxWidth().aspectRatio(1.8f),
                    )

                    // Yellow vintage camera timestamp on corner
                    Text(
                        text = "'26 " + TimeUtils.formatDayOfMonth(entry.entryDate) + " " + TimeUtils.formatTime(entry.entryDate),
                        fontFamily = FontFamily.Monospace,
                        fontSize = 11.sp,
                        color = Color(0xFFFFD54F),
                        modifier =
                            Modifier
                                .align(Alignment.BottomEnd)
                                .padding(8.dp),
                    )
                }
                Spacer(modifier = Modifier.height(10.dp))
            }

            // Postcard Header Line
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = "POST CARD",
                    fontFamily = FontFamily.Serif,
                    fontWeight = FontWeight.Bold,
                    fontSize = 16.sp,
                    letterSpacing = 2.sp,
                    color = colors.inkPrimary,
                )
                Text(
                    text = TimeUtils.formatShortDate(entry.entryDate),
                    fontFamily = FontFamily.Monospace,
                    fontSize = 10.sp,
                    color = colors.inkMuted,
                )
            }

            // Divider rule
            Canvas(
                modifier =
                    Modifier
                        .fillMaxWidth()
                        .padding(vertical = 8.dp)
                        .height(1.dp),
            ) {
                drawLine(
                    color = colors.ruledLine,
                    start = Offset.Zero,
                    end = Offset(size.width, 0f),
                    strokeWidth = 1.dp.toPx(),
                )
            }

            // Split Postcard Body: Left text / Right stamps
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                // Left Column: Note
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "SPACE FOR MESSAGE",
                        fontSize = 8.sp,
                        fontFamily = FontFamily.Monospace,
                        color = colors.inkMuted,
                        letterSpacing = 0.5.sp,
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = entry.title,
                        fontWeight = FontWeight.Bold,
                        fontFamily = FontFamily.Serif,
                        fontSize = 15.sp,
                        color = colors.inkPrimary,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = entry.content,
                        style = HandwrittenCaptionStyle,
                        fontSize = 14.sp,
                        color = colors.inkSecondary,
                        maxLines = 3,
                        overflow = TextOverflow.Ellipsis,
                    )
                }

                // Vertical divider
                Box(
                    modifier =
                        Modifier
                            .width(1.dp)
                            .height(80.dp)
                            .background(colors.ruledLine),
                )

                // Right Column: Stamps & Address
                Column(
                    modifier = Modifier.width(100.dp),
                    horizontalAlignment = Alignment.End,
                    verticalArrangement = Arrangement.spacedBy(6.dp),
                ) {
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        verticalAlignment = Alignment.Top,
                    ) {
                        PostmarkStamp(
                            dateMillis = entry.entryDate,
                            rotation = -5f,
                        )
                    }
                    Text(
                        text = "To: Personal Memoir\nSomewhere in 2026",
                        fontSize = 8.sp,
                        fontFamily = FontFamily.Cursive,
                        color = colors.inkMuted,
                        lineHeight = 10.sp,
                    )
                }
            }

            // Footer tags & mood
            Spacer(modifier = Modifier.height(8.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                MoodBadge(mood = entry.mood, intensity = entry.moodIntensity, showLabel = true)
                if (entry.locationName != null) {
                    Text(
                        text = "📍 ${entry.locationName}",
                        fontSize = 10.sp,
                        color = colors.inkMuted,
                        maxLines = 1,
                    )
                }
            }
        }
    }
}
