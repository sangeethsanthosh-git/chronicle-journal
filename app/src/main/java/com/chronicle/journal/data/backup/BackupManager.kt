package com.chronicle.journal.data.backup

import android.content.Context
import com.chronicle.journal.data.local.dao.AttachmentDao
import com.chronicle.journal.data.local.dao.CollectionDao
import com.chronicle.journal.data.local.dao.JournalEntryDao
import com.chronicle.journal.data.local.dao.TagDao
import com.chronicle.journal.data.local.entities.AttachmentEntity
import com.chronicle.journal.data.local.entities.JournalEntryEntity
import com.chronicle.journal.data.local.entities.JournalEntryTagCrossRef
import com.chronicle.journal.data.local.entities.TagEntity
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.io.BufferedInputStream
import java.io.BufferedOutputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream
import java.util.zip.ZipOutputStream
import javax.inject.Inject
import javax.inject.Singleton

data class BackupResult(
    val success: Boolean,
    val message: String,
    val entriesRestored: Int = 0,
)

@Singleton
class BackupManager
    @Inject
    constructor(
        @ApplicationContext private val context: Context,
        private val journalEntryDao: JournalEntryDao,
        private val tagDao: TagDao,
        private val attachmentDao: AttachmentDao,
        private val collectionDao: CollectionDao,
    ) {
        suspend fun exportToJson(outputFile: File): Boolean =
            withContext(Dispatchers.IO) {
                try {
                    val jsonString = buildBackupJson()
                    outputFile.writeText(jsonString)
                    true
                } catch (e: Exception) {
                    false
                }
            }

        suspend fun exportToTxt(outputFile: File): Boolean =
            withContext(Dispatchers.IO) {
                try {
                    val entries = journalEntryDao.getAllActiveEntries().first()
                    val sb = StringBuilder()
                    sb.append("========================================\n")
                    sb.append("         CHRONICLE JOURNAL EXPORT       \n")
                    sb.append("========================================\n\n")

                    entries.forEach { relation ->
                        val entry = relation.entry
                        sb.append("Date: ").append(java.util.Date(entry.entryDate)).append("\n")
                        sb.append("Title: ").append(entry.title).append("\n")
                        sb
                            .append("Mood: ")
                            .append(entry.mood)
                            .append(" (Intensity: ")
                            .append(entry.moodIntensity)
                            .append("/5)\n")
                        if (relation.tags.isNotEmpty()) {
                            sb.append("Tags: ").append(relation.tags.joinToString(", ") { "#${it.name}" }).append("\n")
                        }
                        if (entry.locationName != null) {
                            sb.append("Location: ").append(entry.locationName).append("\n")
                        }
                        sb.append("\n").append(entry.content).append("\n")
                        sb.append("----------------------------------------\n\n")
                    }

                    outputFile.writeText(sb.toString())
                    true
                } catch (e: Exception) {
                    false
                }
            }

        suspend fun createZipBackup(destinationZipFile: File): Boolean =
            withContext(Dispatchers.IO) {
                try {
                    val jsonContent = buildBackupJson()

                    ZipOutputStream(BufferedOutputStream(FileOutputStream(destinationZipFile))).use { zos ->
                        // Add JSON metadata file
                        val metaEntry = ZipEntry("chronicle_backup.json")
                        zos.putNextEntry(metaEntry)
                        zos.write(jsonContent.toByteArray(Charsets.UTF_8))
                        zos.closeEntry()

                        // Add media attachments
                        val activeEntries = journalEntryDao.getAllActiveEntries().first()
                        activeEntries.forEach { relation ->
                            relation.attachments.forEach { att ->
                                try {
                                    val mediaFile = File(att.uri)
                                    if (mediaFile.exists() && mediaFile.isFile) {
                                        val entryPath = if (att.type == "PHOTO") "photos/${mediaFile.name}" else "audio/${mediaFile.name}"
                                        zos.putNextEntry(ZipEntry(entryPath))
                                        FileInputStream(mediaFile).use { fis ->
                                            fis.copyTo(zos)
                                        }
                                        zos.closeEntry()
                                    }
                                } catch (e: Exception) {
                                    // Continue on single file error
                                }
                            }
                        }
                    }
                    true
                } catch (e: Exception) {
                    false
                }
            }

        suspend fun restoreFromZip(zipFile: File): BackupResult =
            withContext(Dispatchers.IO) {
                try {
                    var jsonString: String? = null
                    val restoredMediaDir = File(context.filesDir, "restored_media").apply { if (!exists()) mkdirs() }

                    ZipInputStream(BufferedInputStream(FileInputStream(zipFile))).use { zis ->
                        var zipEntry: ZipEntry? = zis.nextEntry
                        while (zipEntry != null) {
                            val name = zipEntry.name
                            if (name == "chronicle_backup.json") {
                                jsonString = zis.bufferedReader(Charsets.UTF_8).readText()
                            } else if (name.startsWith("photos/") || name.startsWith("audio/")) {
                                val subFile = File(restoredMediaDir, File(name).name)
                                FileOutputStream(subFile).use { fos ->
                                    zis.copyTo(fos)
                                }
                            }
                            zis.closeEntry()
                            zipEntry = zis.nextEntry
                        }
                    }

                    if (jsonString.isNullOrBlank()) {
                        return@withContext BackupResult(false, "Invalid backup: chronicle_backup.json not found")
                    }

                    restoreFromJsonString(jsonString!!, restoredMediaDir)
                } catch (e: Exception) {
                    BackupResult(false, "Restore failed: ${e.localizedMessage}")
                }
            }

        suspend fun restoreFromJsonFile(jsonFile: File): BackupResult =
            withContext(Dispatchers.IO) {
                try {
                    val jsonString = jsonFile.readText()
                    restoreFromJsonString(jsonString, null)
                } catch (e: Exception) {
                    BackupResult(false, "Restore failed: ${e.localizedMessage}")
                }
            }

        private suspend fun restoreFromJsonString(
            jsonString: String,
            mediaDir: File?,
        ): BackupResult {
            return try {
                val root = JSONObject(jsonString)
                if (!root.has("chronicle_version")) {
                    return BackupResult(false, "Incompatible backup format")
                }

                val entriesArray = root.getJSONArray("entries")
                var count = 0

                for (i in 0 until entriesArray.length()) {
                    val obj = entriesArray.getJSONObject(i)
                    val entryEntity =
                        JournalEntryEntity(
                            title = obj.getString("title"),
                            content = obj.getString("content"),
                            createdAt = obj.getLong("createdAt"),
                            updatedAt = obj.getLong("updatedAt"),
                            entryDate = obj.getLong("entryDate"),
                            mood = obj.optString("mood", "NEUTRAL"),
                            moodIntensity = obj.optInt("moodIntensity", 3),
                            isFavorite = obj.optBoolean("isFavorite", false),
                            locationName = obj.optNullableString("locationName"),
                            latitude = if (obj.has("latitude") && !obj.isNull("latitude")) obj.getDouble("latitude") else null,
                            longitude = if (obj.has("longitude") && !obj.isNull("longitude")) obj.getDouble("longitude") else null,
                            weatherSummary = obj.optNullableString("weatherSummary"),
                            weatherTemperature =
                                if (obj.has("weatherTemperature") &&
                                    !obj.isNull("weatherTemperature")
                                ) {
                                    obj.getDouble("weatherTemperature").toFloat()
                                } else {
                                    null
                                },
                            weatherIcon = obj.optNullableString("weatherIcon"),
                            coverImageUri = obj.optNullableString("coverImageUri"),
                            createdFromTemplate = obj.optNullableString("createdFromTemplate"),
                            archived = obj.optBoolean("archived", false),
                            layoutStyle = obj.optString("layoutStyle", "CLASSIC"),
                        )

                    val newEntryId = journalEntryDao.insertEntry(entryEntity)
                    count++

                    // Restore tags
                    if (obj.has("tags")) {
                        val tagsArr = obj.getJSONArray("tags")
                        for (t in 0 until tagsArr.length()) {
                            val tObj = tagsArr.getJSONObject(t)
                            val tagName = tObj.getString("name").trim().lowercase()
                            val colorHex = tObj.optString("colorHex", "#8C7355")
                            val existingTag = tagDao.getTagByName(tagName)
                            val tagId = existingTag?.id ?: tagDao.insertTag(TagEntity(name = tagName, colorHex = colorHex))
                            journalEntryDao.insertEntryTagCrossRef(
                                JournalEntryTagCrossRef(entryId = newEntryId, tagId = tagId),
                            )
                        }
                    }

                    // Restore attachments
                    if (obj.has("attachments")) {
                        val attArr = obj.getJSONArray("attachments")
                        for (a in 0 until attArr.length()) {
                            val aObj = attArr.getJSONObject(a)
                            val rawUri = aObj.getString("uri")
                            val fileName = File(rawUri).name
                            val localFile = if (mediaDir != null) File(mediaDir, fileName) else File(rawUri)
                            val resolvedUri = if (localFile.exists()) localFile.absolutePath else rawUri

                            val attEntity =
                                AttachmentEntity(
                                    journalEntryId = newEntryId,
                                    uri = resolvedUri,
                                    type = aObj.getString("type"),
                                    caption = aObj.optNullableString("caption"),
                                    durationMs =
                                        if (aObj.has("durationMs") &&
                                            !aObj.isNull("durationMs")
                                        ) {
                                            aObj.getLong("durationMs")
                                        } else {
                                            null
                                        },
                                    createdAt = aObj.optLong("createdAt", System.currentTimeMillis()),
                                )
                            attachmentDao.insertAttachment(attEntity)
                        }
                    }
                }

                BackupResult(true, "Successfully restored $count entries!", count)
            } catch (e: Exception) {
                BackupResult(false, "Parsing failed: ${e.localizedMessage}")
            }
        }

        private suspend fun buildBackupJson(): String {
            val entries = journalEntryDao.getAllActiveEntries().first()
            val tags = tagDao.getAllTagsSync()
            val collections = collectionDao.getAllCollectionsSync()

            val root = JSONObject()
            root.put("chronicle_version", 1)
            root.put("exported_at", System.currentTimeMillis())

            val entriesArray = JSONArray()
            entries.forEach { relation ->
                val entryObj = JSONObject()
                val e = relation.entry
                entryObj.put("title", e.title)
                entryObj.put("content", e.content)
                entryObj.put("createdAt", e.createdAt)
                entryObj.put("updatedAt", e.updatedAt)
                entryObj.put("entryDate", e.entryDate)
                entryObj.put("mood", e.mood)
                entryObj.put("moodIntensity", e.moodIntensity)
                entryObj.put("isFavorite", e.isFavorite)
                entryObj.put("locationName", e.locationName)
                if (e.latitude != null) entryObj.put("latitude", e.latitude)
                if (e.longitude != null) entryObj.put("longitude", e.longitude)
                entryObj.put("weatherSummary", e.weatherSummary)
                if (e.weatherTemperature != null) entryObj.put("weatherTemperature", e.weatherTemperature)
                entryObj.put("weatherIcon", e.weatherIcon)
                entryObj.put("coverImageUri", e.coverImageUri)
                entryObj.put("createdFromTemplate", e.createdFromTemplate)
                entryObj.put("archived", e.archived)
                entryObj.put("layoutStyle", e.layoutStyle)

                val tagsArr = JSONArray()
                relation.tags.forEach { tag ->
                    val tObj = JSONObject()
                    tObj.put("name", tag.name)
                    tObj.put("colorHex", tag.colorHex)
                    tagsArr.put(tObj)
                }
                entryObj.put("tags", tagsArr)

                val attArr = JSONArray()
                relation.attachments.forEach { att ->
                    val aObj = JSONObject()
                    aObj.put("uri", att.uri)
                    aObj.put("type", att.type)
                    aObj.put("caption", att.caption)
                    if (att.durationMs != null) aObj.put("durationMs", att.durationMs)
                    aObj.put("createdAt", att.createdAt)
                    attArr.put(aObj)
                }
                entryObj.put("attachments", attArr)

                entriesArray.put(entryObj)
            }
            root.put("entries", entriesArray)

            return root.toString(2)
        }

        private fun JSONObject.optNullableString(key: String): String? = if (has(key) && !isNull(key)) getString(key) else null
    }
