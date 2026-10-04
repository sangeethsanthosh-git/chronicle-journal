package com.chronicle.journal.core.common

sealed interface ChronicleResult<out T> {
    data class Success<T>(
        val data: T,
    ) : ChronicleResult<T>

    data class Error(
        val exception: Throwable,
        val message: String = exception.localizedMessage ?: "Unknown error",
    ) : ChronicleResult<Nothing>

    data object Loading : ChronicleResult<Nothing>
}
