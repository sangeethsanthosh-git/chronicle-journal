package com.chronicle.journal.presentation.home

import com.chronicle.journal.domain.model.JournalEntry
import com.chronicle.journal.domain.model.JournalWithDetails
import com.chronicle.journal.domain.model.MemoryItem
import com.chronicle.journal.domain.model.Mood
import com.chronicle.journal.domain.model.StreakInfo
import com.chronicle.journal.domain.repository.JournalRepository
import com.chronicle.journal.domain.usecase.CalculateStreakUseCase
import com.chronicle.journal.domain.usecase.GetMemoriesUseCase
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
import org.junit.Assert.assertNotNull
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class HomeViewModelTest {
    private val testDispatcher = StandardTestDispatcher()
    private val journalRepository: JournalRepository = mockk(relaxed = true)
    private val getMemoriesUseCase: GetMemoriesUseCase = mockk()
    private val calculateStreakUseCase: CalculateStreakUseCase = mockk()

    @Before
    fun setUp() {
        Dispatchers.setMain(testDispatcher)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `loadHomeData updates uiState with entries, streak, and memories`() =
        runTest(testDispatcher) {
            val todayMillis = System.currentTimeMillis()
            val entry =
                JournalEntry(
                    id = 1L,
                    title = "Morning Coffee",
                    content = "Great day ahead",
                    entryDate = todayMillis,
                    mood = Mood.HAPPY,
                )
            val entryWithDetails = JournalWithDetails(entry = entry)
            val expectedStreak = StreakInfo(currentStreak = 3, longestStreak = 5, totalActiveDays = 8)
            val memory = MemoryItem(entryWithDetails = entryWithDetails, yearsAgo = 1, formattedDate = "1 year ago today")

            every { journalRepository.getAllEntries() } returns flowOf(listOf(entryWithDetails))
            every { calculateStreakUseCase.execute(any(), any()) } returns expectedStreak
            every { getMemoriesUseCase.execute(any()) } returns flowOf(listOf(memory))

            val viewModel = HomeViewModel(journalRepository, getMemoriesUseCase, calculateStreakUseCase)
            advanceUntilIdle()

            val state = viewModel.uiState.value
            assertFalse(state.isLoading)
            assertNotNull(state.todayEntry)
            assertEquals("Morning Coffee", state.todayEntry?.entry?.title)
            assertEquals(3, state.streakInfo.currentStreak)
            assertEquals(1, state.memories.size)
        }

    @Test
    fun `toggleFavorite calls journalRepository toggleFavorite`() =
        runTest(testDispatcher) {
            every { journalRepository.getAllEntries() } returns flowOf(emptyList())
            every { calculateStreakUseCase.execute(any(), any()) } returns StreakInfo()
            every { getMemoriesUseCase.execute(any()) } returns flowOf(emptyList())

            val viewModel = HomeViewModel(journalRepository, getMemoriesUseCase, calculateStreakUseCase)
            advanceUntilIdle()

            viewModel.toggleFavorite(42L, true)
            advanceUntilIdle()

            coVerify { journalRepository.toggleFavorite(42L, true) }
        }
}
