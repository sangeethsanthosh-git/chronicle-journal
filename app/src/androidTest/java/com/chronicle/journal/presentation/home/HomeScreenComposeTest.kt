package com.chronicle.journal.presentation.home

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import com.chronicle.journal.core.designsystem.components.EmptyState
import com.chronicle.journal.core.designsystem.components.SectionHeader
import com.chronicle.journal.core.designsystem.theme.ChronicleTheme
import org.junit.Rule
import org.junit.Test

class HomeScreenComposeTest {
    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun sectionHeaderDisplaysTitleAndSubtitle() {
        composeTestRule.setContent {
            ChronicleTheme {
                SectionHeader(
                    title = "Memories",
                    actionLabel = "View All",
                    onActionClick = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Memories").assertIsDisplayed()
        composeTestRule.onNodeWithText("View All").assertIsDisplayed()
    }

    @Test
    fun emptyStateDisplaysMessageAndAction() {
        composeTestRule.setContent {
            ChronicleTheme {
                EmptyState(
                    title = "No journal entries yet",
                    message = "Tap the plus button to pen your first thought.",
                    actionLabel = "Start Writing",
                )
            }
        }

        composeTestRule.onNodeWithText("No journal entries yet").assertIsDisplayed()
        composeTestRule.onNodeWithText("Tap the plus button to pen your first thought.").assertIsDisplayed()
        composeTestRule.onNodeWithText("Start Writing").assertIsDisplayed()
    }
}
