package com.chronicle.journal.data.local.database

import androidx.room.Database
import androidx.room.RoomDatabase
import com.chronicle.journal.data.local.dao.AttachmentDao
import com.chronicle.journal.data.local.dao.CollectionDao
import com.chronicle.journal.data.local.dao.JournalEntryDao
import com.chronicle.journal.data.local.dao.TagDao
import com.chronicle.journal.data.local.entities.AttachmentEntity
import com.chronicle.journal.data.local.entities.CollectionEntity
import com.chronicle.journal.data.local.entities.CollectionEntryCrossRef
import com.chronicle.journal.data.local.entities.DraftEntity
import com.chronicle.journal.data.local.entities.JournalEntryEntity
import com.chronicle.journal.data.local.entities.JournalEntryTagCrossRef
import com.chronicle.journal.data.local.entities.TagEntity

@Database(
    entities = [
        JournalEntryEntity::class,
        TagEntity::class,
        JournalEntryTagCrossRef::class,
        AttachmentEntity::class,
        CollectionEntity::class,
        CollectionEntryCrossRef::class,
        DraftEntity::class,
    ],
    version = 1,
    exportSchema = false,
)
abstract class ChronicleDatabase : RoomDatabase() {
    abstract fun journalEntryDao(): JournalEntryDao

    abstract fun tagDao(): TagDao

    abstract fun attachmentDao(): AttachmentDao

    abstract fun collectionDao(): CollectionDao

    companion object {
        const val DATABASE_NAME = "chronicle_journal.db"
    }
}
