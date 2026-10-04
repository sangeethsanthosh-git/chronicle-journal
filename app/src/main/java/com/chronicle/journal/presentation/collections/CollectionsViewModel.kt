package com.chronicle.journal.presentation.collections

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronicle.journal.domain.model.Collection
import com.chronicle.journal.domain.repository.CollectionRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import javax.inject.Inject

data class CollectionsUiState(
    val collections: List<Collection> = emptyList(),
    val isLoading: Boolean = true,
)

@HiltViewModel
class CollectionsViewModel
    @Inject
    constructor(
        private val collectionRepository: CollectionRepository,
    ) : ViewModel() {
        private val _uiState = MutableStateFlow(CollectionsUiState())
        val uiState: StateFlow<CollectionsUiState> = _uiState.asStateFlow()

        init {
            loadCollections()
        }

        private fun loadCollections() {
            viewModelScope.launch {
                collectionRepository.getAllCollections().collectLatest { list ->
                    // If collections list is completely empty, seed default inspirations
                    if (list.isEmpty()) {
                        collectionRepository.createCollection("Travel & Wanderlust", "Journeys, escapes, and postcards")
                        collectionRepository.createCollection("Best Memories", "Moments that made life wonderful")
                        collectionRepository.createCollection("Ideas & Spark", "Creative thoughts and projects")
                    }
                    _uiState.value = CollectionsUiState(collections = list, isLoading = false)
                }
            }
        }

        fun createCollection(
            name: String,
            description: String?,
        ) {
            viewModelScope.launch {
                collectionRepository.createCollection(name, description)
            }
        }

        fun deleteCollection(collection: Collection) {
            viewModelScope.launch {
                collectionRepository.deleteCollection(collection)
            }
        }
    }
