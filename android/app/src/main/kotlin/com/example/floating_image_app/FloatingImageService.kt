package com.example.floating_image_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

import android.content.pm.ServiceInfo

class FloatingImageService : Service() {

    private val CHANNEL_ID = "FloatingImageServiceChannel"
    private var overlayManager: OverlayManager? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Floating Image Active")
            .setContentText("The floating image is currently displayed.")
            .setSmallIcon(android.R.drawable.ic_menu_gallery)
            .build()
        
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(1, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(1, notification)
        }
        
        overlayManager = OverlayManager(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) return START_STICKY

        when (intent.action) {
            "START" -> {
                val imagePath = intent.getStringExtra("imagePath") ?: ""
                val size = intent.getStringExtra("size") ?: "M"
                val lockScreen = intent.getBooleanExtra("lockScreen", true)
                overlayManager?.showOverlay(imagePath, size, lockScreen)
            }
            "UPDATE_IMAGE" -> {
                val imagePath = intent.getStringExtra("imagePath") ?: ""
                overlayManager?.updateImage(imagePath)
            }
            "UPDATE_SIZE" -> {
                val size = intent.getStringExtra("size") ?: "M"
                overlayManager?.updateSize(size)
            }
            "UPDATE_LOCK" -> {
                val lockScreen = intent.getBooleanExtra("lockScreen", true)
                overlayManager?.updateLockScreen(lockScreen)
            }
            "RESET_POSITION" -> {
                overlayManager?.resetPosition()
            }
            "STOP" -> {
                stopSelf()
            }
        }

        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        overlayManager?.removeOverlay()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Floating Image Service Channel",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }
}
