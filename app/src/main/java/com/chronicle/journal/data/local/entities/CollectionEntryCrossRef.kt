package com.chronicle.journal.data.local.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index

@Entity(
    tableName = "collection_entry_cross_ref",
    primaryKeys = ["collectionId", "entryId"],
    foreignKeys = [
        ForeignKey(
            entity = CollectionEntity::class,
            parentColumns = ["id"],
            childColumns = ["collectionId"],
            onDelete = ForeignKey.CASCADE,
        ),
        ForeignKey(
            entity = JournalEntryEntity::class,
            parentColumns = ["id"],
            childColumns = ["entryId"],
            onDelete = ForeignKey.CASCADE,
        ),
    ],
    indices = [
        Index(value = ["collectionId"]),
        Index(value = ["entryId"]),
    ],
)
data class CollectionEntryCrossRef(
    val collectionId: Long,
    val entryId: Long,
)
