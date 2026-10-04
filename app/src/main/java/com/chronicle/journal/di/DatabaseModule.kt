package com.chronicle.journal.di

import android.content.Context
import androidx.room.Room
import com.chronicle.journal.data.local.dao.AttachmentDao
import com.chronicle.journal.data.local.dao.CollectionDao
import com.chronicle.journal.data.local.dao.JournalEntryDao
import com.chronicle.journal.data.local.dao.TagDao
import com.chronicle.journal.data.local.database.ChronicleDatabase
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {
    @Provides
    @Singleton
    fun provideDatabase(
        @ApplicationContext context: Context,
    ): ChronicleDatabase =
        Room
            .databaseBuilder(
                context,
                ChronicleDatabase::class.java,
                ChronicleDatabase.DATABASE_NAME,
            ).fallbackToDestructiveMigration()
            .build()

    @Provides
    fun provideJournalEntryDao(database: ChronicleDatabase): JournalEntryDao = database.journalEntryDao()

    @Provides
    fun provideTagDao(database: ChronicleDatabase): TagDao = database.tagDao()

    @Provides
    fun provideAttachmentDao(database: ChronicleDatabase): AttachmentDao = database.attachmentDao()

    @Provides
    fun provideCollectionDao(database: ChronicleDatabase): CollectionDao = database.collectionDao()
}
