package com.chronicle.journal.core.utils

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class SecurityUtilsTest {
    @Test
    fun `hashPin generates consistent SHA-256 hash`() {
        val pin = "1234"
        val hash1 = SecurityUtils.hashPin(pin)
        val hash2 = SecurityUtils.hashPin(pin)

        assertEquals(64, hash1.length)
        assertEquals(hash1, hash2)
    }

    @Test
    fun `different PINs produce different hashes`() {
        val hash1 = SecurityUtils.hashPin("1234")
        val hash2 = SecurityUtils.hashPin("4321")

        assertNotEquals(hash1, hash2)
    }

    @Test
    fun `verifyPin returns true for matching PIN and expected hash`() {
        val pin = "9876"
        val hash = SecurityUtils.hashPin(pin)

        assertTrue(SecurityUtils.verifyPin(pin, hash))
    }

    @Test
    fun `verifyPin returns false for wrong PIN or null hash`() {
        val pin = "9876"
        val hash = SecurityUtils.hashPin(pin)

        assertFalse(SecurityUtils.verifyPin("0000", hash))
        assertFalse(SecurityUtils.verifyPin(pin, null))
    }
}
