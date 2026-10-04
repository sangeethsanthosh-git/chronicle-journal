package com.chronicle.journal.data.repository

import com.chronicle.journal.data.local.dao.AttachmentDao
import com.chronicle.journal.data.local.dao.CollectionDao
import com.chronicle.journal.data.local.dao.JournalEntryDao
import com.chronicle.journal.data.local.dao.TagDao
import com.chronicle.journal.data.local.entities.AttachmentEntity
import com.chronicle.journal.data.local.entities.CollectionEntryCrossRef
import com.chronicle.journal.data.local.entities.DraftEntity
import com.chronicle.journal.data.local.entities.JournalEntryEntity
import com.chronicle.journal.data.local.entities.JournalEntryTagCrossRef
import com.chronicle.journal.data.local.entities.TagEntity
import com.chronicle.journal.domain.model.Attachment
import com.chronicle.journal.domain.model.JournalEntry
import com.chronicle.journal.domain.model.JournalWithDetails
import com.chronicle.journal.domain.model.Tag
import com.chronicle.journal.domain.repository.JournalRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class JournalRepositoryImpl
    @Inject
    constructor(
        private val journalEntryDao: JournalEntryDao,
        private val tagDao: TagDao,
        private val attachmentDao: AttachmentDao,
        private val collectionDao: CollectionDao,
    ) : JournalRepository {
        override fun getAllEntries(): Flow<List<JournalWithDetails>> =
            journalEntryDao.getAllActiveEntries().map { relations ->
                relations.map { it.toDomain() }
            }

        override fun getEntryById(id: Long): Flow<JournalWithDetails?> = journalEntryDao.getEntryById(id).map { it?.toDomain() }

        override suspend fun getEntryByIdSync(id: Long): JournalWithDetails? = journalEntryDao.getEntryByIdSync(id)?.toDomain()

        override fun getFavoriteEntries(): Flow<List<JournalWithDetails>> =
            journalEntryDao.getFavoriteEntries().map { relations ->
                relations.map { it.toDomain() }
            }

        override fun getEntriesByDateRange(
            startDate: Long,
            endDate: Long,
        ): Flow<List<JournalWithDetails>> =
            journalEntryDao.getEntriesByDateRange(startDate, endDate).map { relations ->
                relations.map { it.toDomain() }
            }

        override fun getEntriesForDay(
            startOfDay: Long,
            endOfDay: Long,
        ): Flow<List<JournalWithDetails>> =
            journalEntryDao.getEntriesForDay(startOfDay, endOfDay).map { relations ->
                relations.map { it.toDomain() }
            }

        override fun searchEntries(query: String): Flow<List<JournalWithDetails>> =
            journalEntryDao.searchEntries(query.trim()).map { relations ->
                relations.map { it.toDomain() }
            }

        override suspend fun saveEntry(
            entry: JournalEntry,
            tags: List<Tag>,
            attachments: List<Attachment>,
            collectionIds: List<Long>,
        ): Long {
            val entryEntity = JournalEntryEntity.fromDomain(entry)
            val entryId =
                if (entry.id == 0L) {
                    journalEntryDao.insertEntry(entryEntity)
                } else {
                    journalEntryDao.updateEntry(entryEntity)
                    entry.id
                }

            // Handle tags
            journalEntryDao.deleteTagsForEntry(entryId)
            tags.forEach { tag ->
                val resolvedTag = getOrCreateTag(tag.name, tag.colorHex)
                journalEntryDao.insertEntryTagCrossRef(
                    JournalEntryTagCrossRef(entryId = entryId, tagId = resolvedTag.id),
                )
            }

            // Handle attachments
            attachments.forEach { attachment ->
                val attachmentEntity =
                    AttachmentEntity.fromDomain(
                        attachment.copy(journalEntryId = entryId),
                    )
                attachmentDao.insertAttachment(attachmentEntity)
            }

            // Handle collections
            collectionIds.forEach { collectionId ->
                collectionDao.addEntryToCollection(
                    CollectionEntryCrossRef(collectionId = collectionId, entryId = entryId),
                )
            }

            return entryId
        }

        override suspend fun deleteEntry(
            id: Long,
            permanent: Boolean,
        ) {
            if (permanent) {
                journalEntryDao.hardDeleteEntry(id)
            } else {
                journalEntryDao.softDeleteEntry(id)
            }
        }

        override suspend fun toggleFavorite(
            id: Long,
            isFavorite: Boolean,
        ) {
            journalEntryDao.setFavorite(id, isFavorite)
        }

        override fun getAllTags(): Flow<List<Tag>> = tagDao.getAllTags().map { list -> list.map { it.toDomain() } }

        override suspend fun getOrCreateTag(
            name: String,
            colorHex: String?,
        ): Tag {
            val trimmed = name.trim().lowercase()
            val existing = tagDao.getTagByName(trimmed)
            if (existing != null) {
                return existing.toDomain()
            }
            val newTagEntity =
                TagEntity(
                    name = trimmed,
                    colorHex = colorHex ?: "#8C7355",
                )
            val newId = tagDao.insertTag(newTagEntity)
            return Tag(id = newId, name = trimmed, colorHex = newTagEntity.colorHex)
        }

        override suspend fun deleteAttachment(attachment: Attachment) {
            attachmentDao.deleteAttachment(AttachmentEntity.fromDomain(attachment))
        }

        override fun getDraft(): Flow<DraftEntity?> = journalEntryDao.getDraft()

        override suspend fun saveDraft(draft: DraftEntity) {
            journalEntryDao.insertDraft(draft)
        }

        override suspend fun clearDraft() {
            journalEntryDao.clearDraft()
        }

        override fun getTotalEntriesCount(): Flow<Int> = journalEntryDao.getTotalEntriesCount()

        override suspend fun getEntriesCountBetween(
            start: Long,
            end: Long,
        ): Int = journalEntryDao.getEntriesCountBetween(start, end)

        override suspend fun getAllEntryDates(): List<Long> = journalEntryDao.getAllEntryDates()

        override suspend fun getTotalPhotosCount(): Int = attachmentDao.getTotalPhotosCount()

        override suspend fun getTotalAudioCount(): Int = attachmentDao.getTotalAudioCount()
    }
