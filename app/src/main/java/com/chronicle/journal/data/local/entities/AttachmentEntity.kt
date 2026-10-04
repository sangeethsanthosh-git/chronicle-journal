package com.chronicle.journal.data.local.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import com.chronicle.journal.domain.model.Attachment
import com.chronicle.journal.domain.model.AttachmentType

@Entity(
    tableName = "attachments",
    foreignKeys = [
        ForeignKey(
            entity = JournalEntryEntity::class,
            parentColumns = ["id"],
            childColumns = ["journalEntryId"],
            onDelete = ForeignKey.CASCADE,
        ),
    ],
    indices = [
        Index(value = ["journalEntryId"]),
        Index(value = ["type"]),
    ],
)
data class AttachmentEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val journalEntryId: Long,
    val uri: String,
    val type: String,
    val caption: String? = null,
    val durationMs: Long? = null,
    val createdAt: Long = System.currentTimeMillis(),
) {
    fun toDomain(): Attachment =
        Attachment(
            id = id,
            journalEntryId = journalEntryId,
            uri = uri,
            type = AttachmentType.fromString(type),
            caption = caption,
            durationMs = durationMs,
            createdAt = createdAt,
        )

    companion object {
        fun fromDomain(attachment: Attachment): AttachmentEntity =
            AttachmentEntity(
                id = attachment.id,
                journalEntryId = attachment.journalEntryId,
                uri = attachment.uri,
                type = attachment.type.name,
                caption = attachment.caption,
                durationMs = attachment.durationMs,
                createdAt = attachment.createdAt,
            )
    }
}
