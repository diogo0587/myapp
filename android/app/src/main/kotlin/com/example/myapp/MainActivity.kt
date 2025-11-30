package com.example.myapp

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val notificationChannel = "com.example.myapp/notifications"
    private val permissionChannel = "com.example.myapp/permissions"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val handler = NotificationEventHandler()
        NotificationListener.eventHandler = handler
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            notificationChannel
        ).setStreamHandler(handler)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            permissionChannel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openNotificationSettings" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(null)
                }
                "isNotificationAccessGranted" -> {
                    val enabledListeners = Settings.Secure.getString(
                        contentResolver,
                        "enabled_notification_listeners"
                    ) ?: ""
                    val isEnabled = enabledListeners.contains(componentName.flattenToString())
                    result.success(isEnabled)
                }
                else -> result.notImplemented()
            }
        }
    }
}
