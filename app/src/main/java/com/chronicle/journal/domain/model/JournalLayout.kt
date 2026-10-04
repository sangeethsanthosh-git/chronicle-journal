package com.chronicle.journal.domain.model

enum class JournalLayout(
    val displayName: String,
    val description: String,
) {
    CLASSIC("Classic Diary", "Timeless book style with editorial typography"),
    SCRAPBOOK("Scrapbook", "Polaroid cards, washi tape & memory clippings"),
    POSTCARD("Postcard", "Vintage postal stamp, postmark & photo view"),
    MINIMAL("Minimal", "Clean, distilled focus on your writing"),
    PHOTO_DIARY("Photo Story", "Bold hero photography with captioned note"),
    ;

    companion object {
        fun fromString(value: String?): JournalLayout = entries.firstOrNull { it.name.equals(value, ignoreCase = true) } ?: CLASSIC
    }
}
