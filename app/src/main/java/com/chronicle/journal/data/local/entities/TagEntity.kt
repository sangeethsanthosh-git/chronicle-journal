package com.chronicle.journal.data.local.entities

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import com.chronicle.journal.domain.model.Tag

@Entity(
    tableName = "tags",
    indices = [Index(value = ["name"], unique = true)],
)
data class TagEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val name: String,
    val colorHex: String,
) {
    fun toDomain(): Tag = Tag(id = id, name = name, colorHex = colorHex)

    companion object {
        fun fromDomain(tag: Tag): TagEntity =
            TagEntity(
                id = tag.id,
                name = tag.name,
                colorHex = tag.colorHex,
            )
    }
}
