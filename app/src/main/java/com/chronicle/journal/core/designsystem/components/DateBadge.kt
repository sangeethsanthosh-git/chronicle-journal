package com.chronicle.journal.core.designsystem.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
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
import com.chronicle.journal.core.common.TimeUtils
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.core.designsystem.theme.PostmarkRed

@Composable
fun DateBadge(
    dateMillis: Long,
    modifier: Modifier = Modifier,
) {
    val colors = LocalChronicleColors.current
    val day = TimeUtils.formatDayOfMonth(dateMillis)
    val dayOfWeek = TimeUtils.formatDayOfWeek(dateMillis)

    Column(
        modifier =
            modifier
                .width(44.dp)
                .border(1.dp, colors.paperCardBorder, RoundedCornerShape(4.dp))
                .background(colors.paperCard, RoundedCornerShape(4.dp)),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        // Red top header bar for day of week
        Text(
            text = dayOfWeek,
            fontSize = 9.sp,
            fontWeight = FontWeight.Bold,
            fontFamily = FontFamily.Monospace,
            color = Color.White,
            modifier =
                Modifier
                    .background(PostmarkRed, RoundedCornerShape(topStart = 3.dp, topEnd = 3.dp))
                    .padding(vertical = 2.dp)
                    .align(Alignment.CenterHorizontally),
        )
        // Day number
        Text(
            text = day,
            fontSize = 18.sp,
            fontWeight = FontWeight.Bold,
            fontFamily = FontFamily.Serif,
            color = colors.inkPrimary,
            modifier = Modifier.padding(vertical = 2.dp),
        )
    }
}
