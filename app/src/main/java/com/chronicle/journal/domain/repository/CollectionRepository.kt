package com.chronicle.journal.domain.repository

import com.chronicle.journal.domain.model.Collection
import com.chronicle.journal.domain.model.JournalWithDetails
import kotlinx.coroutines.flow.Flow

interface CollectionRepository {
    fun getAllCollections(): Flow<List<Collection>>

    fun getCollectionById(id: Long): Flow<Collection?>

    suspend fun createCollection(
        name: String,
        description: String? = null,
        coverImageUri: String? = null,
    ): Long

    suspend fun updateCollection(collection: Collection)

    suspend fun deleteCollection(collection: Collection)

    suspend fun addEntryToCollection(
        collectionId: Long,
        entryId: Long,
    )

    suspend fun removeEntryFromCollection(
        collectionId: Long,
        entryId: Long,
    )

    fun getEntriesForCollection(collectionId: Long): Flow<List<JournalWithDetails>>
}
