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
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.chronicle.journal.core.common.TimeUtils
import com.chronicle.journal.core.designsystem.theme.VintageGold
import java.time.YearMonth

/**
 * An inline mini calendar widget that renders an authentic month grid
 * with the journal entry's date highlighted, inspired by editorial travel journals.
 */
@Composable
fun MiniCalendarWidget(
    entryDateMillis: Long,
    modifier: Modifier = Modifier,
    bannerText: String? = null,
    backgroundColor: Color = Color(0xFF2A4234).copy(alpha = 0.85f),
    textColor: Color = Color(0xFFE8ECE9),
) {
    val date = TimeUtils.toLocalDate(entryDateMillis)
    val yearMonth = YearMonth.of(date.year, date.month)
    val firstDayOfWeek = yearMonth.atDay(1).dayOfWeek.value % 7 // 0 = Sunday
    val daysInMonth = yearMonth.lengthOfMonth()

    Column(
        modifier =
            modifier
                .clip(RoundedCornerShape(8.dp))
                .background(backgroundColor)
                .border(1.dp, Color.White.copy(alpha = 0.15f), RoundedCornerShape(8.dp))
                .padding(10.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        // Month Title (e.g. "JUNE")
        Text(
            text = date.month.name.uppercase(),
            fontSize = 11.sp,
            fontFamily = FontFamily.Monospace,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.5.sp,
            color = textColor,
        )

        Spacer(modifier = Modifier.height(6.dp))

        // Weekday Headers
        val dayHeaders = listOf("S", "M", "T", "W", "T", "F", "S")
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            dayHeaders.forEach { header ->
                Text(
                    text = header,
                    fontSize = 8.sp,
                    fontFamily = FontFamily.Monospace,
                    fontWeight = FontWeight.Medium,
                    color = textColor.copy(alpha = 0.6f),
                    textAlign = TextAlign.Center,
                    modifier = Modifier.size(16.dp),
                )
            }
        }

        Spacer(modifier = Modifier.height(4.dp))

        // Days Grid (up to 5 weeks)
        var currentDay = 1
        for (row in 0 until 5) {
            if (currentDay > daysInMonth) break
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
            ) {
                for (col in 0 until 7) {
                    val dayNum =
                        if (row == 0 && col < firstDayOfWeek) {
                            null
                        } else if (currentDay <= daysInMonth) {
                            currentDay++
                        } else {
                            null
                        }

                    if (dayNum != null) {
                        val isEntryDay = dayNum == date.dayOfMonth
                        Box(
                            modifier =
                                Modifier
                                    .size(16.dp)
                                    .clip(CircleShape)
                                    .background(if (isEntryDay) VintageGold else Color.Transparent),
                            contentAlignment = Alignment.Center,
                        ) {
                            Text(
                                text = dayNum.toString(),
                                fontSize = 8.sp,
                                fontFamily = FontFamily.Monospace,
                                fontWeight = if (isEntryDay) FontWeight.Bold else FontWeight.Normal,
                                color = if (isEntryDay) Color(0xFF2C2216) else textColor,
                            )
                        }
                    } else {
                        Box(modifier = Modifier.size(16.dp))
                    }
                }
            }
            Spacer(modifier = Modifier.height(2.dp))
        }

        if (bannerText != null) {
            Spacer(modifier = Modifier.height(8.dp))
            Box(
                modifier =
                    Modifier
                        .clip(RoundedCornerShape(3.dp))
                        .background(Color.White.copy(alpha = 0.2f))
                        .padding(horizontal = 6.dp, vertical = 2.dp),
            ) {
                Text(
                    text = bannerText.uppercase(),
                    fontSize = 8.sp,
                    fontFamily = FontFamily.Monospace,
                    fontWeight = FontWeight.Bold,
                    color = textColor,
                    letterSpacing = 0.5.sp,
                )
            }
        }
    }
}
