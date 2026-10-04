package com.chronicle.journal.domain.usecase

import com.chronicle.journal.domain.model.Attachment
import com.chronicle.journal.domain.model.AttachmentType
import com.chronicle.journal.domain.model.JournalEntry
import com.chronicle.journal.domain.model.Mood
import com.chronicle.journal.domain.model.Tag
import com.chronicle.journal.testutil.FakeJournalRepository
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test

class GetStatisticsUseCaseTest {
    private lateinit var repository: FakeJournalRepository
    private lateinit var streakUseCase: CalculateStreakUseCase
    private lateinit var statisticsUseCase: GetStatisticsUseCase

    @Before
    fun setUp() =
        runTest {
            repository = FakeJournalRepository()
            streakUseCase = CalculateStreakUseCase()
            statisticsUseCase = GetStatisticsUseCase(repository, streakUseCase)

            val tagArt = Tag(1, "art")
            val tagNature = Tag(2, "nature")

            repository.saveEntry(
                JournalEntry(
                    id = 1,
                    title = "Painting flowers",
                    content = "Today I painted twenty beautiful vibrant yellow flowers in the garden.",
                    entryDate = System.currentTimeMillis(),
                    mood = Mood.HAPPY,
                ),
                listOf(tagArt, tagNature),
                listOf(Attachment(1, uri = "img1.png", type = AttachmentType.PHOTO)),
            )

            repository.saveEntry(
                JournalEntry(
                    id = 2,
                    title = "Forest hike",
                    content = "Walked through the tall pine forest beside the quiet river.",
                    entryDate = System.currentTimeMillis(),
                    mood = Mood.HAPPY,
                ),
                listOf(tagNature),
                listOf(Attachment(2, uri = "voice.m4a", type = AttachmentType.AUDIO)),
            )

            repository.saveEntry(
                JournalEntry(
                    id = 3,
                    title = "Tired evening",
                    content = "Long hours at work today. Need good sleep.",
                    entryDate = System.currentTimeMillis() - 86400000,
                    mood = Mood.TIRED,
                ),
                emptyList(),
                emptyList(),
            )
        }

    @Test
    fun `calculates statistics accurately from real repository data`() =
        runTest {
            val stats = statisticsUseCase.execute()

            assertEquals(3, stats.totalEntries)
            assertEquals(Mood.HAPPY, stats.mostCommonMood)
            assertEquals(2, stats.moodDistribution[Mood.HAPPY])
            assertEquals(1, stats.moodDistribution[Mood.TIRED])
            assertEquals(1, stats.totalPhotosCount)
            assertEquals(1, stats.totalAudioCount)
            // Check top tag is 'nature' with count 2
            assertEquals(
                "nature",
                stats.topTags
                    .first()
                    .first.name,
            )
            assertEquals(2, stats.topTags.first().second)
        }
}
