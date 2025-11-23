package com.example.myapp

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.plugin.common.EventChannel

class NotificationListener : NotificationListenerService() {

    companion object {
        var eventHandler: NotificationEventHandler? = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        val notification = sbn?.notification
        if (notification != null) {
            val title = notification.extras.getString(Notification.EXTRA_TITLE) ?: ""
            val text = notification.extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
            val appName = sbn.packageName ?: ""

            val notificationData = mapOf(
                "title" to title,
                "body" to text,
                "appName" to appName
            )
            eventHandler?.sendEvent(notificationData)
        }
    }
}

class NotificationEventHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun sendEvent(data: Map<String, Any>) {
        eventSink?.success(data)
    }
}
