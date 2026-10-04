package com.chronicle.journal.domain.usecase

import com.chronicle.journal.domain.model.Attachment
import com.chronicle.journal.domain.model.JournalEntry
import com.chronicle.journal.domain.model.Tag
import com.chronicle.journal.domain.repository.JournalRepository
import javax.inject.Inject

class SaveEntryUseCase
    @Inject
    constructor(
        private val journalRepository: JournalRepository,
    ) {
        suspend fun execute(
            entry: JournalEntry,
            tags: List<Tag>,
            attachments: List<Attachment>,
            collectionIds: List<Long> = emptyList(),
        ): Long {
            require(entry.title.isNotBlank() || entry.content.isNotBlank()) {
                "Entry title or content cannot be empty"
            }
            val entryId = journalRepository.saveEntry(entry, tags, attachments, collectionIds)
            // Clear draft when successfully saved
            journalRepository.clearDraft()
            return entryId
        }
    }
