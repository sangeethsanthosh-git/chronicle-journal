package com.chronicle.journal.domain.usecase

import com.chronicle.journal.domain.repository.JournalRepository
import javax.inject.Inject

class DeleteEntryUseCase
    @Inject
    constructor(
        private val journalRepository: JournalRepository,
    ) {
        suspend fun execute(
            id: Long,
            permanent: Boolean = false,
        ) {
            journalRepository.deleteEntry(id, permanent)
        }
    }
