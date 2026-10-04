package com.chronicle.journal.core.utils

import java.security.MessageDigest

object SecurityUtils {
    fun hashPin(pin: String): String {
        val digest = MessageDigest.getInstance("SHA-256")
        val hashBytes = digest.digest(pin.toByteArray(Charsets.UTF_8))
        return hashBytes.joinToString("") { "%02x".format(it) }
    }

    fun verifyPin(
        pin: String,
        expectedHash: String?,
    ): Boolean {
        if (expectedHash == null) return false
        return hashPin(pin) == expectedHash
    }
}
