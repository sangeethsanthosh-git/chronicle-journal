package com.chronicle.journal.data.local.entities

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import com.chronicle.journal.domain.model.Collection

@Entity(
    tableName = "collections",
    indices = [Index(value = ["name"])],
)
data class CollectionEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val name: String,
    val description: String? = null,
    val coverImageUri: String? = null,
    val createdAt: Long = System.currentTimeMillis(),
) {
    fun toDomain(entryCount: Int = 0): Collection =
        Collection(
            id = id,
            name = name,
            description = description,
            coverImageUri = coverImageUri,
            createdAt = createdAt,
            entryCount = entryCount,
        )

    companion object {
        fun fromDomain(collection: Collection): CollectionEntity =
            CollectionEntity(
                id = collection.id,
                name = collection.name,
                description = collection.description,
                coverImageUri = collection.coverImageUri,
                createdAt = collection.createdAt,
            )
    }
}
