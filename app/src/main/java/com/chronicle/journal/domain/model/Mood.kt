package com.chronicle.journal.domain.model

enum class Mood(
    val displayName: String,
    val emoji: String,
    val lightColorHex: String,
    val darkColorHex: String,
    val prompt: String,
) {
    HAPPY(
        displayName = "Happy",
        emoji = "✨",
        lightColorHex = "#E8B86D",
        darkColorHex = "#D49E4F",
        prompt = "What made you smile today?",
    ),
    CALM(
        displayName = "Calm",
        emoji = "🌿",
        lightColorHex = "#98A886",
        darkColorHex = "#7A8C6A",
        prompt = "Where did you find stillness?",
    ),
    EXCITED(
        displayName = "Excited",
        emoji = "⚡",
        lightColorHex = "#DF7A5E",
        darkColorHex = "#C46349",
        prompt = "What is fueling your anticipation?",
    ),
    GRATEFUL(
        displayName = "Grateful",
        emoji = "🕊️",
        lightColorHex = "#B8A2CD",
        darkColorHex = "#9C83B4",
        prompt = "What are three things you appreciate?",
    ),
    NEUTRAL(
        displayName = "Neutral",
        emoji = "☁️",
        lightColorHex = "#A3A79E",
        darkColorHex = "#83877F",
        prompt = "How was the steady rhythm of your day?",
    ),
    SAD(
        displayName = "Sad",
        emoji = "🌧️",
        lightColorHex = "#8EAEC2",
        darkColorHex = "#6E8F9F",
        prompt = "What feels heavy right now?",
    ),
    ANGRY(
        displayName = "Angry",
        emoji = "🔥",
        lightColorHex = "#CC6B68",
        darkColorHex = "#AD4D4C",
        prompt = "What crossed your boundaries today?",
    ),
    ANXIOUS(
        displayName = "Anxious",
        emoji = "🍂",
        lightColorHex = "#C99E75",
        darkColorHex = "#A87E56",
        prompt = "What is worrying your thoughts?",
    ),
    TIRED(
        displayName = "Tired",
        emoji = "🌙",
        lightColorHex = "#8F9CA8",
        darkColorHex = "#727F8B",
        prompt = "How can you rest and recharge?",
    ),
    LOVED(
        displayName = "Loved",
        emoji = "🌸",
        lightColorHex = "#DE95A0",
        darkColorHex = "#C37682",
        prompt = "Who warmed your heart today?",
    ),
    ;

    companion object {
        fun fromString(value: String?): Mood = entries.firstOrNull { it.name.equals(value, ignoreCase = true) } ?: NEUTRAL
    }
}
