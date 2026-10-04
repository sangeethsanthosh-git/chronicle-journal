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
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.domain.model.Tag

@Composable
fun TagChip(
    tag: Tag,
    modifier: Modifier = Modifier,
    isSelected: Boolean = false,
    onClick: (() -> Unit)? = null,
) {
    val colors = LocalChronicleColors.current
    val tagColor =
        try {
            Color(android.graphics.Color.parseColor(tag.colorHex))
        } catch (e: Exception) {
            colors.inkSecondary
        }

    val backgroundColor = if (isSelected) tagColor.copy(alpha = 0.2f) else colors.paperSurface
    val borderColor = if (isSelected) tagColor else colors.paperCardBorder

    Row(
        modifier =
            modifier
                .then(if (onClick != null) Modifier.clickable { onClick() } else Modifier)
                .border(1.dp, borderColor, RoundedCornerShape(12.dp))
                .background(backgroundColor, RoundedCornerShape(12.dp))
                .padding(horizontal = 8.dp, vertical = 3.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(5.dp),
    ) {
        Box(
            modifier =
                Modifier
                    .size(6.dp)
                    .background(tagColor, CircleShape),
        )
        Text(
            text = "#${tag.name}",
            fontSize = 11.sp,
            color = colors.inkPrimary,
        )
    }
}
