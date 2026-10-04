package com.chronicle.journal.core.designsystem.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.chronicle.journal.core.common.TimeUtils
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors

@Composable
fun AudioPlayerBar(
    isPlaying: Boolean,
    currentPositionMs: Long,
    totalDurationMs: Long,
    onPlayPauseClick: () -> Unit,
    modifier: Modifier = Modifier,
    onDeleteClick: (() -> Unit)? = null,
) {
    val colors = LocalChronicleColors.current
    val progress =
        if (totalDurationMs > 0) {
            (currentPositionMs.toFloat() / totalDurationMs.toFloat()).coerceIn(0f, 1f)
        } else {
            0f
        }

    Box(
        modifier =
            modifier
                .fillMaxWidth()
                .border(1.dp, colors.paperCardBorder, RoundedCornerShape(8.dp))
                .background(colors.paperSurface, RoundedCornerShape(8.dp))
                .padding(10.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            // Play / Pause round button
            IconButton(
                onClick = onPlayPauseClick,
                modifier =
                    Modifier
                        .size(38.dp)
                        .background(colors.inkPrimary, CircleShape),
            ) {
                Icon(
                    imageVector = if (isPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                    contentDescription = if (isPlaying) "Pause" else "Play",
                    tint = colors.paperCard,
                    modifier = Modifier.size(20.dp),
                )
            }

            // Cassette tape styling & progress
            Column(modifier = Modifier.weight(1f)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                ) {
                    Text(
                        text = "VOICE MEMO",
                        fontSize = 10.sp,
                        fontFamily = FontFamily.Monospace,
                        color = colors.inkSecondary,
                    )
                    Text(
                        text = "${TimeUtils.formatDuration(currentPositionMs)} / ${TimeUtils.formatDuration(totalDurationMs)}",
                        fontSize = 10.sp,
                        fontFamily = FontFamily.Monospace,
                        color = colors.inkMuted,
                    )
                }

                Spacer(modifier = Modifier.height(6.dp))

                LinearProgressIndicator(
                    progress = { progress },
                    modifier =
                        Modifier
                            .fillMaxWidth()
                            .height(4.dp)
                            .clip(RoundedCornerShape(2.dp)),
                    color = colors.inkPrimary,
                    trackColor = colors.ruledLine,
                )
            }

            if (onDeleteClick != null) {
                IconButton(onClick = onDeleteClick, modifier = Modifier.size(32.dp)) {
                    Icon(
                        imageVector = Icons.Default.Delete,
                        contentDescription = "Delete audio",
                        tint = colors.inkMuted,
                        modifier = Modifier.size(18.dp),
                    )
                }
            }
        }
    }
}
