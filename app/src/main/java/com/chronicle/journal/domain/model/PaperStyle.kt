package com.chronicle.journal.domain.model

enum class PaperStyle(
    val displayName: String,
) {
    PLAIN("Parchment Plain"),
    RULED("Ruled Journal"),
    GRID("Dot-Grid Notebook"),
    VINTAGE_WARM("Aged Vintage"),
    ;

    companion object {
        fun fromString(value: String?): PaperStyle = entries.firstOrNull { it.name.equals(value, ignoreCase = true) } ?: PLAIN
    }
}
