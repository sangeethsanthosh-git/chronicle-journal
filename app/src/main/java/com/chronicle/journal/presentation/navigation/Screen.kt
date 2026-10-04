package com.chronicle.journal.presentation.navigation

sealed class Screen(
    val route: String,
) {
    data object Home : Screen("home")

    data object Journal : Screen("journal")

    data object Calendar : Screen("calendar")

    data object Insights : Screen("insights")

    data object Settings : Screen("settings")

    data object Search : Screen("search")

    data object Collections : Screen("collections")

    data object CollectionDetail : Screen("collection_detail/{collectionId}") {
        fun createRoute(collectionId: Long): String = "collection_detail/$collectionId"
    }

    data object Memories : Screen("memories")

    data object Editor : Screen("editor?entryId={entryId}&entryDate={entryDate}") {
        fun createRoute(
            entryId: Long = -1L,
            entryDate: Long = -1L,
        ): String = "editor?entryId=$entryId&entryDate=$entryDate"
    }

    data object EntryDetail : Screen("entry_detail/{entryId}") {
        fun createRoute(entryId: Long): String = "entry_detail/$entryId"
    }

    data object Lock : Screen("lock")

    data object Onboarding : Screen("onboarding")
}
