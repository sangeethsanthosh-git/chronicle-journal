package com.chronicle.journal.presentation.onboarding

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronicle.journal.data.preferences.UserPreferencesRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class OnboardingViewModel
    @Inject
    constructor(
        private val preferencesRepository: UserPreferencesRepository,
    ) : ViewModel() {
        fun completeOnboarding(onFinished: () -> Unit) {
            viewModelScope.launch {
                preferencesRepository.setOnboardingCompleted(true)
                onFinished()
            }
        }
    }
