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
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
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
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.chronicle.journal.core.common.TimeUtils
import com.chronicle.journal.core.designsystem.theme.VintageGold
import com.chronicle.journal.core.designsystem.theme.WashiTapeKraft
import com.chronicle.journal.domain.model.JournalWithDetails

/**
 * An authentic open ring-binder journal spread, directly inspired by reference image 2:
 * - Slate desktop backdrop
 * - Dual-page book spread with center metallic binder rings
 * - Left page: Taped photos and handwritten observations
 * - Right page: Torn paper notes and circular photo seals
 * - Bottom reminder banner: "reminder: progress matters more than perfection."
 */
@Composable
fun OpenBinderCard(
    details: JournalWithDetails,
    modifier: Modifier = Modifier,
    onFavoriteToggle: (() -> Unit)? = null,
    onClick: () -> Unit,
) {
    val entry = details.entry
    val primaryImage = details.primaryImageUri
    val context = LocalContext.current

    Column(
        modifier =
            modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(Color(0xFF384756))
                .clickable { onClick() }
                .padding(14.dp),
    ) {
        // The Open Binder Book Spread
        Box(
            modifier =
                Modifier
                    .fillMaxWidth()
                    .shadow(8.dp, RoundedCornerShape(8.dp))
                    .background(Color(0xFFF7F5EE), RoundedCornerShape(8.dp))
                    .border(1.dp, Color(0xFFDCD5C5), RoundedCornerShape(8.dp))
                    .padding(vertical = 12.dp),
        ) {
            Row(modifier = Modifier.fillMaxWidth()) {
                // Left Page
                Column(
                    modifier =
                        Modifier
                            .weight(1f)
                            .padding(start = 12.dp, end = 14.dp),
                ) {
                    // Header Date
                    Text(
                        text = TimeUtils.formatShortDate(entry.entryDate).uppercase(),
                        fontSize = 9.sp,
                        fontFamily = FontFamily.Monospace,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF706A62),
                        letterSpacing = 0.5.sp,
                    )

                    Spacer(modifier = Modifier.height(4.dp))

                    Text(
                        text = entry.title,
                        fontSize = 14.sp,
                        fontFamily = FontFamily.Serif,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF28231D),
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis,
                    )

                    Spacer(modifier = Modifier.height(8.dp))

                    if (primaryImage != null) {
                        // Taped photo with washi tape
                        Box(
                            modifier =
                                Modifier
                                    .fillMaxWidth()
                                    .aspectRatio(1.2f)
                                    .shadow(3.dp, RoundedCornerShape(4.dp))
                                    .background(Color.White, RoundedCornerShape(4.dp))
                                    .padding(4.dp),
                        ) {
                            AsyncImage(
                                model =
                                    ImageRequest
                                        .Builder(context)
                                        .data(primaryImage)
                                        .crossfade(true)
                                        .build(),
                                contentDescription = null,
                                contentScale = ContentScale.Crop,
                                modifier =
                                    Modifier
                                        .fillMaxWidth()
                                        .fillMaxHeight()
                                        .clip(RoundedCornerShape(2.dp)),
                            )

                            // Corner washi tape
                            WashiTape(
                                modifier =
                                    Modifier
                                        .align(Alignment.TopStart)
                                        .padding(start = 2.dp, top = 2.dp),
                                width = 36.dp,
                                height = 12.dp,
                                color = WashiTapeKraft,
                                rotation = -25f,
                            )
                        }
                    } else {
                        // Handwritten thought snippet
                        Text(
                            text = entry.content,
                            fontSize = 12.sp,
                            fontFamily = FontFamily.Cursive,
                            color = Color(0xFF38322A),
                            lineHeight = 17.sp,
                            maxLines = 5,
                            overflow = TextOverflow.Ellipsis,
                        )
                    }
                }

                // Center Binding Spine with Metallic Rings
                Box(
                    modifier =
                        Modifier
                            .width(24.dp)
                            .fillMaxHeight(),
                    contentAlignment = Alignment.Center,
                ) {
                    Canvas(modifier = Modifier.width(20.dp).height(120.dp)) {
                        val ringCount = 3
                        val step = size.height / (ringCount + 1)
                        for (i in 1..ringCount) {
                            val y = step * i
                            // Metallic ring hoop
                            drawCircle(
                                color = Color(0xFF7C8288),
                                radius = 7.dp.toPx(),
                                center = Offset(size.width / 2, y),
                                style = Stroke(width = 2.5.dp.toPx()),
                            )
                            // Inner hole on paper
                            drawCircle(
                                color = Color(0xFF384756),
                                radius = 3.dp.toPx(),
                                center = Offset(size.width / 2, y),
                            )
                        }
                    }
                }

                // Right Page
                Column(
                    modifier =
                        Modifier
                            .weight(1f)
                            .padding(start = 14.dp, end = 12.dp),
                ) {
                    // Mood & Tag info
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        MoodBadge(mood = entry.mood, intensity = entry.moodIntensity)

                        if (onFavoriteToggle != null) {
                            IconButton(
                                onClick = onFavoriteToggle,
                                modifier = Modifier.size(24.dp),
                            ) {
                                Icon(
                                    imageVector = if (entry.isFavorite) Icons.Filled.Star else Icons.Outlined.StarBorder,
                                    contentDescription = null,
                                    tint = if (entry.isFavorite) VintageGold else Color(0xFF908A7E),
                                    modifier = Modifier.size(16.dp),
                                )
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(6.dp))

                    // Torn paper note on the right page
                    TornPaperNote(
                        title = entry.locationName ?: "JOURNAL NOTE",
                        content = entry.content.take(120),
                        hasBinderClip = true,
                        rotationDegrees = 1.5f,
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        // Bottom Editorial Reminder Banner
        Text(
            text = "reminder: progress matters more than perfection.",
            fontSize = 11.sp,
            fontFamily = FontFamily.Serif,
            color = Color(0xFFCCD6E0),
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth(),
        )
    }
}
