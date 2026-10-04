package com.chronicle.journal.data.repository

import com.chronicle.journal.data.local.dao.CollectionDao
import com.chronicle.journal.data.local.entities.CollectionEntity
import com.chronicle.journal.data.local.entities.CollectionEntryCrossRef
import com.chronicle.journal.domain.model.Collection
import com.chronicle.journal.domain.model.JournalWithDetails
import com.chronicle.journal.domain.repository.CollectionRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class CollectionRepositoryImpl
    @Inject
    constructor(
        private val collectionDao: CollectionDao,
    ) : CollectionRepository {
        override fun getAllCollections(): Flow<List<Collection>> =
            collectionDao.getAllCollections().map { list ->
                list.map { entity ->
                    val count = collectionDao.getEntryCountForCollectionSync(entity.id)
                    entity.toDomain(entryCount = count)
                }
            }

        override fun getCollectionById(id: Long): Flow<Collection?> =
            collectionDao.getCollectionById(id).map { entity ->
                if (entity != null) {
                    val count = collectionDao.getEntryCountForCollectionSync(entity.id)
                    entity.toDomain(entryCount = count)
                } else {
                    null
                }
            }

        override suspend fun createCollection(
            name: String,
            description: String?,
            coverImageUri: String?,
        ): Long {
            val entity =
                CollectionEntity(
                    name = name.trim(),
                    description = description?.trim(),
                    coverImageUri = coverImageUri,
                )
            return collectionDao.insertCollection(entity)
        }

        override suspend fun updateCollection(collection: Collection) {
            collectionDao.updateCollection(CollectionEntity.fromDomain(collection))
        }

        override suspend fun deleteCollection(collection: Collection) {
            collectionDao.deleteCollection(CollectionEntity.fromDomain(collection))
        }

        override suspend fun addEntryToCollection(
            collectionId: Long,
            entryId: Long,
        ) {
            collectionDao.addEntryToCollection(
                CollectionEntryCrossRef(collectionId = collectionId, entryId = entryId),
            )
        }

        override suspend fun removeEntryFromCollection(
            collectionId: Long,
            entryId: Long,
        ) {
            collectionDao.removeEntryFromCollection(collectionId, entryId)
        }

        override fun getEntriesForCollection(collectionId: Long): Flow<List<JournalWithDetails>> =
            collectionDao.getEntriesForCollection(collectionId).map { relations ->
                relations.map { it.toDomain() }
            }
    }
