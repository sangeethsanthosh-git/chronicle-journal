package com.chronicle.journal.domain.repository

import com.chronicle.journal.data.local.entities.DraftEntity
import com.chronicle.journal.domain.model.Attachment
import com.chronicle.journal.domain.model.JournalEntry
import com.chronicle.journal.domain.model.JournalWithDetails
import com.chronicle.journal.domain.model.Tag
import kotlinx.coroutines.flow.Flow

interface JournalRepository {
    fun getAllEntries(): Flow<List<JournalWithDetails>>

    fun getEntryById(id: Long): Flow<JournalWithDetails?>

    suspend fun getEntryByIdSync(id: Long): JournalWithDetails?

    fun getFavoriteEntries(): Flow<List<JournalWithDetails>>

    fun getEntriesByDateRange(
        startDate: Long,
        endDate: Long,
    ): Flow<List<JournalWithDetails>>

    fun getEntriesForDay(
        startOfDay: Long,
        endOfDay: Long,
    ): Flow<List<JournalWithDetails>>

    fun searchEntries(query: String): Flow<List<JournalWithDetails>>

    suspend fun saveEntry(
        entry: JournalEntry,
        tags: List<Tag>,
        attachments: List<Attachment>,
        collectionIds: List<Long> = emptyList(),
    ): Long

    suspend fun deleteEntry(
        id: Long,
        permanent: Boolean = false,
    )

    suspend fun toggleFavorite(
        id: Long,
        isFavorite: Boolean,
    )

    fun getAllTags(): Flow<List<Tag>>

    suspend fun getOrCreateTag(
        name: String,
        colorHex: String? = null,
    ): Tag

    suspend fun deleteAttachment(attachment: Attachment)

    fun getDraft(): Flow<DraftEntity?>

    suspend fun saveDraft(draft: DraftEntity)

    suspend fun clearDraft()

    fun getTotalEntriesCount(): Flow<Int>

    suspend fun getEntriesCountBetween(
        start: Long,
        end: Long,
    ): Int

    suspend fun getAllEntryDates(): List<Long>

    suspend fun getTotalPhotosCount(): Int

    suspend fun getTotalAudioCount(): Int
}
