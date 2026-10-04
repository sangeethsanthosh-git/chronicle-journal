package com.chronicle.journal.core.designsystem.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat
import com.chronicle.journal.data.preferences.AppTheme
import com.chronicle.journal.domain.model.PaperStyle

data class ChronicleColors(
    val paperBackground: Color,
    val paperSurface: Color,
    val paperCard: Color,
    val paperCardBorder: Color,
    val ruledLine: Color,
    val gridDot: Color,
    val inkPrimary: Color,
    val inkSecondary: Color,
    val inkMuted: Color,
    val isDark: Boolean,
)

val LocalChronicleColors =
    compositionLocalOf {
        ChronicleColors(
            paperBackground = PaperBackgroundLight,
            paperSurface = PaperSurfaceLight,
            paperCard = PaperCardLight,
            paperCardBorder = PaperCardBorderLight,
            ruledLine = RuledLineColorLight,
            gridDot = GridDotColorLight,
            inkPrimary = InkPrimaryLight,
            inkSecondary = InkSecondaryLight,
            inkMuted = InkMutedLight,
            isDark = false,
        )
    }

val LocalPaperStyle = compositionLocalOf { PaperStyle.PLAIN }

private val LightColorScheme =
    lightColorScheme(
        primary = InkPrimaryLight,
        onPrimary = PaperCardLight,
        primaryContainer = PaperSurfaceLight,
        onPrimaryContainer = InkPrimaryLight,
        secondary = VintageGold,
        onSecondary = PaperCardLight,
        secondaryContainer = WashiTapeKraft,
        onSecondaryContainer = InkPrimaryLight,
        tertiary = PostalStampBlue,
        onTertiary = PaperCardLight,
        background = PaperBackgroundLight,
        onBackground = InkPrimaryLight,
        surface = PaperSurfaceLight,
        onSurface = InkPrimaryLight,
        surfaceVariant = PaperCardBorderLight,
        onSurfaceVariant = InkSecondaryLight,
        outline = PaperCardBorderLight,
        outlineVariant = RuledLineColorLight,
    )

private val DarkColorScheme =
    darkColorScheme(
        primary = InkPrimaryDark,
        onPrimary = PaperCardDark,
        primaryContainer = PaperSurfaceDark,
        onPrimaryContainer = InkPrimaryDark,
        secondary = VintageGold,
        onSecondary = PaperBackgroundDark,
        secondaryContainer = PaperCardBorderDark,
        onSecondaryContainer = InkPrimaryDark,
        tertiary = WashiTapeNavy,
        onTertiary = PaperBackgroundDark,
        background = PaperBackgroundDark,
        onBackground = InkPrimaryDark,
        surface = PaperSurfaceDark,
        onSurface = InkPrimaryDark,
        surfaceVariant = PaperCardBorderDark,
        onSurfaceVariant = InkSecondaryDark,
        outline = PaperCardBorderDark,
        outlineVariant = RuledLineColorDark,
    )

@Composable
fun ChronicleTheme(
    appTheme: AppTheme = AppTheme.SYSTEM,
    paperStyle: PaperStyle = PaperStyle.PLAIN,
    content: @Composable () -> Unit,
) {
    val darkTheme =
        when (appTheme) {
            AppTheme.LIGHT -> false
            AppTheme.DARK -> true
            AppTheme.SYSTEM -> isSystemInDarkTheme()
        }

    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme
    val chronicleColors =
        if (darkTheme) {
            ChronicleColors(
                paperBackground = PaperBackgroundDark,
                paperSurface = PaperSurfaceDark,
                paperCard = PaperCardDark,
                paperCardBorder = PaperCardBorderDark,
                ruledLine = RuledLineColorDark,
                gridDot = GridDotColorDark,
                inkPrimary = InkPrimaryDark,
                inkSecondary = InkSecondaryDark,
                inkMuted = InkMutedDark,
                isDark = true,
            )
        } else {
            ChronicleColors(
                paperBackground = PaperBackgroundLight,
                paperSurface = PaperSurfaceLight,
                paperCard = PaperCardLight,
                paperCardBorder = PaperCardBorderLight,
                ruledLine = RuledLineColorLight,
                gridDot = GridDotColorLight,
                inkPrimary = InkPrimaryLight,
                inkSecondary = InkSecondaryLight,
                inkMuted = InkMutedLight,
                isDark = false,
            )
        }

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as? Activity)?.window
            if (window != null) {
                window.statusBarColor = chronicleColors.paperBackground.toArgb()
                window.navigationBarColor = chronicleColors.paperBackground.toArgb()
                val controller = WindowCompat.getInsetsController(window, view)
                controller.isAppearanceLightStatusBars = !darkTheme
                controller.isAppearanceLightNavigationBars = !darkTheme
            }
        }
    }

    CompositionLocalProvider(
        LocalChronicleColors provides chronicleColors,
        LocalPaperStyle provides paperStyle,
    ) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = ChronicleTypography,
            content = content,
        )
    }
}
