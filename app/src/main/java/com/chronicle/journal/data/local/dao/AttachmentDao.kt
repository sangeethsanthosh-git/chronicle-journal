package com.chronicle.journal.data.local.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.chronicle.journal.data.local.entities.AttachmentEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface AttachmentDao {
    @Query("SELECT * FROM attachments WHERE journalEntryId = :entryId ORDER BY createdAt ASC")
    fun getAttachmentsForEntry(entryId: Long): Flow<List<AttachmentEntity>>

    @Query("SELECT * FROM attachments WHERE journalEntryId = :entryId ORDER BY createdAt ASC")
    suspend fun getAttachmentsForEntrySync(entryId: Long): List<AttachmentEntity>

    @Query("SELECT * FROM attachments WHERE type = :type")
    suspend fun getAttachmentsByType(type: String): List<AttachmentEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAttachment(attachment: AttachmentEntity): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAttachments(attachments: List<AttachmentEntity>): List<Long>

    @Delete
    suspend fun deleteAttachment(attachment: AttachmentEntity)

    @Query("DELETE FROM attachments WHERE journalEntryId = :entryId")
    suspend fun deleteAttachmentsForEntry(entryId: Long)

    @Query("SELECT COUNT(*) FROM attachments WHERE type = 'PHOTO'")
    suspend fun getTotalPhotosCount(): Int

    @Query("SELECT COUNT(*) FROM attachments WHERE type = 'AUDIO'")
    suspend fun getTotalAudioCount(): Int
}
