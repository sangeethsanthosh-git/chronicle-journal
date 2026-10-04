package com.chronicle.journal.core.designsystem.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors

/**
 * A torn paper snippet note with jagged ragged edges and an optional binder clip or tape,
 * inspired by physical scrapbooks and bullet journals.
 */
@Composable
fun TornPaperNote(
    title: String,
    content: String,
    modifier: Modifier = Modifier,
    items: List<String> = emptyList(),
    rotationDegrees: Float = 0f,
    hasBinderClip: Boolean = true,
) {
    val colors = LocalChronicleColors.current

    Box(
        modifier =
            modifier
                .rotate(rotationDegrees)
                .shadow(4.dp, RoundedCornerShape(2.dp))
                .background(Color(0xFFF9F7F1), RoundedCornerShape(2.dp))
                .padding(horizontal = 14.dp, vertical = 12.dp),
    ) {
        // Jagged ragged edge lines on top and bottom
        Canvas(modifier = Modifier.fillMaxWidth().height(4.dp)) {
            val step = 10f
            val path =
                Path().apply {
                    moveTo(0f, 0f)
                    var x = 0f
                    var up = true
                    while (x < size.width) {
                        x += step
                        lineTo(x, if (up) 4f else 0f)
                        up = !up
                    }
                }
            drawPath(path, color = Color(0xFFD6CEBF), style = Stroke(width = 1.5f))
        }

        Column(modifier = Modifier.padding(top = 6.dp)) {
            if (hasBinderClip) {
                // Drawn binder clip icon
                Box(
                    modifier =
                        Modifier
                            .size(width = 24.dp, height = 8.dp)
                            .background(Color(0xFF5A5A5A), RoundedCornerShape(2.dp))
                            .align(Alignment.CenterHorizontally),
                )
                Spacer(modifier = Modifier.height(6.dp))
            }

            if (title.isNotBlank()) {
                Text(
                    text = title.uppercase(),
                    fontSize = 11.sp,
                    fontFamily = FontFamily.Monospace,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp,
                    color = Color(0xFF3E3A37),
                )
                Spacer(modifier = Modifier.height(4.dp))
            }

            if (content.isNotBlank()) {
                Text(
                    text = content,
                    fontSize = 13.sp,
                    fontFamily = FontFamily.Cursive,
                    lineHeight = 18.sp,
                    color = Color(0xFF2C2A29),
                )
            }

            if (items.isNotEmpty()) {
                Spacer(modifier = Modifier.height(4.dp))
                items.forEach { item ->
                    Text(
                        text = "› $item",
                        fontSize = 12.sp,
                        fontFamily = FontFamily.Monospace,
                        color = Color(0xFF55524E),
                        modifier = Modifier.padding(vertical = 1.dp),
                    )
                }
            }
        }
    }
}
