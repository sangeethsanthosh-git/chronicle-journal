package com.chronicle.journal.data.local.dao

import android.content.Context
import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.chronicle.journal.data.local.database.ChronicleDatabase
import com.chronicle.journal.data.local.entities.JournalEntryEntity
import com.chronicle.journal.data.local.entities.JournalEntryTagCrossRef
import com.chronicle.journal.data.local.entities.TagEntity
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class JournalEntryDaoTest {
    private lateinit var database: ChronicleDatabase
    private lateinit var journalEntryDao: JournalEntryDao
    private lateinit var tagDao: TagDao

    @Before
    fun createDb() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        database =
            Room
                .inMemoryDatabaseBuilder(context, ChronicleDatabase::class.java)
                .allowMainThreadQueries()
                .build()
        journalEntryDao = database.journalEntryDao()
        tagDao = database.tagDao()
    }

    @After
    fun closeDb() {
        database.close()
    }

    @Test
    fun insertAndGetActiveEntry() =
        runBlocking {
            val entity =
                JournalEntryEntity(
                    id = 0,
                    title = "Testing DAO",
                    content = "Testing content",
                    createdAt = 1000L,
                    updatedAt = 1000L,
                    entryDate = 1000L,
                    mood = "HAPPY",
                    moodIntensity = 4,
                    isFavorite = false,
                )
            val id = journalEntryDao.insertEntry(entity)
            val fetched = journalEntryDao.getEntryByIdSync(id)

            assertNotNull(fetched)
            assertEquals("Testing DAO", fetched?.entry?.title)
            assertEquals("HAPPY", fetched?.entry?.mood)
        }

    @Test
    fun softDeleteHidesEntryFromActiveEntries() =
        runBlocking {
            val entity =
                JournalEntryEntity(
                    id = 0,
                    title = "To be deleted",
                    content = "Will vanish from active list",
                    createdAt = 2000L,
                    updatedAt = 2000L,
                    entryDate = 2000L,
                    mood = "CALM",
                )
            val id = journalEntryDao.insertEntry(entity)

            var activeEntries = journalEntryDao.getAllActiveEntries().first()
            assertEquals(1, activeEntries.size)

            journalEntryDao.softDeleteEntry(id, System.currentTimeMillis())

            activeEntries = journalEntryDao.getAllActiveEntries().first()
            assertEquals(0, activeEntries.size)
        }

    @Test
    fun searchEntriesFindsMatchesInTitleAndContent() =
        runBlocking {
            val entry1 =
                JournalEntryEntity(
                    id = 0,
                    title = "Kyoto Gardens",
                    content = "Peaceful morning walking by moss temples",
                    createdAt = 1000L,
                    updatedAt = 1000L,
                    entryDate = 1000L,
                )
            val entry2 =
                JournalEntryEntity(
                    id = 0,
                    title = "Tokyo Neon",
                    content = "Exciting dinner in Shinjuku",
                    createdAt = 2000L,
                    updatedAt = 2000L,
                    entryDate = 2000L,
                )
            journalEntryDao.insertEntry(entry1)
            journalEntryDao.insertEntry(entry2)

            val kyotoResults = journalEntryDao.searchEntries("Kyoto").first()
            assertEquals(1, kyotoResults.size)
            assertEquals("Kyoto Gardens", kyotoResults.first().entry.title)

            val dinnerResults = journalEntryDao.searchEntries("dinner").first()
            assertEquals(1, dinnerResults.size)
            assertEquals("Tokyo Neon", dinnerResults.first().entry.title)
        }

    @Test
    fun setFavoriteTogglesFavoriteState() =
        runBlocking {
            val entity =
                JournalEntryEntity(
                    id = 0,
                    title = "Favorite candidate",
                    content = "Star me",
                    createdAt = 1000L,
                    updatedAt = 1000L,
                    entryDate = 1000L,
                    isFavorite = false,
                )
            val id = journalEntryDao.insertEntry(entity)

            journalEntryDao.setFavorite(id, true)
            val favorites = journalEntryDao.getFavoriteEntries().first()

            assertEquals(1, favorites.size)
            assertTrue(favorites.first().entry.isFavorite)
        }

    @Test
    fun crossRefAssociatesTagsWithEntry() =
        runBlocking {
            val entryId =
                journalEntryDao.insertEntry(
                    JournalEntryEntity(
                        id = 0,
                        title = "Tagged Note",
                        content = "Has tags",
                        createdAt = 1000L,
                        updatedAt = 1000L,
                        entryDate = 1000L,
                    ),
                )
            val tagId = tagDao.insertTag(TagEntity(id = 0, name = "reflection", colorHex = "#123456"))

            journalEntryDao.insertEntryTagCrossRef(
                JournalEntryTagCrossRef(entryId = entryId, tagId = tagId),
            )

            val retrieved = journalEntryDao.getEntryById(entryId).first()
            assertNotNull(retrieved)
            assertEquals(1, retrieved?.tags?.size)
            assertEquals("reflection", retrieved?.tags?.first()?.name)
        }
}
