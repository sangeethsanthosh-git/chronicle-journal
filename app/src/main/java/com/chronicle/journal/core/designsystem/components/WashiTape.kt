package com.chronicle.journal.core.designsystem.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.chronicle.journal.core.designsystem.theme.WashiTapeKraft

@Composable
fun WashiTape(
    modifier: Modifier = Modifier,
    width: Dp = 64.dp,
    height: Dp = 18.dp,
    rotation: Float = -3f,
    color: Color = WashiTapeKraft,
) {
    Box(
        modifier =
            modifier
                .rotate(rotation)
                .shadow(1.dp, shape = RoundedCornerShape(1.dp))
                .width(width)
                .height(height)
                .background(color, shape = RoundedCornerShape(1.dp)),
    )
}
