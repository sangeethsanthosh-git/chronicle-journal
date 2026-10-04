package com.chronicle.journal.presentation.journal

import com.chronicle.journal.domain.model.JournalEntry
import com.chronicle.journal.domain.model.JournalWithDetails
import com.chronicle.journal.domain.model.Mood
import com.chronicle.journal.domain.model.Tag
import com.chronicle.journal.domain.repository.JournalRepository
import com.chronicle.journal.domain.usecase.EntrySortOption
import com.chronicle.journal.domain.usecase.GetEntriesUseCase
import io.mockk.coVerify
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class JournalTimelineViewModelTest {
    private val testDispatcher = StandardTestDispatcher()
    private val journalRepository: JournalRepository = mockk(relaxed = true)
    private val getEntriesUseCase: GetEntriesUseCase = mockk()

    @Before
    fun setUp() {
        Dispatchers.setMain(testDispatcher)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `initial load fetches tags and entries`() =
        runTest(testDispatcher) {
            val tag = Tag(id = 1L, name = "Travel", colorHex = "#FF0000")
            val entry =
                JournalWithDetails(
                    entry = JournalEntry(id = 1L, title = "Paris Trip", content = "Exploring Montmartre", mood = Mood.HAPPY),
                    tags = listOf(tag),
                )

            every { journalRepository.getAllTags() } returns flowOf(listOf(tag))
            every { getEntriesUseCase.execute(any(), any()) } returns flowOf(listOf(entry))

            val viewModel = JournalTimelineViewModel(journalRepository, getEntriesUseCase)
            advanceUntilIdle()

            val state = viewModel.uiState.value
            assertFalse(state.isLoading)
            assertEquals(1, state.entries.size)
            assertEquals(
                "Paris Trip",
                state.entries
                    .first()
                    .entry.title,
            )
            assertEquals(1, state.availableTags.size)
        }

    @Test
    fun `setViewMode updates viewMode correctly`() =
        runTest(testDispatcher) {
            every { journalRepository.getAllTags() } returns flowOf(emptyList())
            every { getEntriesUseCase.execute(any(), any()) } returns flowOf(emptyList())

            val viewModel = JournalTimelineViewModel(journalRepository, getEntriesUseCase)
            advanceUntilIdle()

            viewModel.setViewMode(TimelineViewMode.SCRAPBOOK)
            assertEquals(TimelineViewMode.SCRAPBOOK, viewModel.uiState.value.viewMode)

            viewModel.setViewMode(TimelineViewMode.POSTCARD)
            assertEquals(TimelineViewMode.POSTCARD, viewModel.uiState.value.viewMode)
        }

    @Test
    fun `filtering by mood and favorites triggers updated criteria`() =
        runTest(testDispatcher) {
            every { journalRepository.getAllTags() } returns flowOf(emptyList())
            every { getEntriesUseCase.execute(any(), any()) } returns flowOf(emptyList())

            val viewModel = JournalTimelineViewModel(journalRepository, getEntriesUseCase)
            advanceUntilIdle()

            viewModel.filterByMood(Mood.CALM)
            assertEquals(Mood.CALM, viewModel.uiState.value.filterCriteria.mood)

            viewModel.toggleFavoritesOnly()
            assertTrue(viewModel.uiState.value.filterCriteria.onlyFavorites)

            viewModel.setSortOption(EntrySortOption.OLDEST)
            assertEquals(EntrySortOption.OLDEST, viewModel.uiState.value.sortOption)
        }

    @Test
    fun `toggleFavorite delegates to repository`() =
        runTest(testDispatcher) {
            every { journalRepository.getAllTags() } returns flowOf(emptyList())
            every { getEntriesUseCase.execute(any(), any()) } returns flowOf(emptyList())

            val viewModel = JournalTimelineViewModel(journalRepository, getEntriesUseCase)
            advanceUntilIdle()

            viewModel.toggleFavorite(100L, true)
            advanceUntilIdle()

            coVerify { journalRepository.toggleFavorite(100L, true) }
        }
}
