package com.chronicle.journal.di

import com.chronicle.journal.data.repository.CollectionRepositoryImpl
import com.chronicle.journal.data.repository.JournalRepositoryImpl
import com.chronicle.journal.domain.repository.CollectionRepository
import com.chronicle.journal.domain.repository.JournalRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {
    @Binds
    @Singleton
    abstract fun bindJournalRepository(impl: JournalRepositoryImpl): JournalRepository

    @Binds
    @Singleton
    abstract fun bindCollectionRepository(impl: CollectionRepositoryImpl): CollectionRepository
}
