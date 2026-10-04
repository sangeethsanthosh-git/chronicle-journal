package com.chronicle.journal.domain.usecase

import com.chronicle.journal.domain.model.Attachment
import com.chronicle.journal.domain.model.AttachmentType
import com.chronicle.journal.domain.model.JournalEntry
import com.chronicle.journal.domain.model.Mood
import com.chronicle.journal.domain.model.Tag
import com.chronicle.journal.testutil.FakeJournalRepository
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

class GetEntriesUseCaseTest {
    private lateinit var repository: FakeJournalRepository
    private lateinit var useCase: GetEntriesUseCase

    private val tagTravel = Tag(id = 1, name = "travel")
    private val tagCoffee = Tag(id = 2, name = "coffee")

    @Before
    fun setUp() =
        runTest {
            repository = FakeJournalRepository()
            useCase = GetEntriesUseCase(repository)

            // Populate test data
            repository.saveEntry(
                JournalEntry(id = 1, title = "A", content = "one", entryDate = 1000, mood = Mood.HAPPY, isFavorite = false),
                listOf(tagTravel),
                emptyList(),
            )
            repository.saveEntry(
                JournalEntry(id = 2, title = "B", content = "two", entryDate = 3000, mood = Mood.CALM, isFavorite = true),
                listOf(tagCoffee),
                listOf(Attachment(id = 1, uri = "photo.jpg", type = AttachmentType.PHOTO)),
            )
            repository.saveEntry(
                JournalEntry(id = 3, title = "C", content = "three", entryDate = 2000, mood = Mood.HAPPY, isFavorite = true),
                listOf(tagTravel, tagCoffee),
                listOf(Attachment(id = 2, uri = "audio.m4a", type = AttachmentType.AUDIO)),
            )
        }

    @Test
    fun `default sort returns newest first`() =
        runTest {
            val result = useCase.execute(sortOption = EntrySortOption.NEWEST).first()
            assertEquals(3, result.size)
            assertEquals(2L, result[0].entry.id) // 3000
            assertEquals(3L, result[1].entry.id) // 2000
            assertEquals(1L, result[2].entry.id) // 1000
        }

    @Test
    fun `oldest sort returns chronological order`() =
        runTest {
            val result = useCase.execute(sortOption = EntrySortOption.OLDEST).first()
            assertEquals(1L, result[0].entry.id) // 1000
            assertEquals(3L, result[1].entry.id) // 2000
            assertEquals(2L, result[2].entry.id) // 3000
        }

    @Test
    fun `favorites sort prioritizes favorited entries`() =
        runTest {
            val result = useCase.execute(sortOption = EntrySortOption.FAVORITES).first()
            assertTrue(result[0].entry.isFavorite)
            assertTrue(result[1].entry.isFavorite)
            assertEquals(false, result[2].entry.isFavorite)
        }

    @Test
    fun `filter by mood returns only matching entries`() =
        runTest {
            val result =
                useCase
                    .execute(
                        filterCriteria = EntryFilterCriteria(mood = Mood.HAPPY),
                    ).first()

            assertEquals(2, result.size)
            assertTrue(result.all { it.entry.mood == Mood.HAPPY })
        }

    @Test
    fun `filter by tag returns only tagged entries`() =
        runTest {
            val result =
                useCase
                    .execute(
                        filterCriteria = EntryFilterCriteria(tagId = tagTravel.id),
                    ).first()

            assertEquals(2, result.size)
            assertTrue(result.all { it.tags.any { t -> t.id == tagTravel.id } })
        }

    @Test
    fun `filter by only favorites`() =
        runTest {
            val result =
                useCase
                    .execute(
                        filterCriteria = EntryFilterCriteria(onlyFavorites = true),
                    ).first()

            assertEquals(2, result.size)
            assertTrue(result.all { it.entry.isFavorite })
        }

    @Test
    fun `filter by photo attachments`() =
        runTest {
            val result =
                useCase
                    .execute(
                        filterCriteria = EntryFilterCriteria(onlyWithPhotos = true),
                    ).first()

            assertEquals(1, result.size)
            assertEquals(2L, result.first().entry.id)
        }

    @Test
    fun `filter by audio attachments`() =
        runTest {
            val result =
                useCase
                    .execute(
                        filterCriteria = EntryFilterCriteria(onlyWithAudio = true),
                    ).first()

            assertEquals(1, result.size)
            assertEquals(3L, result.first().entry.id)
        }
}
