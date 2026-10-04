package com.chronicle.journal.data.repository

import com.chronicle.journal.data.local.dao.AttachmentDao
import com.chronicle.journal.data.local.dao.CollectionDao
import com.chronicle.journal.data.local.dao.JournalEntryDao
import com.chronicle.journal.data.local.dao.TagDao
import com.chronicle.journal.data.local.entities.AttachmentEntity
import com.chronicle.journal.data.local.entities.JournalEntryEntity
import com.chronicle.journal.data.local.entities.JournalEntryWithDetailsRelation
import com.chronicle.journal.data.local.entities.TagEntity
import com.chronicle.journal.domain.model.Attachment
import com.chronicle.journal.domain.model.AttachmentType
import com.chronicle.journal.domain.model.JournalEntry
import com.chronicle.journal.domain.model.Mood
import com.chronicle.journal.domain.model.Tag
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test

class JournalRepositoryImplTest {
    private val journalEntryDao: JournalEntryDao = mockk(relaxed = true)
    private val tagDao: TagDao = mockk(relaxed = true)
    private val attachmentDao: AttachmentDao = mockk(relaxed = true)
    private val collectionDao: CollectionDao = mockk(relaxed = true)

    private lateinit var repository: JournalRepositoryImpl

    @Before
    fun setUp() {
        repository =
            JournalRepositoryImpl(
                journalEntryDao = journalEntryDao,
                tagDao = tagDao,
                attachmentDao = attachmentDao,
                collectionDao = collectionDao,
            )
    }

    @Test
    fun `getAllEntries maps relations to domain models`() =
        runTest {
            val entryEntity =
                JournalEntryEntity(
                    id = 10L,
                    title = "Test Reflection",
                    content = "Testing content",
                    createdAt = 1000L,
                    updatedAt = 1000L,
                    entryDate = 1000L,
                    mood = "PEACEFUL",
                    moodIntensity = 4,
                    isFavorite = true,
                )
            val tagEntity = TagEntity(id = 1L, name = "Mindfulness", colorHex = "#AABBCC")
            val attachmentEntity =
                AttachmentEntity(
                    id = 2L,
                    journalEntryId = 10L,
                    uri = "file://photo.jpg",
                    type = "PHOTO",
                    caption = "Calm morning",
                )
            val relation =
                JournalEntryWithDetailsRelation(
                    entry = entryEntity,
                    tags = listOf(tagEntity),
                    attachments = listOf(attachmentEntity),
                )

            every { journalEntryDao.getAllActiveEntries() } returns flowOf(listOf(relation))

            val result = repository.getAllEntries().first()
            assertEquals(1, result.size)
            val domainEntry = result.first()
            assertEquals(10L, domainEntry.entry.id)
            assertEquals("Test Reflection", domainEntry.entry.title)
            assertEquals(1, domainEntry.tags.size)
            assertEquals("Mindfulness", domainEntry.tags.first().name)
            assertEquals(1, domainEntry.attachments.size)
            assertEquals("file://photo.jpg", domainEntry.attachments.first().uri)
        }

    @Test
    fun `saveEntry inserts new entry and associates tags and attachments`() =
        runTest {
            val entry =
                JournalEntry(
                    id = 0L,
                    title = "New Memory",
                    content = "Exciting adventure",
                    mood = Mood.EXCITED,
                )
            val tags = listOf(Tag(id = 0L, name = "Adventure", colorHex = "#FF5500"))
            val attachments =
                listOf(
                    Attachment(id = 0L, journalEntryId = 0L, uri = "content://image.png", type = AttachmentType.PHOTO),
                )

            coEvery { journalEntryDao.insertEntry(any()) } returns 99L
            coEvery { tagDao.getTagByName("Adventure") } returns null
            coEvery { tagDao.insertTag(any()) } returns 5L

            val returnedId =
                repository.saveEntry(
                    entry = entry,
                    tags = tags,
                    attachments = attachments,
                    collectionIds = emptyList(),
                )

            assertEquals(99L, returnedId)
            coVerify { journalEntryDao.insertEntry(any()) }
            coVerify { journalEntryDao.deleteTagsForEntry(99L) }
            coVerify { journalEntryDao.insertEntryTagCrossRef(any()) }
            coVerify { attachmentDao.insertAttachment(any()) }
        }

    @Test
    fun `deleteEntry triggers soft delete`() =
        runTest {
            repository.deleteEntry(42L)
            coVerify { journalEntryDao.softDeleteEntry(42L, any()) }
        }

    @Test
    fun `toggleFavorite updates favorite state in DAO`() =
        runTest {
            repository.toggleFavorite(42L, true)
            coVerify { journalEntryDao.setFavorite(42L, true) }
        }
}
