package com.chronicle.journal.domain.model

data class Tag(
    val id: Long = 0,
    val name: String,
    val colorHex: String = "#8C7355",
)
