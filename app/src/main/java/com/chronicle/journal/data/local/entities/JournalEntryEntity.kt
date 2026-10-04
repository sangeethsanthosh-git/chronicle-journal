package com.chronicle.journal.data.local.entities

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import com.chronicle.journal.domain.model.JournalEntry
import com.chronicle.journal.domain.model.JournalLayout
import com.chronicle.journal.domain.model.Mood

@Entity(
    tableName = "journal_entries",
    indices = [
        Index(value = ["entryDate"]),
        Index(value = ["createdAt"]),
        Index(value = ["mood"]),
        Index(value = ["isFavorite"]),
        Index(value = ["archived"]),
        Index(value = ["deletedAt"]),
    ],
)
data class JournalEntryEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val title: String,
    val content: String,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis(),
    val entryDate: Long = System.currentTimeMillis(),
    val mood: String = "NEUTRAL",
    val moodIntensity: Int = 3,
    val isFavorite: Boolean = false,
    val locationName: String? = null,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val weatherSummary: String? = null,
    val weatherTemperature: Float? = null,
    val weatherIcon: String? = null,
    val coverImageUri: String? = null,
    val createdFromTemplate: String? = null,
    val archived: Boolean = false,
    val deletedAt: Long? = null,
    val layoutStyle: String = JournalLayout.CLASSIC.name,
) {
    fun toDomain(): JournalEntry =
        JournalEntry(
            id = id,
            title = title,
            content = content,
            createdAt = createdAt,
            updatedAt = updatedAt,
            entryDate = entryDate,
            mood = Mood.fromString(mood),
            moodIntensity = moodIntensity,
            isFavorite = isFavorite,
            locationName = locationName,
            latitude = latitude,
            longitude = longitude,
            weatherSummary = weatherSummary,
            weatherTemperature = weatherTemperature,
            weatherIcon = weatherIcon,
            coverImageUri = coverImageUri,
            createdFromTemplate = createdFromTemplate,
            archived = archived,
            deletedAt = deletedAt,
            layoutStyle = JournalLayout.fromString(layoutStyle),
        )

    companion object {
        fun fromDomain(entry: JournalEntry): JournalEntryEntity =
            JournalEntryEntity(
                id = entry.id,
                title = entry.title,
                content = entry.content,
                createdAt = entry.createdAt,
                updatedAt = entry.updatedAt,
                entryDate = entry.entryDate,
                mood = entry.mood.name,
                moodIntensity = entry.moodIntensity,
                isFavorite = entry.isFavorite,
                locationName = entry.locationName,
                latitude = entry.latitude,
                longitude = entry.longitude,
                weatherSummary = entry.weatherSummary,
                weatherTemperature = entry.weatherTemperature,
                weatherIcon = entry.weatherIcon,
                coverImageUri = entry.coverImageUri,
                createdFromTemplate = entry.createdFromTemplate,
                archived = entry.archived,
                deletedAt = entry.deletedAt,
                layoutStyle = entry.layoutStyle.name,
            )
    }
}
