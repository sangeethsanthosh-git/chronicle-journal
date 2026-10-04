package com.chronicle.journal.domain.usecase

import com.chronicle.journal.domain.model.JournalWithDetails
import com.chronicle.journal.domain.repository.JournalRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

class GetEntryByIdUseCase
    @Inject
    constructor(
        private val journalRepository: JournalRepository,
    ) {
        fun execute(id: Long): Flow<JournalWithDetails?> = journalRepository.getEntryById(id)

        suspend fun executeSync(id: Long): JournalWithDetails? = journalRepository.getEntryByIdSync(id)
    }
