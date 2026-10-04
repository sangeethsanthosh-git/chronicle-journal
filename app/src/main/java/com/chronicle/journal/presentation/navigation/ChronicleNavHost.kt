package com.chronicle.journal.presentation.navigation

import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.navArgument
import com.chronicle.journal.core.designsystem.components.ChronicleNavigationBar
import com.chronicle.journal.presentation.calendar.CalendarScreen
import com.chronicle.journal.presentation.collections.CollectionDetailScreen
import com.chronicle.journal.presentation.collections.CollectionsScreen
import com.chronicle.journal.presentation.editor.JournalEditorScreen
import com.chronicle.journal.presentation.home.HomeScreen
import com.chronicle.journal.presentation.insights.InsightsScreen
import com.chronicle.journal.presentation.journal.EntryDetailScreen
import com.chronicle.journal.presentation.journal.JournalTimelineScreen
import com.chronicle.journal.presentation.lock.LockScreen
import com.chronicle.journal.presentation.onboarding.OnboardingScreen
import com.chronicle.journal.presentation.search.SearchScreen
import com.chronicle.journal.presentation.settings.SettingsScreen

@Composable
fun ChronicleNavHost(
    navController: NavHostController,
    startDestination: String,
    modifier: Modifier = Modifier,
) {
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    val bottomBarRoutes =
        listOf(
            Screen.Home.route,
            Screen.Journal.route,
            Screen.Calendar.route,
            Screen.Insights.route,
            Screen.Settings.route,
        )

    val showBottomBar = currentRoute in bottomBarRoutes

    Scaffold(
        bottomBar = {
            if (showBottomBar) {
                ChronicleNavigationBar(
                    currentRoute = currentRoute,
                    onNavigateToRoute = { route ->
                        navController.navigate(route) {
                            popUpTo(navController.graph.findStartDestination().id) {
                                saveState = true
                            }
                            launchSingleTop = true
                            restoreState = true
                        }
                    },
                )
            }
        },
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = startDestination,
            modifier = modifier.padding(innerPadding),
            enterTransition = { fadeIn(animationSpec = tween(250)) },
            exitTransition = { fadeOut(animationSpec = tween(250)) },
        ) {
            composable(Screen.Onboarding.route) {
                OnboardingScreen(
                    onFinished = {
                        navController.navigate(Screen.Home.route) {
                            popUpTo(Screen.Onboarding.route) { inclusive = true }
                        }
                    },
                )
            }

            composable(Screen.Lock.route) {
                LockScreen(
                    onUnlockSuccess = {
                        navController.navigate(Screen.Home.route) {
                            popUpTo(Screen.Lock.route) { inclusive = true }
                        }
                    },
                )
            }

            composable(Screen.Home.route) {
                HomeScreen(
                    onNavigateToEditor = { entryId ->
                        navController.navigate(Screen.Editor.createRoute(entryId = entryId))
                    },
                    onNavigateToEntryDetail = { entryId ->
                        navController.navigate(Screen.EntryDetail.createRoute(entryId))
                    },
                    onNavigateToSearch = { navController.navigate(Screen.Search.route) },
                    onNavigateToCollections = { navController.navigate(Screen.Collections.route) },
                    onNavigateToMemories = { navController.navigate(Screen.Memories.route) },
                    onNavigateToJournal = { navController.navigate(Screen.Journal.route) },
                )
            }

            composable(Screen.Journal.route) {
                JournalTimelineScreen(
                    onNavigateToEditor = { entryId ->
                        navController.navigate(Screen.Editor.createRoute(entryId = entryId))
                    },
                    onNavigateToDetail = { entryId ->
                        navController.navigate(Screen.EntryDetail.createRoute(entryId))
                    },
                )
            }

            composable(Screen.Calendar.route) {
                CalendarScreen(
                    onNavigateToEditorWithDate = { dateMillis ->
                        navController.navigate(Screen.Editor.createRoute(entryId = -1L, entryDate = dateMillis))
                    },
                    onNavigateToDetail = { entryId ->
                        navController.navigate(Screen.EntryDetail.createRoute(entryId))
                    },
                )
            }

            composable(Screen.Insights.route) {
                InsightsScreen()
            }

            composable(Screen.Settings.route) {
                SettingsScreen()
            }

            composable(Screen.Search.route) {
                SearchScreen(
                    onNavigateBack = { navController.popBackStack() },
                    onNavigateToDetail = { entryId ->
                        navController.navigate(Screen.EntryDetail.createRoute(entryId))
                    },
                )
            }

            composable(Screen.Collections.route) {
                CollectionsScreen(
                    onNavigateBack = { navController.popBackStack() },
                    onNavigateToCollectionDetail = { id ->
                        navController.navigate(Screen.CollectionDetail.createRoute(id))
                    },
                )
            }

            composable(
                route = Screen.CollectionDetail.route,
                arguments = listOf(navArgument("collectionId") { type = NavType.StringType }),
            ) {
                CollectionDetailScreen(
                    onNavigateBack = { navController.popBackStack() },
                    onNavigateToDetail = { entryId ->
                        navController.navigate(Screen.EntryDetail.createRoute(entryId))
                    },
                    onNavigateToEditor = {
                        navController.navigate(Screen.Editor.createRoute(-1L))
                    },
                )
            }

            composable(Screen.Memories.route) {
                com.chronicle.journal.presentation.memories.MemoriesScreen(
                    onNavigateBack = { navController.popBackStack() },
                    onNavigateToDetail = { entryId ->
                        navController.navigate(Screen.EntryDetail.createRoute(entryId))
                    },
                )
            }

            composable(
                route = Screen.Editor.route,
                arguments =
                    listOf(
                        navArgument("entryId") {
                            type = NavType.StringType
                            defaultValue = "-1"
                        },
                        navArgument("entryDate") {
                            type = NavType.StringType
                            defaultValue = "-1"
                        },
                    ),
            ) {
                JournalEditorScreen(
                    onNavigateBack = { navController.popBackStack() },
                )
            }

            composable(
                route = Screen.EntryDetail.route,
                arguments = listOf(navArgument("entryId") { type = NavType.StringType }),
            ) {
                EntryDetailScreen(
                    onNavigateBack = { navController.popBackStack() },
                    onNavigateToEdit = { entryId ->
                        navController.navigate(Screen.Editor.createRoute(entryId = entryId))
                    },
                )
            }
        }
    }
}
