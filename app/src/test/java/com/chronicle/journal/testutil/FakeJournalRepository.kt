package com.chronicle.journal.testutil

import com.chronicle.journal.data.local.entities.DraftEntity
import com.chronicle.journal.domain.model.Attachment
import com.chronicle.journal.domain.model.JournalEntry
import com.chronicle.journal.domain.model.JournalWithDetails
import com.chronicle.journal.domain.model.Tag
import com.chronicle.journal.domain.repository.JournalRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.map

class FakeJournalRepository : JournalRepository {
    val entriesFlow = MutableStateFlow<List<JournalWithDetails>>(emptyList())
    val tagsFlow = MutableStateFlow<List<Tag>>(emptyList())
    val draftFlow = MutableStateFlow<DraftEntity?>(null)

    private var currentId = 1L
    private var tagIdCounter = 1L

    override fun getAllEntries(): Flow<List<JournalWithDetails>> = entriesFlow

    override fun getEntryById(id: Long): Flow<JournalWithDetails?> = entriesFlow.map { list -> list.firstOrNull { it.entry.id == id } }

    override suspend fun getEntryByIdSync(id: Long): JournalWithDetails? = entriesFlow.value.firstOrNull { it.entry.id == id }

    override fun getFavoriteEntries(): Flow<List<JournalWithDetails>> = entriesFlow.map { list -> list.filter { it.entry.isFavorite } }

    override fun getEntriesByDateRange(
        startDate: Long,
        endDate: Long,
    ): Flow<List<JournalWithDetails>> =
        entriesFlow.map { list ->
            list.filter { it.entry.entryDate in startDate..endDate }
        }

    override fun getEntriesForDay(
        startOfDay: Long,
        endOfDay: Long,
    ): Flow<List<JournalWithDetails>> =
        entriesFlow.map { list ->
            list.filter { it.entry.entryDate in startOfDay..endOfDay }
        }

    override fun searchEntries(query: String): Flow<List<JournalWithDetails>> =
        entriesFlow.map { list ->
            list.filter {
                it.entry.title.contains(query, ignoreCase = true) ||
                    it.entry.content.contains(query, ignoreCase = true) ||
                    it.tags.any { tag -> tag.name.contains(query, ignoreCase = true) }
            }
        }

    override suspend fun saveEntry(
        entry: JournalEntry,
        tags: List<Tag>,
        attachments: List<Attachment>,
        collectionIds: List<Long>,
    ): Long {
        val entryId = if (entry.id == 0L) currentId++ else entry.id
        val resolvedEntry = entry.copy(id = entryId)
        val details =
            JournalWithDetails(
                entry = resolvedEntry,
                tags = tags,
                attachments = attachments,
            )
        val currentList = entriesFlow.value.toMutableList()
        val index = currentList.indexOfFirst { it.entry.id == entryId }
        if (index >= 0) {
            currentList[index] = details
        } else {
            currentList.add(details)
        }
        entriesFlow.value = currentList
        return entryId
    }

    override suspend fun deleteEntry(
        id: Long,
        permanent: Boolean,
    ) {
        entriesFlow.value = entriesFlow.value.filterNot { it.entry.id == id }
    }

    override suspend fun toggleFavorite(
        id: Long,
        isFavorite: Boolean,
    ) {
        val currentList = entriesFlow.value.toMutableList()
        val index = currentList.indexOfFirst { it.entry.id == id }
        if (index >= 0) {
            val updated =
                currentList[index].copy(
                    entry = currentList[index].entry.copy(isFavorite = isFavorite),
                )
            currentList[index] = updated
            entriesFlow.value = currentList
        }
    }

    override fun getAllTags(): Flow<List<Tag>> = tagsFlow

    override suspend fun getOrCreateTag(
        name: String,
        colorHex: String?,
    ): Tag {
        val existing = tagsFlow.value.firstOrNull { it.name.equals(name, ignoreCase = true) }
        if (existing != null) return existing
        val newTag = Tag(id = tagIdCounter++, name = name, colorHex = colorHex ?: "#8C7355")
        tagsFlow.value = tagsFlow.value + newTag
        return newTag
    }

    override suspend fun deleteAttachment(attachment: Attachment) {
        // No-op for fake
    }

    override fun getDraft(): Flow<DraftEntity?> = draftFlow

    override suspend fun saveDraft(draft: DraftEntity) {
        draftFlow.value = draft
    }

    override suspend fun clearDraft() {
        draftFlow.value = null
    }

    override fun getTotalEntriesCount(): Flow<Int> = entriesFlow.map { it.size }

    override suspend fun getEntriesCountBetween(
        start: Long,
        end: Long,
    ): Int = entriesFlow.value.count { it.entry.entryDate in start..end }

    override suspend fun getAllEntryDates(): List<Long> = entriesFlow.value.map { it.entry.entryDate }

    override suspend fun getTotalPhotosCount(): Int = entriesFlow.value.sumOf { it.photoAttachments.size }

    override suspend fun getTotalAudioCount(): Int = entriesFlow.value.sumOf { it.audioAttachments.size }
}
