package com.chronicle.journal.presentation.media

import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.net.Uri
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
import javax.inject.Inject
import javax.inject.Singleton

data class PlaybackState(
    val isPlaying: Boolean = false,
    val currentPositionMs: Long = 0L,
    val totalDurationMs: Long = 0L,
    val playingUri: String? = null,
)

@Singleton
class AudioPlayerHelper
    @Inject
    constructor(
        @ApplicationContext private val context: Context,
    ) {
        private var mediaPlayer: MediaPlayer? = null
        private var progressJob: Job? = null
        private val scope = CoroutineScope(Dispatchers.Main)

        private val _playbackState = MutableStateFlow(PlaybackState())
        val playbackState: StateFlow<PlaybackState> = _playbackState.asStateFlow()

        fun play(uriString: String) {
            if (_playbackState.value.playingUri == uriString && mediaPlayer != null) {
                if (!_playbackState.value.isPlaying) {
                    mediaPlayer?.start()
                    _playbackState.value = _playbackState.value.copy(isPlaying = true)
                    startProgressTracker()
                }
                return
            }

            stop()

            try {
                val player =
                    MediaPlayer().apply {
                        setAudioAttributes(
                            AudioAttributes
                                .Builder()
                                .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                                .setUsage(AudioAttributes.USAGE_MEDIA)
                                .build(),
                        )

                        if (uriString.startsWith("content://") || uriString.startsWith("file://")) {
                            setDataSource(context, Uri.parse(uriString))
                        } else {
                            setDataSource(uriString)
                        }

                        prepare()
                        start()
                    }

                val duration = player.duration.toLong()
                mediaPlayer = player

                _playbackState.value =
                    PlaybackState(
                        isPlaying = true,
                        currentPositionMs = 0L,
                        totalDurationMs = duration,
                        playingUri = uriString,
                    )

                player.setOnCompletionListener {
                    stop()
                }

                startProgressTracker()
            } catch (e: Exception) {
                stop()
            }
        }

        fun pause() {
            mediaPlayer?.let {
                if (it.isPlaying) {
                    it.pause()
                    progressJob?.cancel()
                    _playbackState.value = _playbackState.value.copy(isPlaying = false)
                }
            }
        }

        fun stop() {
            progressJob?.cancel()
            try {
                mediaPlayer?.apply {
                    if (isPlaying) stop()
                    reset()
                    release()
                }
            } catch (e: Exception) {
                // Ignore
            } finally {
                mediaPlayer = null
            }
            _playbackState.value = PlaybackState()
        }

        fun seekTo(positionMs: Long) {
            mediaPlayer?.seekTo(positionMs.toInt())
            _playbackState.value = _playbackState.value.copy(currentPositionMs = positionMs)
        }

        private fun startProgressTracker() {
            progressJob?.cancel()
            progressJob =
                scope.launch {
                    while (isActive && mediaPlayer?.isPlaying == true) {
                        val current = mediaPlayer?.currentPosition?.toLong() ?: 0L
                        _playbackState.value = _playbackState.value.copy(currentPositionMs = current)
                        delay(200)
                    }
                }
        }
    }
