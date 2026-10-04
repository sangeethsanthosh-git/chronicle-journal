package com.chronicle.journal.data.local.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction
import androidx.room.Update
import com.chronicle.journal.data.local.entities.DraftEntity
import com.chronicle.journal.data.local.entities.JournalEntryEntity
import com.chronicle.journal.data.local.entities.JournalEntryTagCrossRef
import com.chronicle.journal.data.local.entities.JournalEntryWithDetailsRelation
import kotlinx.coroutines.flow.Flow

@Dao
interface JournalEntryDao {
    @Transaction
    @Query("SELECT * FROM journal_entries WHERE deletedAt IS NULL AND archived = 0 ORDER BY entryDate DESC, createdAt DESC")
    fun getAllActiveEntries(): Flow<List<JournalEntryWithDetailsRelation>>

    @Transaction
    @Query("SELECT * FROM journal_entries WHERE id = :id")
    fun getEntryById(id: Long): Flow<JournalEntryWithDetailsRelation?>

    @Transaction
    @Query("SELECT * FROM journal_entries WHERE id = :id")
    suspend fun getEntryByIdSync(id: Long): JournalEntryWithDetailsRelation?

    @Transaction
    @Query("SELECT * FROM journal_entries WHERE deletedAt IS NULL AND isFavorite = 1 ORDER BY entryDate DESC")
    fun getFavoriteEntries(): Flow<List<JournalEntryWithDetailsRelation>>

    @Transaction
    @Query(
        "SELECT * FROM journal_entries WHERE deletedAt IS NULL AND entryDate >= :startDate AND entryDate <= :endDate ORDER BY entryDate ASC",
    )
    fun getEntriesByDateRange(
        startDate: Long,
        endDate: Long,
    ): Flow<List<JournalEntryWithDetailsRelation>>

    @Transaction
    @Query(
        "SELECT * FROM journal_entries WHERE deletedAt IS NULL AND entryDate >= :startOfDay AND entryDate <= :endOfDay ORDER BY createdAt DESC",
    )
    fun getEntriesForDay(
        startOfDay: Long,
        endOfDay: Long,
    ): Flow<List<JournalEntryWithDetailsRelation>>

    @Transaction
    @Query(
        """
        SELECT DISTINCT e.* FROM journal_entries e
        LEFT JOIN journal_entry_tag_cross_ref xref ON e.id = xref.entryId
        LEFT JOIN tags t ON xref.tagId = t.id
        WHERE e.deletedAt IS NULL
        AND (
            e.title LIKE '%' || :query || '%' 
            OR e.content LIKE '%' || :query || '%' 
            OR (e.locationName IS NOT NULL AND e.locationName LIKE '%' || :query || '%')
            OR (t.name IS NOT NULL AND t.name LIKE '%' || :query || '%')
        )
        ORDER BY e.entryDate DESC
        """,
    )
    fun searchEntries(query: String): Flow<List<JournalEntryWithDetailsRelation>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertEntry(entry: JournalEntryEntity): Long

    @Update
    suspend fun updateEntry(entry: JournalEntryEntity)

    @Delete
    suspend fun deleteEntry(entry: JournalEntryEntity)

    @Query("UPDATE journal_entries SET deletedAt = :deletedAt WHERE id = :id")
    suspend fun softDeleteEntry(
        id: Long,
        deletedAt: Long = System.currentTimeMillis(),
    )

    @Query("DELETE FROM journal_entries WHERE id = :id")
    suspend fun hardDeleteEntry(id: Long)

    @Query("UPDATE journal_entries SET isFavorite = :isFavorite WHERE id = :id")
    suspend fun setFavorite(
        id: Long,
        isFavorite: Boolean,
    )

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertEntryTagCrossRef(crossRef: JournalEntryTagCrossRef)

    @Query("DELETE FROM journal_entry_tag_cross_ref WHERE entryId = :entryId")
    suspend fun deleteTagsForEntry(entryId: Long)

    @Query("SELECT COUNT(*) FROM journal_entries WHERE deletedAt IS NULL AND archived = 0")
    fun getTotalEntriesCount(): Flow<Int>

    @Query("SELECT COUNT(*) FROM journal_entries WHERE deletedAt IS NULL AND archived = 0")
    suspend fun getTotalEntriesCountSync(): Int

    @Query("SELECT COUNT(*) FROM journal_entries WHERE deletedAt IS NULL AND archived = 0 AND entryDate >= :start AND entryDate <= :end")
    suspend fun getEntriesCountBetween(
        start: Long,
        end: Long,
    ): Int

    @Query("SELECT entryDate FROM journal_entries WHERE deletedAt IS NULL AND archived = 0 ORDER BY entryDate ASC")
    suspend fun getAllEntryDates(): List<Long>

    @Query("SELECT DISTINCT strftime('%Y', datetime(entryDate / 1000, 'unixepoch')) FROM journal_entries WHERE deletedAt IS NULL")
    suspend fun getDistinctEntryYears(): List<String>

    // Draft persistence
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertDraft(draft: DraftEntity)

    @Query("SELECT * FROM journal_drafts WHERE id = 1 LIMIT 1")
    fun getDraft(): Flow<DraftEntity?>

    @Query("DELETE FROM journal_drafts WHERE id = 1")
    suspend fun clearDraft()
}
