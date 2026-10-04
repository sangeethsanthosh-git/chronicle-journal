package com.chronicle.journal.presentation.media

import android.content.Context
import android.media.MediaRecorder
import android.os.Build
import android.os.SystemClock
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import java.io.File
import javax.inject.Inject
import javax.inject.Singleton

sealed interface RecordingState {
    data object Idle : RecordingState

    data class Recording(
        val durationMs: Long,
    ) : RecordingState

    data class Paused(
        val durationMs: Long,
    ) : RecordingState

    data class Completed(
        val file: File,
        val durationMs: Long,
    ) : RecordingState

    data class Error(
        val message: String,
    ) : RecordingState
}

@Singleton
class AudioRecorderHelper
    @Inject
    constructor(
        @ApplicationContext private val context: Context,
    ) {
        private var mediaRecorder: MediaRecorder? = null
        private var currentOutputFile: File? = null
        private var startTimeMillis: Long = 0L
        private var pausedDurationMillis: Long = 0L
        private var timerJob: Job? = null
        private val scope = CoroutineScope(Dispatchers.Default)

        private val _recordingState = MutableStateFlow<RecordingState>(RecordingState.Idle)
        val recordingState: StateFlow<RecordingState> = _recordingState.asStateFlow()

        fun startRecording(): File? {
            try {
                stopRecording() // Clean any leftover

                val audioDir = File(context.filesDir, "audio").apply { if (!exists()) mkdirs() }
                val outputFile = File(audioDir, "audio_${System.currentTimeMillis()}.m4a")
                currentOutputFile = outputFile

                val recorder =
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        MediaRecorder(context)
                    } else {
                        @Suppress("DEPRECATION")
                        MediaRecorder()
                    }

                recorder.apply {
                    setAudioSource(MediaRecorder.AudioSource.MIC)
                    setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                    setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                    setAudioEncodingBitRate(128000)
                    setAudioSamplingRate(44100)
                    setOutputFile(outputFile.absolutePath)
                    prepare()
                    start()
                }

                mediaRecorder = recorder
                startTimeMillis = SystemClock.elapsedRealtime()
                pausedDurationMillis = 0L

                startTimer()
                return outputFile
            } catch (e: Exception) {
                _recordingState.value = RecordingState.Error(e.localizedMessage ?: "Failed to start recording")
                mediaRecorder?.release()
                mediaRecorder = null
                return null
            }
        }

        fun pauseRecording() {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                try {
                    mediaRecorder?.pause()
                    timerJob?.cancel()
                    pausedDurationMillis += SystemClock.elapsedRealtime() - startTimeMillis
                    _recordingState.value = RecordingState.Paused(pausedDurationMillis)
                } catch (e: Exception) {
                    // Ignore pause failure
                }
            }
        }

        fun resumeRecording() {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                try {
                    mediaRecorder?.resume()
                    startTimeMillis = SystemClock.elapsedRealtime()
                    startTimer()
                } catch (e: Exception) {
                    // Ignore resume failure
                }
            }
        }

        fun stopRecording(): File? {
            timerJob?.cancel()
            val file = currentOutputFile
            val totalDuration =
                pausedDurationMillis +
                    if (startTimeMillis > 0) {
                        SystemClock.elapsedRealtime() - startTimeMillis
                    } else {
                        0L
                    }

            try {
                mediaRecorder?.apply {
                    stop()
                    reset()
                    release()
                }
            } catch (e: Exception) {
                // Can throw if stopped immediately
            } finally {
                mediaRecorder = null
            }

            if (file != null && file.exists() && file.length() > 0) {
                _recordingState.value = RecordingState.Completed(file, totalDuration)
            } else {
                _recordingState.value = RecordingState.Idle
            }

            return file
        }

        fun cancelRecording() {
            timerJob?.cancel()
            try {
                mediaRecorder?.apply {
                    stop()
                    release()
                }
            } catch (e: Exception) {
                // Ignore
            } finally {
                mediaRecorder = null
            }
            currentOutputFile?.delete()
            currentOutputFile = null
            _recordingState.value = RecordingState.Idle
        }

        private fun startTimer() {
            timerJob?.cancel()
            timerJob =
                scope.launch {
                    while (isActive) {
                        val currentDuration = pausedDurationMillis + (SystemClock.elapsedRealtime() - startTimeMillis)
                        _recordingState.value = RecordingState.Recording(currentDuration)
                        delay(200)
                    }
                }
        }
    }
