package com.chronicle.journal.presentation.settings

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.chronicle.journal.core.designsystem.theme.HandwrittenCaptionStyle
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.core.designsystem.theme.PaperBackground
import com.chronicle.journal.data.preferences.AppTheme
import com.chronicle.journal.domain.model.JournalLayout
import com.chronicle.journal.domain.model.PaperStyle

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(viewModel: SettingsViewModel = hiltViewModel()) {
    val prefs by viewModel.userPreferences.collectAsState()
    val colors = LocalChronicleColors.current
    val context = LocalContext.current

    var showPinSetupDialog by remember { mutableStateOf(false) }
    var pinInput by remember { mutableStateOf("") }
    var showRestoreConfirmDialog by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        viewModel.events.collect { event ->
            when (event) {
                is SettingsEvent.ShowMessage -> {
                    Toast.makeText(context, event.message, Toast.LENGTH_SHORT).show()
                }
                is SettingsEvent.BackupSuccess -> {
                    Toast.makeText(context, "Saved to ${event.filePath}", Toast.LENGTH_LONG).show()
                }
            }
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Settings & Vault",
                        fontFamily = FontFamily.Serif,
                        fontWeight = FontWeight.Bold,
                        fontSize = 20.sp,
                        color = colors.inkPrimary,
                    )
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = colors.paperBackground),
            )
        },
    ) { paddingValues ->
        PaperBackground(modifier = Modifier.padding(paddingValues)) {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 10.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp),
            ) {
                // Appearance Section
                item {
                    SettingsCard(title = "APPEARANCE") {
                        // Theme selector
                        Text(
                            text = "Theme",
                            fontSize = 12.sp,
                            fontFamily = FontFamily.Monospace,
                            color = colors.inkMuted,
                        )
                        Spacer(modifier = Modifier.height(6.dp))
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            AppTheme.entries.forEach { theme ->
                                FilterChip(
                                    selected = prefs.theme == theme,
                                    onClick = { viewModel.setTheme(theme) },
                                    label = { Text(theme.name, fontSize = 11.sp) },
                                    colors =
                                        FilterChipDefaults.filterChipColors(
                                            selectedContainerColor = colors.inkPrimary,
                                            selectedLabelColor = colors.paperCard,
                                        ),
                                )
                            }
                        }

                        Spacer(modifier = Modifier.height(14.dp))

                        // Paper Style selector
                        Text(
                            text = "Paper Texture",
                            fontSize = 12.sp,
                            fontFamily = FontFamily.Monospace,
                            color = colors.inkMuted,
                        )
                        Spacer(modifier = Modifier.height(6.dp))
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            PaperStyle.entries.forEach { style ->
                                FilterChip(
                                    selected = prefs.paperStyle == style,
                                    onClick = { viewModel.setPaperStyle(style) },
                                    label = { Text(style.displayName, fontSize = 11.sp) },
                                    colors =
                                        FilterChipDefaults.filterChipColors(
                                            selectedContainerColor = colors.inkPrimary,
                                            selectedLabelColor = colors.paperCard,
                                        ),
                                )
                            }
                        }

                        Spacer(modifier = Modifier.height(14.dp))

                        // Default Layout selector
                        Text(
                            text = "Default Journal Layout",
                            fontSize = 12.sp,
                            fontFamily = FontFamily.Monospace,
                            color = colors.inkMuted,
                        )
                        Spacer(modifier = Modifier.height(6.dp))
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            JournalLayout.entries.forEach { layout ->
                                FilterChip(
                                    selected = prefs.defaultLayout == layout,
                                    onClick = { viewModel.setDefaultLayout(layout) },
                                    label = { Text(layout.displayName, fontSize = 11.sp) },
                                    colors =
                                        FilterChipDefaults.filterChipColors(
                                            selectedContainerColor = colors.inkPrimary,
                                            selectedLabelColor = colors.paperCard,
                                        ),
                                )
                            }
                        }
                    }
                }

                // Privacy & Lock Section
                item {
                    SettingsCard(title = "PRIVACY & APP LOCK") {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Column {
                                Text(
                                    text = "PIN Passcode Lock",
                                    fontWeight = FontWeight.Medium,
                                    fontSize = 15.sp,
                                    color = colors.inkPrimary,
                                )
                                Text(
                                    text = if (prefs.isAppLockEnabled) "Enabled" else "Disabled",
                                    fontSize = 12.sp,
                                    fontFamily = FontFamily.Monospace,
                                    color = colors.inkMuted,
                                )
                            }

                            Switch(
                                checked = prefs.isAppLockEnabled,
                                onCheckedChange = { enable ->
                                    if (enable) {
                                        showPinSetupDialog = true
                                    } else {
                                        viewModel.disableAppLock()
                                    }
                                },
                                colors =
                                    SwitchDefaults.colors(
                                        checkedThumbColor = colors.paperCard,
                                        checkedTrackColor = colors.inkPrimary,
                                    ),
                            )
                        }

                        if (prefs.isAppLockEnabled) {
                            Spacer(modifier = Modifier.height(10.dp))
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically,
                            ) {
                                Column {
                                    Text(
                                        text = "Biometric Unlock",
                                        fontWeight = FontWeight.Medium,
                                        fontSize = 15.sp,
                                        color = colors.inkPrimary,
                                    )
                                    Text(
                                        text = "Unlock with fingerprint or face",
                                        fontSize = 12.sp,
                                        fontFamily = FontFamily.Monospace,
                                        color = colors.inkMuted,
                                    )
                                }

                                Switch(
                                    checked = prefs.isBiometricEnabled,
                                    onCheckedChange = { viewModel.setBiometricEnabled(it) },
                                    colors =
                                        SwitchDefaults.colors(
                                            checkedThumbColor = colors.paperCard,
                                            checkedTrackColor = colors.inkPrimary,
                                        ),
                                )
                            }
                        }
                    }
                }

                // Reminders Section
                item {
                    SettingsCard(title = "DAILY REFLECTIONS REMINDER") {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Column {
                                Text(
                                    text = "Daily Reminder",
                                    fontWeight = FontWeight.Medium,
                                    fontSize = 15.sp,
                                    color = colors.inkPrimary,
                                )
                                Text(
                                    text =
                                        if (prefs.isReminderEnabled) {
                                            "Scheduled for %02d:%02d".format(
                                                prefs.reminderHour,
                                                prefs.reminderMinute,
                                            )
                                        } else {
                                            "Off"
                                        },
                                    fontSize = 12.sp,
                                    fontFamily = FontFamily.Monospace,
                                    color = colors.inkMuted,
                                )
                            }

                            Switch(
                                checked = prefs.isReminderEnabled,
                                onCheckedChange = { enable ->
                                    viewModel.setReminder(enable, prefs.reminderHour, prefs.reminderMinute)
                                },
                                colors =
                                    SwitchDefaults.colors(
                                        checkedThumbColor = colors.paperCard,
                                        checkedTrackColor = colors.inkPrimary,
                                    ),
                            )
                        }
                    }
                }

                // Data Backup & Export Section
                item {
                    SettingsCard(title = "BACKUP & EXPORT") {
                        Text(
                            text = "Export and secure your personal archive offline.",
                            style = HandwrittenCaptionStyle,
                            fontSize = 13.sp,
                            color = colors.inkSecondary,
                        )

                        Spacer(modifier = Modifier.height(12.dp))

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                        ) {
                            Button(
                                onClick = { viewModel.createZipBackup() },
                                colors = ButtonDefaults.buttonColors(containerColor = colors.inkPrimary),
                                modifier = Modifier.weight(1f),
                                shape = RoundedCornerShape(8.dp),
                            ) {
                                Text("ZIP Backup", fontSize = 11.sp, fontFamily = FontFamily.Monospace)
                            }

                            Button(
                                onClick = { viewModel.exportToJson() },
                                colors = ButtonDefaults.buttonColors(containerColor = colors.paperSurface),
                                modifier = Modifier.weight(1f),
                                shape = RoundedCornerShape(8.dp),
                            ) {
                                Text("Export JSON", fontSize = 11.sp, fontFamily = FontFamily.Monospace, color = colors.inkPrimary)
                            }
                        }

                        Spacer(modifier = Modifier.height(8.dp))

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                        ) {
                            Button(
                                onClick = { viewModel.exportToTxt() },
                                colors = ButtonDefaults.buttonColors(containerColor = colors.paperSurface),
                                modifier = Modifier.weight(1f),
                                shape = RoundedCornerShape(8.dp),
                            ) {
                                Text("Export Plain Text", fontSize = 11.sp, fontFamily = FontFamily.Monospace, color = colors.inkPrimary)
                            }
                        }
                    }
                }

                // About & Privacy Card
                item {
                    SettingsCard(title = "LOCAL-FIRST PRIVACY PROMISE") {
                        Text(
                            text =
                                "Chronicle Journal is built with a strict offline-first philosophy. " +
                                    "Your memories, photographs, and audio recordings never leave your device. " +
                                    "No analytics, no surveillance, no cloud leakage.",
                            fontSize = 13.sp,
                            fontFamily = FontFamily.Serif,
                            color = colors.inkSecondary,
                            lineHeight = 20.sp,
                        )

                        Spacer(modifier = Modifier.height(8.dp))

                        Text(
                            text = "Version 1.0.0 • Licensed under Apache 2.0",
                            fontSize = 11.sp,
                            fontFamily = FontFamily.Monospace,
                            color = colors.inkMuted,
                        )
                    }
                }

                item {
                    Spacer(modifier = Modifier.height(60.dp))
                }
            }
        }
    }

    if (showPinSetupDialog) {
        AlertDialog(
            onDismissRequest = { showPinSetupDialog = false },
            title = { Text("Set Passcode PIN", fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold) },
            text = {
                Column {
                    Text("Enter a 4-6 digit numeric PIN to lock your journal.", fontSize = 13.sp)
                    Spacer(modifier = Modifier.height(10.dp))
                    OutlinedTextField(
                        value = pinInput,
                        onValueChange = { if (it.length <= 6 && it.all { char -> char.isDigit() }) pinInput = it },
                        label = { Text("PIN Code") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth(),
                    )
                }
            },
            confirmButton = {
                Button(
                    onClick = {
                        if (pinInput.length in 4..6) {
                            viewModel.setPinLock(pinInput)
                            pinInput = ""
                            showPinSetupDialog = false
                        }
                    },
                ) {
                    Text("Save PIN")
                }
            },
            dismissButton = {
                TextButton(onClick = {
                    showPinSetupDialog = false
                    pinInput = ""
                }) {
                    Text("Cancel")
                }
            },
        )
    }
}

@Composable
fun SettingsCard(
    title: String,
    content: @Composable () -> Unit,
) {
    val colors = LocalChronicleColors.current

    Box(
        modifier =
            Modifier
                .fillMaxWidth()
                .shadow(2.dp, RoundedCornerShape(8.dp))
                .background(colors.paperCard, RoundedCornerShape(8.dp))
                .border(1.dp, colors.paperCardBorder, RoundedCornerShape(8.dp))
                .padding(16.dp),
    ) {
        Column {
            Text(
                text = title,
                fontFamily = FontFamily.Monospace,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                color = colors.inkSecondary,
                letterSpacing = 1.sp,
            )
            Spacer(modifier = Modifier.height(12.dp))
            content()
        }
    }
}
