package com.chronicle.journal.domain.usecase

import com.chronicle.journal.domain.model.JournalWithDetails
import com.chronicle.journal.domain.model.Mood
import com.chronicle.journal.domain.repository.JournalRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject

enum class EntrySortOption(
    val displayName: String,
) {
    NEWEST("Newest First"),
    OLDEST("Oldest First"),
    FAVORITES("Favorites"),
    MOOD("By Mood"),
    RECENTLY_EDITED("Recently Edited"),
}

data class EntryFilterCriteria(
    val mood: Mood? = null,
    val tagId: Long? = null,
    val onlyFavorites: Boolean = false,
    val onlyWithPhotos: Boolean = false,
    val onlyWithAudio: Boolean = false,
)

class GetEntriesUseCase
    @Inject
    constructor(
        private val journalRepository: JournalRepository,
    ) {
        fun execute(
            sortOption: EntrySortOption = EntrySortOption.NEWEST,
            filterCriteria: EntryFilterCriteria = EntryFilterCriteria(),
        ): Flow<List<JournalWithDetails>> =
            journalRepository.getAllEntries().map { list ->
                // Apply filtering
                var filtered =
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

                // Apply sorting
                when (sortOption) {
                    EntrySortOption.NEWEST -> filtered.sortedByDescending { it.entry.entryDate }
                    EntrySortOption.OLDEST -> filtered.sortedBy { it.entry.entryDate }
                    EntrySortOption.FAVORITES ->
                        filtered.sortedWith(
                            compareByDescending<JournalWithDetails> { it.entry.isFavorite }
                                .thenByDescending { it.entry.entryDate },
                        )
                    EntrySortOption.MOOD -> filtered.sortedBy { it.entry.mood.name }
                    EntrySortOption.RECENTLY_EDITED -> filtered.sortedByDescending { it.entry.updatedAt }
                }
            }
    }
