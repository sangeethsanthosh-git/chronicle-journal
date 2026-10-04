package com.chronicle.journal.domain.model

data class JournalEntry(
    val id: Long = 0,
    val title: String,
    val content: String,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis(),
    val entryDate: Long = System.currentTimeMillis(),
    val mood: Mood = Mood.NEUTRAL,
    val moodIntensity: Int = 3,
    val isFavorite: Boolean = false,
    val locationName: String? = null,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val weatherSummary: String? = null,
    val weatherTemperature: Float? = null,
    val weatherIcon: String? = null,
    val coverImageUri: String? = null,
    val createdFromTemplate: String? = null,
    val archived: Boolean = false,
    val deletedAt: Long? = null,
    val layoutStyle: JournalLayout = JournalLayout.CLASSIC,
)

data class JournalWithDetails(
    val entry: JournalEntry,
    val tags: List<Tag> = emptyList(),
    val attachments: List<Attachment> = emptyList(),
    val collections: List<Collection> = emptyList(),
) {
    val photoAttachments: List<Attachment>
        get() = attachments.filter { it.type == AttachmentType.PHOTO }

    val audioAttachments: List<Attachment>
        get() = attachments.filter { it.type == AttachmentType.AUDIO }

    val primaryImageUri: String?
        get() = entry.coverImageUri ?: photoAttachments.firstOrNull()?.uri
}
