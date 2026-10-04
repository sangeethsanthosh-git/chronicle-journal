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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.chronicle.journal.core.designsystem.theme.HandwrittenCaptionStyle
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.domain.model.Mood

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun MoodSelector(
    selectedMood: Mood,
    intensity: Int,
    onMoodSelected: (Mood) -> Unit,
    onIntensityChanged: (Int) -> Unit,
    modifier: Modifier = Modifier,
) {
    val colors = LocalChronicleColors.current

    Column(
        modifier =
            modifier
                .fillMaxWidth()
                .border(1.dp, colors.paperCardBorder, RoundedCornerShape(8.dp))
                .background(colors.paperCard, RoundedCornerShape(8.dp))
                .padding(14.dp),
    ) {
        Text(
            text = "HOW ARE YOU FEELING?",
            fontFamily = FontFamily.Monospace,
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold,
            color = colors.inkSecondary,
            letterSpacing = 1.sp,
        )

        Spacer(modifier = Modifier.height(10.dp))

        // Grid of Moods
        FlowRow(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp),
        ) {
            Mood.entries.forEach { mood ->
                MoodBadge(
                    mood = mood,
                    intensity = if (mood == selectedMood) intensity else 0,
                    isSelected = (mood == selectedMood),
                    onClick = { onMoodSelected(mood) },
                )
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        // Intensity Selector (1 to 5)
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = "Intensity: $intensity/5",
                fontSize = 12.sp,
                fontFamily = FontFamily.Monospace,
                color = colors.inkSecondary,
            )

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                for (i in 1..5) {
                    val isCurrent = i <= intensity
                    Box(
                        modifier =
                            Modifier
                                .size(24.dp)
                                .border(
                                    1.dp,
                                    if (isCurrent) colors.inkPrimary else colors.paperCardBorder,
                                    CircleShape,
                                ).background(
                                    if (isCurrent) colors.inkPrimary else Color.Transparent,
                                    CircleShape,
                                ).clickable { onIntensityChanged(i) },
                        contentAlignment = Alignment.Center,
                    ) {
                        Text(
                            text = "$i",
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            color = if (isCurrent) colors.paperCard else colors.inkMuted,
                        )
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        // Reflective prompt for chosen mood
        Box(
            modifier =
                Modifier
                    .fillMaxWidth()
                    .background(colors.paperSurface, RoundedCornerShape(6.dp))
                    .padding(10.dp),
        ) {
            Text(
                text = "Prompt: ${selectedMood.prompt}",
                style = HandwrittenCaptionStyle,
                fontSize = 14.sp,
                color = colors.inkSecondary,
            )
        }
    }
}
