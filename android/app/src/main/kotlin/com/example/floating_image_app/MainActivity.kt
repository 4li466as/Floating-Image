package com.example.floating_image_app

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.floatingimage/overlay"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkOverlayPermission" -> {
                    val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        Settings.canDrawOverlays(this)
                    } else {
                        true
                    }
                    result.success(hasPermission)
                }
                "requestOverlayPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        startActivity(intent)
                    }
                    result.success(null)
                }
                "startOverlay" -> {
                    val imagePath = call.argument<String>("imagePath") ?: ""
                    val size = call.argument<String>("size") ?: "M"
                    val lockScreen = call.argument<Boolean>("lockScreen") ?: true
                    
                    val serviceIntent = Intent(this, FloatingImageService::class.java).apply {
                        action = "START"
                        putExtra("imagePath", imagePath)
                        putExtra("size", size)
                        putExtra("lockScreen", lockScreen)
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(serviceIntent)
                    } else {
                        startService(serviceIntent)
                    }
                    result.success(null)
                }
                "stopOverlay" -> {
                    val serviceIntent = Intent(this, FloatingImageService::class.java).apply {
                        action = "STOP"
                    }
                    startService(serviceIntent)
                    result.success(null)
                }
                "updateImage" -> {
                    val imagePath = call.argument<String>("imagePath") ?: ""
                    val serviceIntent = Intent(this, FloatingImageService::class.java).apply {
                        action = "UPDATE_IMAGE"
                        putExtra("imagePath", imagePath)
                    }
                    startService(serviceIntent)
                    result.success(null)
                }
                "updateSize" -> {
                    val size = call.argument<String>("size") ?: "M"
                    val serviceIntent = Intent(this, FloatingImageService::class.java).apply {
                        action = "UPDATE_SIZE"
                        putExtra("size", size)
                    }
                    startService(serviceIntent)
                    result.success(null)
                }
                "updateLockScreen" -> {
                    val lockScreen = call.argument<Boolean>("lockScreen") ?: true
                    val serviceIntent = Intent(this, FloatingImageService::class.java).apply {
                        action = "UPDATE_LOCK"
                        putExtra("lockScreen", lockScreen)
                    }
                    startService(serviceIntent)
                    result.success(null)
                }
                "resetPosition" -> {
                    val serviceIntent = Intent(this, FloatingImageService::class.java).apply {
                        action = "RESET_POSITION"
                    }
                    startService(serviceIntent)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
