package com.chronicle.journal.core.designsystem.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Editorial sticker labels inspired by modern nostalgic scrapbook archives.
 * Examples: "You are not alone.", "reminder: progress matters more than perfection."
 */
@Composable
fun StickerBadge(
    text: String,
    modifier: Modifier = Modifier,
    backgroundColor: Color = Color(0xFF2962FF),
    textColor: Color = Color.White,
    rotationDegrees: Float = 0f,
    subtitle: String? = null,
) {
    Box(
        modifier =
            modifier
                .rotate(rotationDegrees)
                .shadow(3.dp, RoundedCornerShape(2.dp))
                .background(backgroundColor, RoundedCornerShape(2.dp))
                .padding(horizontal = 8.dp, vertical = 4.dp),
    ) {
        Column {
            if (subtitle != null) {
                Text(
                    text = subtitle,
                    fontSize = 9.sp,
                    fontFamily = FontFamily.Serif,
                    color = textColor.copy(alpha = 0.85f),
                )
            }
            Text(
                text = text,
                fontSize = 11.sp,
                fontFamily = FontFamily.Monospace,
                fontWeight = FontWeight.Bold,
                letterSpacing = 0.5.sp,
                color = textColor,
            )
        }
    }
}

/**
 * Hand-drawn decorative doodle heart with sparkle stars, inspired by reference image 3.
 */
@Composable
fun HeartDoodle(
    modifier: Modifier = Modifier,
    color: Color = Color.White,
    sizeDp: Int = 36,
) {
    Canvas(modifier = modifier.size(sizeDp.dp)) {
        val w = size.width
        val h = size.height

        val heartPath =
            Path().apply {
                moveTo(w * 0.5f, h * 0.8f)
                cubicTo(w * 0.1f, h * 0.55f, 0f, h * 0.25f, w * 0.25f, h * 0.15f)
                cubicTo(w * 0.45f, h * 0.08f, w * 0.5f, h * 0.35f, w * 0.5f, h * 0.35f)
                cubicTo(w * 0.5f, h * 0.35f, w * 0.55f, h * 0.08f, w * 0.75f, h * 0.15f)
                cubicTo(w * 1.0f, h * 0.25f, w * 0.9f, h * 0.55f, w * 0.5f, h * 0.8f)
                close()
            }

        drawPath(
            path = heartPath,
            color = color,
            style = Stroke(width = 2.dp.toPx()),
        )

        // Small twinkle star next to heart
        val starCenter = Offset(w * 0.85f, h * 0.15f)
        val starRadius = 4.dp.toPx()
        drawLine(color, Offset(starCenter.x - starRadius, starCenter.y), Offset(starCenter.x + starRadius, starCenter.y), strokeWidth = 1.5.dp.toPx())
        drawLine(color, Offset(starCenter.x, starCenter.y - starRadius), Offset(starCenter.x, starCenter.y + starRadius), strokeWidth = 1.5.dp.toPx())
    }
}
