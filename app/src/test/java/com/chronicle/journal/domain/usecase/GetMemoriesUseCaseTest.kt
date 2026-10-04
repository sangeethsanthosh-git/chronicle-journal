package com.chronicle.journal.domain.usecase

import com.chronicle.journal.core.common.TimeUtils
import com.chronicle.journal.domain.model.JournalEntry
import com.chronicle.journal.testutil.FakeJournalRepository
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test
import java.time.LocalDate

class GetMemoriesUseCaseTest {
    private lateinit var repository: FakeJournalRepository
    private lateinit var memoriesUseCase: GetMemoriesUseCase

    private val referenceDate = LocalDate.of(2026, 10, 4)

    @Before
    fun setUp() {
        repository = FakeJournalRepository()
        memoriesUseCase = GetMemoriesUseCase(repository)
    }

    @Test
    fun `entry exactly one year ago today surfaces as anniversary memory`() =
        runTest {
            val oneYearAgoToday = LocalDate.of(2025, 10, 4)
            val epoch = TimeUtils.fromLocalDate(oneYearAgoToday)

            repository.saveEntry(
                JournalEntry(id = 1, title = "Autumn beginning", content = "Golden leaves falling.", entryDate = epoch),
                emptyList(),
                emptyList(),
            )

            val memories = memoriesUseCase.execute(referenceDate).first()

            assertEquals(1, memories.size)
            assertEquals(1, memories.first().yearsAgo)
            assertEquals("1 year ago today", memories.first().formattedDate)
            assertEquals(
                "Autumn beginning",
                memories
                    .first()
                    .entryWithDetails.entry.title,
            )
        }

    @Test
    fun `entry three years ago today surfaces as 3 years ago`() =
        runTest {
            val threeYearsAgoToday = LocalDate.of(2023, 10, 4)
            val epoch = TimeUtils.fromLocalDate(threeYearsAgoToday)

            repository.saveEntry(
                JournalEntry(id = 2, title = "Moving to new apartment", content = "Packed all boxes.", entryDate = epoch),
                emptyList(),
                emptyList(),
            )

            val memories = memoriesUseCase.execute(referenceDate).first()

            assertEquals(1, memories.size)
            assertEquals(3, memories.first().yearsAgo)
            assertEquals("3 years ago today", memories.first().formattedDate)
        }
}
