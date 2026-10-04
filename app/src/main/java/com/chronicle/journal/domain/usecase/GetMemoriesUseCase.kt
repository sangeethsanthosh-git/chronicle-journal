package com.chronicle.journal.domain.usecase

import com.chronicle.journal.core.common.TimeUtils
import com.chronicle.journal.domain.model.MemoryItem
import com.chronicle.journal.domain.repository.JournalRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import java.time.LocalDate
import javax.inject.Inject

class GetMemoriesUseCase
    @Inject
    constructor(
        private val journalRepository: JournalRepository,
    ) {
        fun execute(referenceDate: LocalDate = LocalDate.now()): Flow<List<MemoryItem>> =
            journalRepository.getAllEntries().map { allEntries ->
                val memories = mutableListOf<MemoryItem>()

                allEntries.forEach { details ->
                    val entryDate = TimeUtils.toLocalDate(details.entry.entryDate)
                    val yearsAgo = referenceDate.year - entryDate.year

                    if (yearsAgo > 0 && entryDate.month == referenceDate.month && entryDate.dayOfMonth == referenceDate.dayOfMonth) {
                        val formatted =
                            when (yearsAgo) {
                                1 -> "1 year ago today"
                                else -> "$yearsAgo years ago today"
                            }
                        memories.add(MemoryItem(details, yearsAgo, formatted))
                    }
                }

                // If no exact anniversary matches, surface a past favorite or notable memory as a nostalgic spotlight
                if (memories.isEmpty() && allEntries.isNotEmpty()) {
                    val pastFavorites =
                        allEntries.filter { details ->
                            val entryDate = TimeUtils.toLocalDate(details.entry.entryDate)
                            entryDate.isBefore(referenceDate.minusDays(7)) &&
                                (details.entry.isFavorite || details.photoAttachments.isNotEmpty())
                        }
                    val candidate =
                        pastFavorites.firstOrNull() ?: allEntries.lastOrNull {
                            TimeUtils.toLocalDate(it.entry.entryDate).isBefore(referenceDate)
                        }
                    if (candidate != null) {
                        val daysAgo =
                            java.time.temporal.ChronoUnit.DAYS.between(
                                TimeUtils.toLocalDate(candidate.entry.entryDate),
                                referenceDate,
                            )
                        val label =
                            when {
                                daysAgo >= 365 -> "${daysAgo / 365} year(s) ago"
                                daysAgo >= 30 -> "${daysAgo / 30} month(s) ago"
                                else -> "$daysAgo days ago"
                            }
                        memories.add(MemoryItem(candidate, (daysAgo / 365).toInt(), "Looking back $label"))
                    }
                }

                memories.sortedByDescending { it.yearsAgo }
            }
    }
