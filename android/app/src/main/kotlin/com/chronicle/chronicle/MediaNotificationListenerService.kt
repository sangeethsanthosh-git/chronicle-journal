package com.chronicle.chronicle

import android.service.notification.NotificationListenerService

/**
 * Android NotificationListenerService required by Android's MediaSessionManager
 * to inspect active media playback sessions.
 * 
 * In accordance with strict privacy principles, this service does NOT log, store,
 * or monitor user notifications. It is solely registered so MediaSessionManager.getActiveSessions()
 * can query the currently active media session when the user explicitly requests it.
 */
class MediaNotificationListenerService : NotificationListenerService() {
    companion object {
        var isConnected: Boolean = false
            private set
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        isConnected = true
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        isConnected = false
    }
}
