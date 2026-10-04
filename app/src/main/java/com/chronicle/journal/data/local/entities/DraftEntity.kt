package com.chronicle.journal.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "journal_drafts")
data class DraftEntity(
    @PrimaryKey
    val id: Long = 1L,
    val editingEntryId: Long? = null,
    val title: String = "",
    val content: String = "",
    val mood: String = "NEUTRAL",
    val moodIntensity: Int = 3,
    val entryDate: Long = System.currentTimeMillis(),
    val layoutStyle: String = "CLASSIC",
    val coverImageUri: String? = null,
    val locationName: String? = null,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val weatherSummary: String? = null,
    val weatherTemperature: Float? = null,
    val tagNamesCsv: String = "",
    val attachmentUrisCsv: String = "",
    val updatedAt: Long = System.currentTimeMillis(),
)
