package com.chronicle.journal.presentation.lock

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.chronicle.journal.core.utils.SecurityUtils
import com.chronicle.journal.data.preferences.UserPreferencesRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import javax.inject.Inject

data class LockUiState(
    val enteredPin: String = "",
    val errorMessage: String? = null,
    val isBiometricAvailable: Boolean = false,
)

@HiltViewModel
class LockViewModel
    @Inject
    constructor(
        private val preferencesRepository: UserPreferencesRepository,
    ) : ViewModel() {
        private val _uiState = MutableStateFlow(LockUiState())
        val uiState: StateFlow<LockUiState> = _uiState.asStateFlow()

        private val _unlockSuccessEvent = MutableSharedFlow<Unit>()
        val unlockSuccessEvent: SharedFlow<Unit> = _unlockSuccessEvent.asSharedFlow()

        fun onDigitPressed(digit: Char) {
            if (_uiState.value.enteredPin.length < 6) {
                val newPin = _uiState.value.enteredPin + digit
                _uiState.value = _uiState.value.copy(enteredPin = newPin, errorMessage = null)

                // If length matches typical 4 or 6, check
                if (newPin.length >= 4) {
                    checkPin(newPin)
                }
            }
        }

        fun onBackspace() {
            if (_uiState.value.enteredPin.isNotEmpty()) {
                val newPin = _uiState.value.enteredPin.dropLast(1)
                _uiState.value = _uiState.value.copy(enteredPin = newPin, errorMessage = null)
            }
        }

        private fun checkPin(pin: String) {
            viewModelScope.launch {
                val prefs = preferencesRepository.userPreferencesFlow.first()
                if (SecurityUtils.verifyPin(pin, prefs.pinHash)) {
                    _unlockSuccessEvent.emit(Unit)
                } else if (pin.length >= 6) {
                    _uiState.value =
                        _uiState.value.copy(
                            enteredPin = "",
                            errorMessage = "Incorrect PIN code",
                        )
                }
            }
        }

        fun onBiometricSuccess() {
            viewModelScope.launch {
                _unlockSuccessEvent.emit(Unit)
            }
        }
    }
