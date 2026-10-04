package com.chronicle.chronicle

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.media.MediaMetadata
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.chronicle.journal/music_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> {
                    // Supported on Android 5.0+ (API 21+)
                    result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
                }
                "hasPermission" -> {
                    result.success(isNotificationServiceEnabled())
                }
                "requestPermission" -> {
                    try {
                        val compName = ComponentName(this, MediaNotificationListenerService::class.java)
                        packageManager.setComponentEnabledSetting(
                            compName,
                            android.content.pm.PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                            android.content.pm.PackageManager.DONT_KILL_APP
                        )
                        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INTENT_ERROR", e.localizedMessage, null)
                    }
                }
                "getCurrentTrack" -> {
                    try {
                        val trackInfo = extractCurrentTrackInfo()
                        result.success(trackInfo)
                    } catch (e: Exception) {
                        // Return null gracefully rather than crashing
                        result.success(null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun isNotificationServiceEnabled(): Boolean {
        val pkgName = packageName
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        if (!flat.isNullOrEmpty()) {
            val names = flat.split(":")
            for (name in names) {
                val cn = ComponentName.unflattenFromString(name)
                if (cn != null && cn.packageName == pkgName) {
                    val compName = ComponentName(this, MediaNotificationListenerService::class.java)
                    packageManager.setComponentEnabledSetting(
                        compName,
                        android.content.pm.PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                        android.content.pm.PackageManager.DONT_KILL_APP
                    )
                    return true
                }
            }
        }
        return false
    }

    private fun extractCurrentTrackInfo(): Map<String, Any?>? {
        if (!isNotificationServiceEnabled()) {
            return null
        }

        val mediaSessionManager = getSystemService(Context.MEDIA_SESSION_SERVICE) as? MediaSessionManager
            ?: return null

        val componentName = ComponentName(this, MediaNotificationListenerService::class.java)
        val controllers: List<MediaController> = try {
            mediaSessionManager.getActiveSessions(componentName)
        } catch (e: SecurityException) {
            return null
        } catch (e: Exception) {
            return null
        }

        if (controllers.isEmpty()) {
            return null
        }

        // Prioritize currently playing controller, otherwise fallback to the most recent one with metadata
        var activeController: MediaController? = null
        for (controller in controllers) {
            val state = controller.playbackState
            if (state != null && state.state == PlaybackState.STATE_PLAYING) {
                activeController = controller
                break
            }
        }

        if (activeController == null) {
            for (controller in controllers) {
                if (controller.metadata != null) {
                    activeController = controller
                    break
                }
            }
        }

        if (activeController == null) {
            activeController = controllers[0]
        }

        val metadata = activeController.metadata
        val playbackState = activeController.playbackState
        val isPlaying = playbackState?.state == PlaybackState.STATE_PLAYING

        // Resolve application display name
        var appName: String? = null
        val pkg = activeController.packageName
        try {
            val appInfo = packageManager.getApplicationInfo(pkg, 0)
            appName = packageManager.getApplicationLabel(appInfo).toString()
        } catch (e: Exception) {
            appName = pkg
        }

        var title: String? = metadata?.getString(MediaMetadata.METADATA_KEY_TITLE)
        var artist: String? = metadata?.getString(MediaMetadata.METADATA_KEY_ARTIST)
        val album: String? = metadata?.getString(MediaMetadata.METADATA_KEY_ALBUM)

        val description = metadata?.description

        // Fallbacks for title and artist if missing or in alternative metadata keys
        if (title.isNullOrEmpty()) {
            title = metadata?.getString(MediaMetadata.METADATA_KEY_DISPLAY_TITLE)
                ?: description?.title?.toString()
        }
        if (artist.isNullOrEmpty()) {
            artist = metadata?.getString(MediaMetadata.METADATA_KEY_ALBUM_ARTIST)
                ?: metadata?.getString(MediaMetadata.METADATA_KEY_AUTHOR)
                ?: description?.subtitle?.toString()
        }

        // If no title is available and not playing, return null
        if (title.isNullOrEmpty() && artist.isNullOrEmpty() && !isPlaying) {
            return null
        }

        // Duration & position
        val durationMs = metadata?.getLong(MediaMetadata.METADATA_KEY_DURATION)
        val positionMs = playbackState?.position

        // Handle artwork extraction (caching to local app cache directory)
        var artworkUri: String? = null
        var bitmap: Bitmap? = metadata?.getBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART)
            ?: metadata?.getBitmap(MediaMetadata.METADATA_KEY_ART)
            ?: metadata?.getBitmap(MediaMetadata.METADATA_KEY_DISPLAY_ICON)
            ?: description?.iconBitmap

        if (bitmap != null) {
            artworkUri = saveArtworkBitmap(bitmap)
        } else {
            val uri = description?.iconUri
                ?: run {
                    val uriStr = metadata?.getString(MediaMetadata.METADATA_KEY_ALBUM_ART_URI)
                        ?: metadata?.getString(MediaMetadata.METADATA_KEY_ART_URI)
                        ?: metadata?.getString(MediaMetadata.METADATA_KEY_DISPLAY_ICON_URI)
                    if (!uriStr.isNullOrEmpty()) android.net.Uri.parse(uriStr) else null
                }

            if (uri != null) {
                val scheme = uri.scheme
                if (scheme == "content" || scheme == "android.resource") {
                    try {
                        contentResolver.openInputStream(uri)?.use { stream ->
                            val decoded = android.graphics.BitmapFactory.decodeStream(stream)
                            if (decoded != null) {
                                artworkUri = saveArtworkBitmap(decoded)
                            }
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                } else {
                    artworkUri = uri.toString()
                }
            }
        }

        val result = HashMap<String, Any?>()
        result["title"] = title ?: "Unknown Track"
        result["artist"] = artist ?: "Unknown Artist"
        result["album"] = album ?: description?.description?.toString()
        result["artworkUri"] = artworkUri
        result["applicationName"] = appName
        result["isPlaying"] = isPlaying
        result["durationMs"] = if (durationMs != null && durationMs > 0) durationMs else null
        result["positionMs"] = if (positionMs != null && positionMs >= 0) positionMs else null
        result["capturedAt"] = System.currentTimeMillis()

        return result
    }

    private fun saveArtworkBitmap(bitmap: Bitmap): String? {
        return try {
            val file = File(cacheDir, "now_playing_art_${System.currentTimeMillis()}.jpg")
            val outputStream = FileOutputStream(file)
            bitmap.compress(Bitmap.CompressFormat.JPEG, 90, outputStream)
            outputStream.flush()
            outputStream.close()
            if (file.exists() && file.length() > 0) {
                file.absolutePath
            } else {
                null
            }
        } catch (e: Exception) {
            null
        }
    }
}
