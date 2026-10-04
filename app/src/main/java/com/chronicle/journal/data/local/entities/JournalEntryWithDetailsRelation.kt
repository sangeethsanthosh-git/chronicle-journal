package com.chronicle.journal.data.local.entities

import androidx.room.Embedded
import androidx.room.Junction
import androidx.room.Relation
import com.chronicle.journal.domain.model.JournalWithDetails

data class JournalEntryWithDetailsRelation(
    @Embedded
    val entry: JournalEntryEntity,
    @Relation(
        parentColumn = "id",
        entityColumn = "journalEntryId",
    )
    val attachments: List<AttachmentEntity> = emptyList(),
    @Relation(
        parentColumn = "id",
        entityColumn = "id",
        associateBy =
            Junction(
                value = JournalEntryTagCrossRef::class,
                parentColumn = "entryId",
                entityColumn = "tagId",
            ),
    )
    val tags: List<TagEntity> = emptyList(),
    @Relation(
        parentColumn = "id",
        entityColumn = "id",
        associateBy =
            Junction(
                value = CollectionEntryCrossRef::class,
                parentColumn = "entryId",
                entityColumn = "collectionId",
            ),
    )
    val collections: List<CollectionEntity> = emptyList(),
) {
    fun toDomain(): JournalWithDetails =
        JournalWithDetails(
            entry = entry.toDomain(),
            tags = tags.map { it.toDomain() },
            attachments = attachments.map { it.toDomain() },
            collections = collections.map { it.toDomain() },
        )
}
