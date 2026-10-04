package com.chronicle.journal.domain.model

enum class AttachmentType {
    PHOTO,
    AUDIO,
    ;

    companion object {
        fun fromString(value: String?): AttachmentType = entries.firstOrNull { it.name.equals(value, ignoreCase = true) } ?: PHOTO
    }
}

data class Attachment(
    val id: Long = 0,
    val journalEntryId: Long = 0,
    val uri: String,
    val type: AttachmentType,
    val caption: String? = null,
    val durationMs: Long? = null,
    val createdAt: Long = System.currentTimeMillis(),
)
