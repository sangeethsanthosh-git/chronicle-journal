package com.chronicle.journal.domain.usecase

import com.chronicle.journal.domain.model.JournalWithDetails
import com.chronicle.journal.domain.repository.JournalRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject

class SearchEntriesUseCase
    @Inject
    constructor(
        private val journalRepository: JournalRepository,
    ) {
        fun execute(
            query: String,
            filterCriteria: EntryFilterCriteria = EntryFilterCriteria(),
        ): Flow<List<JournalWithDetails>> =
            journalRepository.searchEntries(query).map { list ->
                list.filter { details ->
                    var matches = true
                    if (filterCriteria.mood != null && details.entry.mood != filterCriteria.mood) {
                        matches = false
                    }
                    if (filterCriteria.tagId != null && details.tags.none { it.id == filterCriteria.tagId }) {
                        matches = false
                    }
                    if (filterCriteria.onlyFavorites && !details.entry.isFavorite) {
                        matches = false
                    }
                    if (filterCriteria.onlyWithPhotos && details.photoAttachments.isEmpty() && details.entry.coverImageUri == null) {
                        matches = false
                    }
                    if (filterCriteria.onlyWithAudio && details.audioAttachments.isEmpty()) {
                        matches = false
                    }
                    matches
                }
            }
    }
