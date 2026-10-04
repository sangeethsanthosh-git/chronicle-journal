package com.chronicle.journal.presentation.insights

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
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.chronicle.journal.core.designsystem.components.TagChip
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.core.designsystem.theme.PaperBackground
import com.chronicle.journal.core.designsystem.theme.VintageGold

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun InsightsScreen(viewModel: InsightsViewModel = hiltViewModel()) {
    val state by viewModel.uiState.collectAsState()
    val colors = LocalChronicleColors.current
    val stats = state.statistics

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Journal Insights",
                        fontFamily = FontFamily.Serif,
                        fontWeight = FontWeight.Bold,
                        fontSize = 20.sp,
                        color = colors.inkPrimary,
                    )
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
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                ) {
                    // Streaks Card
                    item {
                        Box(
                            modifier =
                                Modifier
                                    .fillMaxWidth()
                                    .shadow(3.dp, RoundedCornerShape(8.dp))
                                    .background(colors.paperCard, RoundedCornerShape(8.dp))
                                    .border(1.dp, colors.paperCardBorder, RoundedCornerShape(8.dp))
                                    .padding(16.dp),
                        ) {
                            Column {
                                Text(
                                    text = "HABIT & MOMENTUM",
                                    fontSize = 11.sp,
                                    fontFamily = FontFamily.Monospace,
                                    fontWeight = FontWeight.Bold,
                                    color = colors.inkSecondary,
                                    letterSpacing = 1.sp,
                                )

                                Spacer(modifier = Modifier.height(14.dp))

                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceAround,
                                ) {
                                    MetricCounter(
                                        title = "Current Streak",
                                        value = "${stats.streakInfo.currentStreak}",
                                        unit = "days",
                                        icon = "🔥",
                                        accentColor = VintageGold,
                                    )
                                    MetricCounter(
                                        title = "Longest Streak",
                                        value = "${stats.streakInfo.longestStreak}",
                                        unit = "days",
                                        icon = "🏆",
                                        accentColor = colors.inkPrimary,
                                    )
                                    MetricCounter(
                                        title = "Active Days",
                                        value = "${stats.streakInfo.totalActiveDays}",
                                        unit = "days",
                                        icon = "📅",
                                        accentColor = colors.inkPrimary,
                                    )
                                }
                            }
                        }
                    }

                    // Key Numbers Card
                    item {
                        Box(
                            modifier =
                                Modifier
                                    .fillMaxWidth()
                                    .shadow(2.dp, RoundedCornerShape(8.dp))
                                    .background(colors.paperCard, RoundedCornerShape(8.dp))
                                    .border(1.dp, colors.paperCardBorder, RoundedCornerShape(8.dp))
                                    .padding(16.dp),
                        ) {
                            Column {
                                Text(
                                    text = "LIFETIME WRITING ARCHIVE",
                                    fontSize = 11.sp,
                                    fontFamily = FontFamily.Monospace,
                                    fontWeight = FontWeight.Bold,
                                    color = colors.inkSecondary,
                                    letterSpacing = 1.sp,
                                )

                                Spacer(modifier = Modifier.height(12.dp))

                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                ) {
                                    MetricItem(label = "Total Pages", value = "${stats.totalEntries}")
                                    MetricItem(label = "Words Written", value = "${stats.totalWordsWritten}")
                                    MetricItem(label = "Photos Kept", value = "${stats.totalPhotosCount}")
                                    MetricItem(label = "Voice Memos", value = "${stats.totalAudioCount}")
                                }
                            }
                        }
                    }

                    // Monthly Activity Bar Chart
                    item {
                        Box(
                            modifier =
                                Modifier
                                    .fillMaxWidth()
                                    .shadow(2.dp, RoundedCornerShape(8.dp))
                                    .background(colors.paperCard, RoundedCornerShape(8.dp))
                                    .border(1.dp, colors.paperCardBorder, RoundedCornerShape(8.dp))
                                    .padding(16.dp),
                        ) {
                            Column {
                                Text(
                                    text = "MONTHLY ACTIVITY",
                                    fontSize = 11.sp,
                                    fontFamily = FontFamily.Monospace,
                                    fontWeight = FontWeight.Bold,
                                    color = colors.inkSecondary,
                                    letterSpacing = 1.sp,
                                )

                                Spacer(modifier = Modifier.height(16.dp))

                                val maxVal =
                                    stats.monthlyActivity.values
                                        .maxOrNull()
                                        ?.coerceAtLeast(1) ?: 1

                                Row(
                                    modifier =
                                        Modifier
                                            .fillMaxWidth()
                                            .height(120.dp),
                                    horizontalArrangement = Arrangement.SpaceAround,
                                    verticalAlignment = Alignment.Bottom,
                                ) {
                                    stats.monthlyActivity.forEach { (month, count) ->
                                        val barHeightFraction = (count.toFloat() / maxVal.toFloat()).coerceIn(0.08f, 1f)

                                        Column(
                                            horizontalAlignment = Alignment.CenterHorizontally,
                                            modifier = Modifier.weight(1f),
                                        ) {
                                            Text(
                                                text = if (count > 0) "$count" else "",
                                                fontSize = 10.sp,
                                                fontFamily = FontFamily.Monospace,
                                                color = colors.inkMuted,
                                            )
                                            Spacer(modifier = Modifier.height(4.dp))
                                            Box(
                                                modifier =
                                                    Modifier
                                                        .width(18.dp)
                                                        .fillMaxHeight(barHeightFraction)
                                                        .clip(RoundedCornerShape(topStart = 4.dp, topEnd = 4.dp))
                                                        .background(
                                                            if (count > 0) colors.inkPrimary else colors.ruledLine,
                                                        ),
                                            )
                                            Spacer(modifier = Modifier.height(6.dp))
                                            Text(
                                                text = month,
                                                fontSize = 11.sp,
                                                fontFamily = FontFamily.Monospace,
                                                color = colors.inkSecondary,
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Mood Distribution Section
                    item {
                        Box(
                            modifier =
                                Modifier
                                    .fillMaxWidth()
                                    .shadow(2.dp, RoundedCornerShape(8.dp))
                                    .background(colors.paperCard, RoundedCornerShape(8.dp))
                                    .border(1.dp, colors.paperCardBorder, RoundedCornerShape(8.dp))
                                    .padding(16.dp),
                        ) {
                            Column {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically,
                                ) {
                                    Text(
                                        text = "MOOD SPECTRUM",
                                        fontSize = 11.sp,
                                        fontFamily = FontFamily.Monospace,
                                        fontWeight = FontWeight.Bold,
                                        color = colors.inkSecondary,
                                        letterSpacing = 1.sp,
                                    )
                                    stats.mostCommonMood?.let {
                                        Text(
                                            text = "Primary: ${it.emoji} ${it.displayName}",
                                            fontSize = 11.sp,
                                            fontFamily = FontFamily.Monospace,
                                            color = VintageGold,
                                        )
                                    }
                                }

                                Spacer(modifier = Modifier.height(14.dp))

                                if (stats.moodDistribution.isEmpty()) {
                                    Text(
                                        text = "No mood records logged yet.",
                                        fontSize = 12.sp,
                                        fontFamily = FontFamily.Serif,
                                        color = colors.inkMuted,
                                    )
                                } else {
                                    val totalMoodCount =
                                        stats.moodDistribution.values
                                            .sum()
                                            .coerceAtLeast(1)

                                    stats.moodDistribution.entries.sortedByDescending { it.value }.forEach { (mood, count) ->
                                        val fraction = count.toFloat() / totalMoodCount.toFloat()
                                        val percent = (fraction * 100).toInt()

                                        Column(modifier = Modifier.padding(vertical = 4.dp)) {
                                            Row(
                                                modifier = Modifier.fillMaxWidth(),
                                                horizontalArrangement = Arrangement.SpaceBetween,
                                            ) {
                                                Text(
                                                    text = "${mood.emoji} ${mood.displayName}",
                                                    fontSize = 12.sp,
                                                    color = colors.inkPrimary,
                                                )
                                                Text(
                                                    text = "$count ($percent%)",
                                                    fontSize = 11.sp,
                                                    fontFamily = FontFamily.Monospace,
                                                    color = colors.inkMuted,
                                                )
                                            }
                                            Spacer(modifier = Modifier.height(4.dp))
                                            LinearProgressIndicator(
                                                progress = { fraction },
                                                modifier =
                                                    Modifier
                                                        .fillMaxWidth()
                                                        .height(6.dp)
                                                        .clip(RoundedCornerShape(3.dp)),
                                                color =
                                                    Color(
                                                        android.graphics.Color.parseColor(
                                                            if (colors.isDark) mood.darkColorHex else mood.lightColorHex,
                                                        ),
                                                    ),
                                                trackColor = colors.paperSurface,
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Top Tags Section
                    if (stats.topTags.isNotEmpty()) {
                        item {
                            Box(
                                modifier =
                                    Modifier
                                        .fillMaxWidth()
                                        .shadow(2.dp, RoundedCornerShape(8.dp))
                                        .background(colors.paperCard, RoundedCornerShape(8.dp))
                                        .border(1.dp, colors.paperCardBorder, RoundedCornerShape(8.dp))
                                        .padding(16.dp),
                            ) {
                                Column {
                                    Text(
                                        text = "FREQUENT THEMES & TAGS",
                                        fontSize = 11.sp,
                                        fontFamily = FontFamily.Monospace,
                                        fontWeight = FontWeight.Bold,
                                        color = colors.inkSecondary,
                                        letterSpacing = 1.sp,
                                    )
                                    Spacer(modifier = Modifier.height(10.dp))
                                    FlowRow(
                                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                                        verticalArrangement = Arrangement.spacedBy(8.dp),
                                    ) {
                                        stats.topTags.forEach { (tag, count) ->
                                            Row(
                                                verticalAlignment = Alignment.CenterVertically,
                                                horizontalArrangement = Arrangement.spacedBy(4.dp),
                                            ) {
                                                TagChip(tag = tag)
                                                Text(
                                                    text = "×$count",
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
                    }

                    item {
                        Spacer(modifier = Modifier.height(60.dp))
                    }
                }
            }
        }
    }
}

@Composable
fun MetricCounter(
    title: String,
    value: String,
    unit: String,
    icon: String,
    accentColor: Color,
) {
    val colors = LocalChronicleColors.current

    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(text = icon, fontSize = 20.sp)
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = value,
            fontFamily = FontFamily.Serif,
            fontWeight = FontWeight.Bold,
            fontSize = 24.sp,
            color = accentColor,
        )
        Text(
            text = "$title ($unit)",
            fontFamily = FontFamily.Monospace,
            fontSize = 10.sp,
            color = colors.inkMuted,
        )
    }
}

@Composable
fun MetricItem(
    label: String,
    value: String,
) {
    val colors = LocalChronicleColors.current
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = value,
            fontFamily = FontFamily.Serif,
            fontWeight = FontWeight.Bold,
            fontSize = 18.sp,
            color = colors.inkPrimary,
        )
        Text(
            text = label,
            fontFamily = FontFamily.Monospace,
            fontSize = 10.sp,
            color = colors.inkMuted,
        )
    }
}
