package com.chronicle.journal.presentation.onboarding

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.chronicle.journal.core.designsystem.components.WashiTape
import com.chronicle.journal.core.designsystem.theme.HandwrittenCaptionStyle
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.core.designsystem.theme.PaperBackground
import com.chronicle.journal.core.designsystem.theme.WashiTapeKraft
import com.chronicle.journal.core.designsystem.theme.WashiTapeSage

data class OnboardingPage(
    val emoji: String,
    val title: String,
    val subtitle: String,
    val quote: String,
)

@Composable
fun OnboardingScreen(
    onFinished: () -> Unit,
    viewModel: OnboardingViewModel = hiltViewModel(),
) {
    val colors = LocalChronicleColors.current

    val pages =
        listOf(
            OnboardingPage(
                emoji = "📖",
                title = "A Tangible Personal Archive",
                subtitle = "Experience the tactile romance of physical journals, postcards, and scrapbooks in a modern digital form.",
                quote = "“Fill your paper with the breathings of your heart.”",
            ),
            OnboardingPage(
                emoji = "📷",
                title = "Moments, Polaroids & Memos",
                subtitle = "Combine handwritten reflections, instant photographic prints, audio recordings, weather, and mood stamps.",
                quote = "“We take photos as a return ticket to a moment otherwise gone.”",
            ),
            OnboardingPage(
                emoji = "🔐",
                title = "100% Offline & Private",
                subtitle = "No tracking, no subscriptions, no accounts. Your memoirs are preserved securely on your device alone.",
                quote = "“Your thoughts belong entirely to you.”",
            ),
        )

    var currentPage by remember { mutableIntStateOf(0) }

    PaperBackground {
        Column(
            modifier =
                Modifier
                    .fillMaxSize()
                    .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween,
        ) {
            // Top Bar
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.End,
            ) {
                TextButton(onClick = { viewModel.completeOnboarding(onFinished) }) {
                    Text(
                        text = "SKIP",
                        fontFamily = FontFamily.Monospace,
                        fontSize = 12.sp,
                        color = colors.inkMuted,
                    )
                }
            }

            // Main Card
            val page = pages[currentPage]
            Box(
                modifier =
                    Modifier
                        .fillMaxWidth()
                        .shadow(4.dp, RoundedCornerShape(8.dp))
                        .background(colors.paperCard, RoundedCornerShape(8.dp))
                        .border(1.dp, colors.paperCardBorder, RoundedCornerShape(8.dp))
                        .padding(24.dp),
            ) {
                WashiTape(
                    modifier =
                        Modifier
                            .align(Alignment.TopEnd)
                            .padding(top = (-32).dp, end = 12.dp),
                    rotation = 6f,
                    color = if (currentPage % 2 == 0) WashiTapeSage else WashiTapeKraft,
                )

                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Text(text = page.emoji, fontSize = 54.sp)
                    Spacer(modifier = Modifier.height(16.dp))
                    Text(
                        text = page.title,
                        fontFamily = FontFamily.Serif,
                        fontWeight = FontWeight.Bold,
                        fontSize = 22.sp,
                        color = colors.inkPrimary,
                        textAlign = TextAlign.Center,
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = page.subtitle,
                        fontSize = 14.sp,
                        fontFamily = FontFamily.Serif,
                        color = colors.inkSecondary,
                        textAlign = TextAlign.Center,
                        lineHeight = 22.sp,
                    )
                    Spacer(modifier = Modifier.height(16.dp))
                    Text(
                        text = page.quote,
                        style = HandwrittenCaptionStyle,
                        fontSize = 16.sp,
                        color = colors.inkMuted,
                        textAlign = TextAlign.Center,
                    )
                }
            }

            // Bottom Navigation and Controls
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.fillMaxWidth(),
            ) {
                // Page Indicator Dots
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    for (i in pages.indices) {
                        val isCurrent = i == currentPage
                        Box(
                            modifier =
                                Modifier
                                    .size(if (isCurrent) 10.dp else 8.dp)
                                    .background(
                                        if (isCurrent) colors.inkPrimary else colors.ruledLine,
                                        CircleShape,
                                    ),
                        )
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))

                // Action Button
                Button(
                    onClick = {
                        if (currentPage < pages.lastIndex) {
                            currentPage++
                        } else {
                            viewModel.completeOnboarding(onFinished)
                        }
                    },
                    modifier =
                        Modifier
                            .fillMaxWidth()
                            .height(50.dp),
                    colors =
                        ButtonDefaults.buttonColors(
                            containerColor = colors.inkPrimary,
                            contentColor = colors.paperCard,
                        ),
                    shape = RoundedCornerShape(25.dp),
                ) {
                    Text(
                        text = if (currentPage == pages.lastIndex) "Begin Your Chronicle" else "Continue",
                        fontFamily = FontFamily.Serif,
                        fontWeight = FontWeight.Bold,
                        fontSize = 16.sp,
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))
            }
        }
    }
}
