package com.chronicle.journal.core.designsystem.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.chronicle.journal.core.designsystem.theme.HandwrittenCaptionStyle
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.core.designsystem.theme.WashiTapeKraft

@Composable
fun PolaroidCard(
    imageUri: String,
    caption: String? = null,
    modifier: Modifier = Modifier,
    rotation: Float = 0f,
    showTape: Boolean = true,
    onClick: (() -> Unit)? = null,
) {
    val colors = LocalChronicleColors.current
    val context = LocalContext.current

    Box(
        modifier =
            modifier
                .rotate(rotation)
                .shadow(4.dp, RoundedCornerShape(2.dp))
                .background(colors.paperCard, RoundedCornerShape(2.dp))
                .border(1.dp, colors.paperCardBorder, RoundedCornerShape(2.dp))
                .then(if (onClick != null) Modifier.clickable { onClick() } else Modifier)
                .padding(10.dp),
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.fillMaxWidth(),
        ) {
            // Photo Area
            Box(
                modifier =
                    Modifier
                        .fillMaxWidth()
                        .aspectRatio(1f)
                        .background(Color(0xFF2C2825)),
            ) {
                AsyncImage(
                    model =
                        ImageRequest
                            .Builder(context)
                            .data(imageUri)
                            .crossfade(true)
                            .build(),
                    contentDescription = caption ?: "Journal photo",
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.fillMaxWidth().aspectRatio(1f),
                )
            }

            // Bottom margin with handwritten caption
            if (!caption.isNullOrBlank()) {
                Text(
                    text = caption,
                    style = HandwrittenCaptionStyle,
                    color = colors.inkPrimary,
                    fontSize = 15.sp,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(top = 10.dp, bottom = 4.dp, start = 4.dp, end = 4.dp),
                )
            } else {
                Box(modifier = Modifier.padding(vertical = 8.dp))
            }
        }

        if (showTape) {
            WashiTape(
                modifier =
                    Modifier
                        .align(Alignment.TopCenter)
                        .padding(top = (-14).dp),
                color = WashiTapeKraft,
            )
        }
    }
}
