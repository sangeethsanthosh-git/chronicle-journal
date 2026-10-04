package com.chronicle.journal.domain.model

data class Collection(
    val id: Long = 0,
    val name: String,
    val description: String? = null,
    val coverImageUri: String? = null,
    val createdAt: Long = System.currentTimeMillis(),
    val entryCount: Int = 0,
)
