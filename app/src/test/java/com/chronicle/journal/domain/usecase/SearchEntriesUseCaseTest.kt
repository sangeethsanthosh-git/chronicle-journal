package com.chronicle.journal.domain.usecase

import com.chronicle.journal.domain.model.JournalEntry
import com.chronicle.journal.domain.model.Mood
import com.chronicle.journal.domain.model.Tag
import com.chronicle.journal.testutil.FakeJournalRepository
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test

class SearchEntriesUseCaseTest {
    private lateinit var repository: FakeJournalRepository
    private lateinit var searchUseCase: SearchEntriesUseCase

    @Before
    fun setUp() =
        runTest {
            repository = FakeJournalRepository()
            searchUseCase = SearchEntriesUseCase(repository)

            repository.saveEntry(
                JournalEntry(id = 1, title = "Kyoto Journey", content = "Temple bells ringing softly.", mood = Mood.CALM),
                listOf(Tag(1, "japan")),
                emptyList(),
            )
            repository.saveEntry(
                JournalEntry(id = 2, title = "Baking Bread", content = "Sourdough starter was active and bubbly.", mood = Mood.EXCITED),
                listOf(Tag(2, "baking")),
                emptyList(),
            )
            repository.saveEntry(
                JournalEntry(id = 3, title = "Tokyo Night", content = "Neon lights reflecting on wet pavement.", mood = Mood.CALM),
                listOf(Tag(1, "japan")),
                emptyList(),
            )
        }

    @Test
    fun `search by title keyword returns matches`() =
        runTest {
            val results = searchUseCase.execute("Kyoto").first()
            assertEquals(1, results.size)
            assertEquals("Kyoto Journey", results.first().entry.title)
        }

    @Test
    fun `search by content keyword returns matches`() =
        runTest {
            val results = searchUseCase.execute("Sourdough").first()
            assertEquals(1, results.size)
            assertEquals("Baking Bread", results.first().entry.title)
        }

    @Test
    fun `search by tag name returns matches`() =
        runTest {
            val results = searchUseCase.execute("japan").first()
            assertEquals(2, results.size)
        }

    @Test
    fun `search with combined mood filter returns filtered matches`() =
        runTest {
            val results =
                searchUseCase
                    .execute(
                        query = "japan",
                        filterCriteria = EntryFilterCriteria(mood = Mood.CALM),
                    ).first()

            assertEquals(2, results.size)
        }
}
