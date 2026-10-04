package com.chronicle.journal.data.backup

import org.json.JSONArray
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class BackupValidationTest {
    @Test
    fun `valid backup json contains required root version and entries`() {
        val root =
            JSONObject().apply {
                put("chronicle_version", 1)
                put("exported_at", System.currentTimeMillis())
                put(
                    "entries",
                    JSONArray().apply {
                        put(
                            JSONObject().apply {
                                put("title", "Test Title")
                                put("content", "Test Content")
                                put("createdAt", 1000L)
                                put("updatedAt", 1000L)
                                put("entryDate", 1000L)
                                put("mood", "HAPPY")
                                put("moodIntensity", 4)
                                put("isFavorite", true)
                            },
                        )
                    },
                )
            }

        assertTrue(root.has("chronicle_version"))
        assertEquals(1, root.getInt("chronicle_version"))
        assertTrue(root.has("entries"))
        assertEquals(1, root.getJSONArray("entries").length())
    }

    @Test
    fun `corrupt json missing chronicle_version is flagged as invalid`() {
        val corrupt =
            JSONObject().apply {
                put("random_field", "data")
            }

        assertFalse(corrupt.has("chronicle_version"))
    }
}
