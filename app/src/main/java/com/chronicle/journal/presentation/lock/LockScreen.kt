package com.chronicle.journal.presentation.lock

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Backspace
import androidx.compose.material.icons.filled.Fingerprint
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.chronicle.journal.core.designsystem.theme.HandwrittenCaptionStyle
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.core.designsystem.theme.PaperBackground
import com.chronicle.journal.core.designsystem.theme.PostmarkRed

@Composable
fun LockScreen(
    onUnlockSuccess: () -> Unit,
    viewModel: LockViewModel = hiltViewModel(),
) {
    val state by viewModel.uiState.collectAsState()
    val colors = LocalChronicleColors.current

    LaunchedEffect(Unit) {
        viewModel.unlockSuccessEvent.collect {
            onUnlockSuccess()
        }
    }

    PaperBackground {
        Column(
            modifier =
                Modifier
                    .fillMaxSize()
                    .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            Text(text = "🔒", fontSize = 36.sp)
            Spacer(modifier = Modifier.height(12.dp))
            Text(
                text = "Chronicle Locked",
                fontFamily = FontFamily.Serif,
                fontWeight = FontWeight.Bold,
                fontSize = 24.sp,
                color = colors.inkPrimary,
            )
            Spacer(modifier = Modifier.height(6.dp))
            Text(
                text = "Enter your passcode to open your private journal",
                style = HandwrittenCaptionStyle,
                fontSize = 15.sp,
                color = colors.inkSecondary,
            )

            Spacer(modifier = Modifier.height(28.dp))

            // Pin Digits Indicators (dots)
            Row(horizontalArrangement = Arrangement.spacedBy(14.dp)) {
                for (i in 0 until 4) {
                    val isFilled = i < state.enteredPin.length
                    Box(
                        modifier =
                            Modifier
                                .size(16.dp)
                                .border(1.5.dp, colors.inkPrimary, CircleShape)
                                .background(
                                    if (isFilled) colors.inkPrimary else colors.paperCard,
                                    CircleShape,
                                ),
                    )
                }
            }

            if (state.errorMessage != null) {
                Spacer(modifier = Modifier.height(14.dp))
                Text(
                    text = state.errorMessage!!,
                    fontFamily = FontFamily.Monospace,
                    fontSize = 12.sp,
                    color = PostmarkRed,
                )
            }

            Spacer(modifier = Modifier.height(36.dp))

            // Keypad (1..9, 0, Backspace)
            val keypadRows =
                listOf(
                    listOf('1', '2', '3'),
                    listOf('4', '5', '6'),
                    listOf('7', '8', '9'),
                )

            keypadRows.forEach { row ->
                Row(
                    horizontalArrangement = Arrangement.spacedBy(28.dp),
                    modifier = Modifier.padding(vertical = 8.dp),
                ) {
                    row.forEach { digit ->
                        KeypadButton(text = "$digit", onClick = { viewModel.onDigitPressed(digit) })
                    }
                }
            }

            // Bottom Row: Biometric, 0, Backspace
            Row(
                horizontalArrangement = Arrangement.spacedBy(28.dp),
                modifier = Modifier.padding(vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                // Biometric shortcut
                Box(
                    modifier =
                        Modifier
                            .size(64.dp)
                            .clickable { viewModel.onBiometricSuccess() },
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(
                        imageVector = Icons.Default.Fingerprint,
                        contentDescription = "Biometric unlock",
                        tint = colors.inkSecondary,
                        modifier = Modifier.size(28.dp),
                    )
                }

                KeypadButton(text = "0", onClick = { viewModel.onDigitPressed('0') })

                // Backspace
                Box(
                    modifier =
                        Modifier
                            .size(64.dp)
                            .clickable { viewModel.onBackspace() },
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.Backspace,
                        contentDescription = "Backspace",
                        tint = colors.inkSecondary,
                        modifier = Modifier.size(24.dp),
                    )
                }
            }
        }
    }
}

@Composable
fun KeypadButton(
    text: String,
    onClick: () -> Unit,
) {
    val colors = LocalChronicleColors.current

    Box(
        modifier =
            Modifier
                .size(64.dp)
                .border(1.dp, colors.paperCardBorder, CircleShape)
                .background(colors.paperCard, CircleShape)
                .clickable { onClick() },
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = text,
            fontFamily = FontFamily.Serif,
            fontWeight = FontWeight.Bold,
            fontSize = 22.sp,
            color = colors.inkPrimary,
        )
    }
}
