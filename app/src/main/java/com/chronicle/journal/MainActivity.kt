package com.chronicle.journal

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.navigation.compose.rememberNavController
import com.chronicle.journal.core.designsystem.theme.ChronicleTheme
import com.chronicle.journal.core.designsystem.theme.LocalChronicleColors
import com.chronicle.journal.data.preferences.AppTheme
import com.chronicle.journal.data.preferences.UserPreferencesRepository
import com.chronicle.journal.domain.model.PaperStyle
import com.chronicle.journal.presentation.navigation.ChronicleNavHost
import com.chronicle.journal.presentation.navigation.Screen
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    @Inject
    lateinit var preferencesRepository: UserPreferencesRepository

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            val prefsState by preferencesRepository.userPreferencesFlow.collectAsState(initial = null)
            val currentPrefs = prefsState

            ChronicleTheme(
                appTheme = currentPrefs?.theme ?: AppTheme.SYSTEM,
                paperStyle = currentPrefs?.paperStyle ?: PaperStyle.PLAIN,
            ) {
                if (currentPrefs == null) {
                    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator(color = LocalChronicleColors.current.inkPrimary)
                    }
                } else {
                    val navController = rememberNavController()

                    val startDestination =
                        when {
                            !currentPrefs.isOnboardingCompleted -> Screen.Onboarding.route
                            currentPrefs.isAppLockEnabled -> Screen.Lock.route
                            else -> Screen.Home.route
                        }

                    ChronicleNavHost(
                        navController = navController,
                        startDestination = startDestination,
                    )
                }
            }
        }
    }
}
