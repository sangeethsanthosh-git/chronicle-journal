package com.chronicle.journal.domain.usecase

import com.chronicle.journal.domain.model.JournalEntry
import com.chronicle.journal.testutil.FakeJournalRepository
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Before
import org.junit.Test

class DeleteEntryUseCaseTest {
    private lateinit var repository: FakeJournalRepository
    private lateinit var deleteUseCase: DeleteEntryUseCase

    @Before
    fun setUp() {
        repository = FakeJournalRepository()
        deleteUseCase = DeleteEntryUseCase(repository)
    }

    @Test
    fun `deleting entry removes it from active repository`() =
        runTest {
            val entry = JournalEntry(title = "Title to remove", content = "Content")
            val id = repository.saveEntry(entry, emptyList(), emptyList())
            assertNotNull(repository.getEntryByIdSync(id))

            deleteUseCase.execute(id)

            assertNull(repository.getEntryByIdSync(id))
        }
}
