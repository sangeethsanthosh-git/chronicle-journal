package com.chronicle.journal.domain.usecase

import com.chronicle.journal.domain.model.JournalEntry
import com.chronicle.journal.testutil.FakeJournalRepository
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Before
import org.junit.Test

class SaveEntryUseCaseTest {
    private lateinit var repository: FakeJournalRepository
    private lateinit var useCase: SaveEntryUseCase

    @Before
    fun setUp() {
        repository = FakeJournalRepository()
        useCase = SaveEntryUseCase(repository)
    }

    @Test(expected = IllegalArgumentException::class)
    fun `saving blank entry throws exception`() =
        runTest {
            val entry =
                JournalEntry(
                    title = "   ",
                    content = "   ",
                )
            useCase.execute(entry, emptyList(), emptyList())
        }

    @Test
    fun `saving valid entry stores entry and clears draft`() =
        runTest {
            val entry =
                JournalEntry(
                    title = "My First Page",
                    content = "Today was a warm sunny afternoon in the library.",
                )

            val id = useCase.execute(entry, emptyList(), emptyList())

            assertEquals(1L, id)
            val saved = repository.getEntryByIdSync(id)
            assertNotNull(saved)
            assertEquals("My First Page", saved?.entry?.title)
            assertNull(repository.draftFlow.value)
        }

    @Test
    fun `updating existing entry preserves id and updates content`() =
        runTest {
            val initial =
                JournalEntry(
                    title = "Original Title",
                    content = "Initial reflection.",
                )
            val id = useCase.execute(initial, emptyList(), emptyList())

            val updated = initial.copy(id = id, title = "Updated Title", content = "Edited reflection.")
            useCase.execute(updated, emptyList(), emptyList())

            val stored = repository.getEntryByIdSync(id)
            assertEquals("Updated Title", stored?.entry?.title)
            assertEquals("Edited reflection.", stored?.entry?.content)
        }
}
