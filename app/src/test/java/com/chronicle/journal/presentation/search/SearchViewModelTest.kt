package com.chronicle.journal.presentation.search

import com.chronicle.journal.domain.model.JournalEntry
import com.chronicle.journal.domain.model.JournalWithDetails
import com.chronicle.journal.domain.model.Mood
import com.chronicle.journal.domain.repository.JournalRepository
import com.chronicle.journal.domain.usecase.SearchEntriesUseCase
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.advanceTimeBy
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
class SearchViewModelTest {
    private val testDispatcher = StandardTestDispatcher()
    private val journalRepository: JournalRepository = mockk(relaxed = true)
    private val searchEntriesUseCase: SearchEntriesUseCase = mockk()

    @Before
    fun setUp() {
        Dispatchers.setMain(testDispatcher)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `query input is debounced and triggers search`() =
        runTest(testDispatcher) {
            val entry =
                JournalWithDetails(
                    entry = JournalEntry(id = 1L, title = "Search Match", content = "Searching for truth"),
                )

            every { journalRepository.getAllTags() } returns flowOf(emptyList())
            every { searchEntriesUseCase.execute(any(), any()) } returns flowOf(listOf(entry))

            val viewModel = SearchViewModel(journalRepository, searchEntriesUseCase)
            advanceUntilIdle()

            viewModel.onQueryChange("Search")
            // Before debounce period
            advanceTimeBy(100)
            assertFalse(viewModel.uiState.value.hasSearched)

            // After debounce period (300ms)
            advanceTimeBy(250)
            advanceUntilIdle()

            val state = viewModel.uiState.value
            assertTrue(state.hasSearched)
            assertEquals(1, state.results.size)
            assertEquals(
                "Search Match",
                state.results
                    .first()
                    .entry.title,
            )
        }

    @Test
    fun `filter changes trigger search immediately`() =
        runTest(testDispatcher) {
            val entry =
                JournalWithDetails(
                    entry = JournalEntry(id = 2L, title = "Happy Memories", content = "Good times", mood = Mood.HAPPY),
                )

            every { journalRepository.getAllTags() } returns flowOf(emptyList())
            every { searchEntriesUseCase.execute(any(), any()) } returns flowOf(listOf(entry))

            val viewModel = SearchViewModel(journalRepository, searchEntriesUseCase)
            advanceUntilIdle()

            viewModel.setFilterMood(Mood.HAPPY)
            advanceUntilIdle()

            val state = viewModel.uiState.value
            assertTrue(state.hasSearched)
            assertEquals(Mood.HAPPY, state.filterCriteria.mood)
            assertEquals(1, state.results.size)
        }

    @Test
    fun `clearFilters resets filter criteria`() =
        runTest(testDispatcher) {
            every { journalRepository.getAllTags() } returns flowOf(emptyList())
            every { searchEntriesUseCase.execute(any(), any()) } returns flowOf(emptyList())

            val viewModel = SearchViewModel(journalRepository, searchEntriesUseCase)
            advanceUntilIdle()

            viewModel.setFilterMood(Mood.EXCITED)
            viewModel.toggleFavoritesOnly()
            advanceUntilIdle()

            viewModel.clearFilters()
            advanceUntilIdle()

            val criteria = viewModel.uiState.value.filterCriteria
            assertEquals(null, criteria.mood)
            assertFalse(criteria.onlyFavorites)
        }
}
