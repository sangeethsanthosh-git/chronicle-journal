package com.chronicle.journal.data.local.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction
import androidx.room.Update
import com.chronicle.journal.data.local.entities.CollectionEntity
import com.chronicle.journal.data.local.entities.CollectionEntryCrossRef
import com.chronicle.journal.data.local.entities.JournalEntryWithDetailsRelation
import kotlinx.coroutines.flow.Flow

@Dao
interface CollectionDao {
    @Query("SELECT * FROM collections ORDER BY createdAt DESC")
    fun getAllCollections(): Flow<List<CollectionEntity>>

    @Query("SELECT * FROM collections ORDER BY createdAt DESC")
    suspend fun getAllCollectionsSync(): List<CollectionEntity>

    @Query("SELECT * FROM collections WHERE id = :id LIMIT 1")
    fun getCollectionById(id: Long): Flow<CollectionEntity?>

    @Query("SELECT * FROM collections WHERE id = :id LIMIT 1")
    suspend fun getCollectionByIdSync(id: Long): CollectionEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertCollection(collection: CollectionEntity): Long

    @Update
    suspend fun updateCollection(collection: CollectionEntity)

    @Delete
    suspend fun deleteCollection(collection: CollectionEntity)

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun addEntryToCollection(crossRef: CollectionEntryCrossRef)

    @Query("DELETE FROM collection_entry_cross_ref WHERE collectionId = :collectionId AND entryId = :entryId")
    suspend fun removeEntryFromCollection(
        collectionId: Long,
        entryId: Long,
    )

    @Transaction
    @Query(
        """
        SELECT e.* FROM journal_entries e
        INNER JOIN collection_entry_cross_ref xref ON e.id = xref.entryId
        WHERE xref.collectionId = :collectionId AND e.deletedAt IS NULL
        ORDER BY e.entryDate DESC
        """,
    )
    fun getEntriesForCollection(collectionId: Long): Flow<List<JournalEntryWithDetailsRelation>>

    @Query("SELECT COUNT(*) FROM collection_entry_cross_ref WHERE collectionId = :collectionId")
    fun getEntryCountForCollection(collectionId: Long): Flow<Int>

    @Query("SELECT COUNT(*) FROM collection_entry_cross_ref WHERE collectionId = :collectionId")
    suspend fun getEntryCountForCollectionSync(collectionId: Long): Int
}
