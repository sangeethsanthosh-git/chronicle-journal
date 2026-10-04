package com.chronicle.journal.core.designsystem.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.chronicle.journal.core.common.TimeUtils
import com.chronicle.journal.core.designsystem.theme.PostalStampBlue
import com.chronicle.journal.core.designsystem.theme.PostmarkRed

@Composable
fun PostmarkStamp(
    dateMillis: Long,
    modifier: Modifier = Modifier,
    rotation: Float = -6f,
    color: Color = PostmarkRed.copy(alpha = 0.85f),
) {
    val dateText = TimeUtils.formatPostmarkDate(dateMillis)

    Row(
        modifier =
            modifier
                .rotate(rotation)
                .padding(4.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(4.dp),
    ) {
        // Circular Postmark
        Box(
            modifier =
                Modifier
                    .size(56.dp)
                    .border(1.5.dp, color, CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center,
            ) {
                Text(
                    text = "CHRONICLE",
                    fontSize = 7.sp,
                    fontWeight = FontWeight.Bold,
                    fontFamily = FontFamily.Monospace,
                    color = color,
                    letterSpacing = 1.sp,
                )
                Text(
                    text = dateText,
                    fontSize = 8.sp,
                    fontWeight = FontWeight.Bold,
                    fontFamily = FontFamily.Monospace,
                    color = color,
                )
                Text(
                    text = "★ ARCHIVE ★",
                    fontSize = 6.sp,
                    fontFamily = FontFamily.Monospace,
                    color = color,
                )
            }
        }

        // Wavy cancellation lines
        Canvas(modifier = Modifier.size(width = 36.dp, height = 40.dp)) {
            val strokeWidth = 1.5.dp.toPx()
            val waveHeight = 8.dp.toPx()
            for (i in 0..2) {
                val y = (i * 12 + 8).dp.toPx()
                val path =
                    Path().apply {
                        moveTo(0f, y)
                        quadraticTo(size.width * 0.25f, y - waveHeight / 2, size.width * 0.5f, y)
                        quadraticTo(size.width * 0.75f, y + waveHeight / 2, size.width, y)
                    }
                drawPath(path, color = color, style = Stroke(width = strokeWidth))
            }
        }
    }
}

@Composable
fun PostageStamp(
    emoji: String = "✉️",
    modifier: Modifier = Modifier,
    color: Color = PostalStampBlue,
) {
    Box(
        modifier =
            modifier
                .size(width = 46.dp, height = 54.dp)
                .border(1.dp, color.copy(alpha = 0.7f), RoundedCornerShape(2.dp))
                .padding(3.dp),
        contentAlignment = Alignment.Center,
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween,
            modifier = Modifier.padding(2.dp),
        ) {
            Text(
                text = "AIR MAIL",
                fontSize = 6.sp,
                fontFamily = FontFamily.Monospace,
                fontWeight = FontWeight.Bold,
                color = color,
            )
            Text(text = emoji, fontSize = 20.sp)
            Text(
                text = "1926",
                fontSize = 7.sp,
                fontFamily = FontFamily.Monospace,
                fontWeight = FontWeight.Bold,
                color = color,
            )
        }
    }
}
