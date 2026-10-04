package com.chronicle.journal.core.designsystem.theme

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.unit.dp
import com.chronicle.journal.domain.model.PaperStyle

@Composable
fun PaperBackground(
    modifier: Modifier = Modifier,
    paperStyle: PaperStyle = LocalPaperStyle.current,
    content: @Composable () -> Unit,
) {
    val colors = LocalChronicleColors.current

    Box(
        modifier =
            modifier
                .fillMaxSize()
                .background(colors.paperBackground),
    ) {
        when (paperStyle) {
            PaperStyle.PLAIN -> {
                // Clean subtle warm paper background
            }
            PaperStyle.RULED -> {
                Canvas(modifier = Modifier.fillMaxSize()) {
                    val lineSpacingPx = 32.dp.toPx()
                    var y = lineSpacingPx
                    while (y < size.height) {
                        drawLine(
                            color = colors.ruledLine,
                            start = Offset(0f, y),
                            end = Offset(size.width, y),
                            strokeWidth = 1.dp.toPx(),
                        )
                        y += lineSpacingPx
                    }
                }
            }
            PaperStyle.GRID -> {
                Canvas(modifier = Modifier.fillMaxSize()) {
                    val gridSpacingPx = 22.dp.toPx()
                    val dotRadiusPx = 1.dp.toPx()
                    var x = gridSpacingPx
                    while (x < size.width) {
                        var y = gridSpacingPx
                        while (y < size.height) {
                            drawCircle(
                                color = colors.gridDot,
                                radius = dotRadiusPx,
                                center = Offset(x, y),
                            )
                            y += gridSpacingPx
                        }
                        x += gridSpacingPx
                    }
                }
            }
            PaperStyle.VINTAGE_WARM -> {
                Canvas(modifier = Modifier.fillMaxSize()) {
                    // Subtle distressed paper edge vignette
                    drawRect(
                        color = colors.paperCardBorder.copy(alpha = 0.15f),
                        topLeft = Offset.Zero,
                        size = size,
                    )
                }
            }
        }
        content()
    }
}
