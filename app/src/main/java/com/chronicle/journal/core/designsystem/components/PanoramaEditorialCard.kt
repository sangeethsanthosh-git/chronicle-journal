package com.chronicle.journal.core.designsystem.components

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
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
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
import com.chronicle.journal.core.designsystem.theme.VintageGold
import com.chronicle.journal.domain.model.JournalWithDetails

/**
 * Panorama Editorial layout directly inspired by reference image 3:
 * - Scenery background with center floating modal card
 * - Triptych: 3 side-by-side vertical rounded photo cards
 * - Location chip, star ratings, and interactive action pills
 * - Embedded mini-calendar widget
 */
@Composable
fun PanoramaEditorialCard(
    details: JournalWithDetails,
    modifier: Modifier = Modifier,
    onFavoriteToggle: (() -> Unit)? = null,
    onClick: () -> Unit,
) {
    val entry = details.entry
    val photos = details.photoAttachments
    val context = LocalContext.current

    Box(
        modifier =
            modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(16.dp))
                .background(
                    Brush.verticalGradient(
                        listOf(Color(0xFF1B3224), Color(0xFF12231A)),
                    ),
                ).clickable { onClick() }
                .padding(14.dp),
    ) {
        Column(modifier = Modifier.fillMaxWidth()) {
            // Top Row: Title, Heart Doodle & Mini Calendar
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Top,
            ) {
                Column(modifier = Modifier.weight(1f).padding(end = 8.dp)) {
                    Text(
                        text = entry.title.uppercase(),
                        fontSize = 17.sp,
                        fontFamily = FontFamily.Serif,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp,
                        color = Color(0xFFEFF5F0),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )

                    if (entry.locationName != null) {
                        Spacer(modifier = Modifier.height(4.dp))
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                imageVector = Icons.Default.LocationOn,
                                contentDescription = null,
                                tint = Color(0xFF8AB69B),
                                modifier = Modifier.size(13.dp),
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = entry.locationName,
                                fontSize = 10.sp,
                                fontFamily = FontFamily.Monospace,
                                color = Color(0xFF8AB69B),
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis,
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(6.dp))

                    // Decorative doodle heart and handwritten snippet
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        HeartDoodle(color = Color(0xFFC5E0CE), sizeDp = 22)
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = "A sanctuary of quiet thoughts",
                            fontSize = 11.sp,
                            fontFamily = FontFamily.Cursive,
                            color = Color(0xFFBFD8C7),
                        )
                    }
                }

                // Mini Calendar Widget
                MiniCalendarWidget(
                    entryDateMillis = entry.entryDate,
                    modifier = Modifier.width(105.dp),
                    bannerText = if (entry.isFavorite) "FAVORITE" else null,
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Center: 3 Triptych Photo Cards
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                val photoUris = photos.map { it.uri }.take(3)
                for (i in 0 until 3) {
                    val uri = photoUris.getOrNull(i) ?: details.primaryImageUri
                    Box(
                        modifier =
                            Modifier
                                .weight(1f)
                                .aspectRatio(0.72f)
                                .clip(RoundedCornerShape(12.dp))
                                .background(Color(0xFF263C2E))
                                .border(1.dp, Color.White.copy(alpha = 0.2f), RoundedCornerShape(12.dp)),
                    ) {
                        if (uri != null) {
                            AsyncImage(
                                model =
                                    ImageRequest
                                        .Builder(context)
                                        .data(uri)
                                        .crossfade(true)
                                        .build(),
                                contentDescription = null,
                                contentScale = ContentScale.Crop,
                                modifier = Modifier.fillMaxWidth(),
                            )
                        } else {
                            // Artistic placeholder frame
                            Box(
                                modifier =
                                    Modifier
                                        .fillMaxWidth()
                                        .padding(8.dp),
                                contentAlignment = Alignment.Center,
                            ) {
                                Text(
                                    text = if (i == 1) entry.mood.displayName else "✦",
                                    fontSize = 11.sp,
                                    fontFamily = FontFamily.Monospace,
                                    color = Color(0xFFA5C4AF),
                                )
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Content snippet
            Text(
                text = entry.content,
                fontSize = 12.sp,
                fontFamily = FontFamily.Serif,
                color = Color(0xFFD6E2D8),
                lineHeight = 17.sp,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
            )

            Spacer(modifier = Modifier.height(10.dp))

            // Bottom Action Pills & Star Rating
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                // Star Rating
                Row(verticalAlignment = Alignment.CenterVertically) {
                    repeat(entry.moodIntensity) {
                        Icon(
                            imageVector = Icons.Filled.Star,
                            contentDescription = null,
                            tint = VintageGold,
                            modifier = Modifier.size(13.dp),
                        )
                    }
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "(${entry.moodIntensity}.0)",
                        fontSize = 10.sp,
                        fontFamily = FontFamily.Monospace,
                        color = Color(0xFF9CB8A4),
                    )
                }

                // Action Pills (Route, Save, Favorite)
                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    if (onFavoriteToggle != null) {
                        Box(
                            modifier =
                                Modifier
                                    .clip(RoundedCornerShape(14.dp))
                                    .background(if (entry.isFavorite) VintageGold else Color.White.copy(alpha = 0.15f))
                                    .clickable { onFavoriteToggle() }
                                    .padding(horizontal = 8.dp, vertical = 4.dp),
                        ) {
                            Text(
                                text = if (entry.isFavorite) "★ SAVED" else "☆ SAVE",
                                fontSize = 9.sp,
                                fontFamily = FontFamily.Monospace,
                                fontWeight = FontWeight.Bold,
                                color = if (entry.isFavorite) Color(0xFF2C2216) else Color.White,
                            )
                        }
                    }

                    Box(
                        modifier =
                            Modifier
                                .clip(RoundedCornerShape(14.dp))
                                .background(Color(0xFF4A8B6F))
                                .padding(horizontal = 8.dp, vertical = 4.dp),
                    ) {
                        Text(
                            text = "EXPLORE",
                            fontSize = 9.sp,
                            fontFamily = FontFamily.Monospace,
                            fontWeight = FontWeight.Bold,
                            color = Color.White,
                        )
                    }
                }
            }
        }
    }
}
