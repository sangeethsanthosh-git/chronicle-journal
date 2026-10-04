package com.chronicle.journal.core.designsystem.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.domain.model.Mood

@Composable
fun MoodBadge(
    mood: Mood,
    intensity: Int = 3,
    modifier: Modifier = Modifier,
    showLabel: Boolean = true,
    isSelected: Boolean = false,
    onClick: (() -> Unit)? = null,
) {
    val colors = LocalChronicleColors.current
    val moodColor =
        try {
            Color(android.graphics.Color.parseColor(if (colors.isDark) mood.darkColorHex else mood.lightColorHex))
        } catch (e: Exception) {
            colors.inkSecondary
        }

    val backgroundColor = if (isSelected) moodColor.copy(alpha = 0.25f) else colors.paperSurface
    val borderColor = if (isSelected) moodColor else colors.paperCardBorder

    Row(
        modifier =
            modifier
                .then(
                    if (onClick != null) Modifier.clickable { onClick() } else Modifier,
                ).border(1.dp, borderColor, RoundedCornerShape(16.dp))
                .background(backgroundColor, RoundedCornerShape(16.dp))
                .padding(horizontal = 8.dp, vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(4.dp),
    ) {
        Text(text = mood.emoji, fontSize = 14.sp)
        if (showLabel) {
            Text(
                text = mood.displayName,
                fontSize = 12.sp,
                fontWeight = FontWeight.Medium,
                color = colors.inkPrimary,
            )
        }
        if (intensity in 1..5) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(2.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                for (i in 1..5) {
                    val dotColor = if (i <= intensity) moodColor else colors.ruledLine
                    Box(
                        modifier =
                            Modifier
                                .size(3.dp)
                                .background(dotColor, CircleShape),
                    )
                }
            }
        }
    }
}
