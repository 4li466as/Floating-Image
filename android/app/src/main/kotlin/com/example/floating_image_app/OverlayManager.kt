package com.example.floating_image_app

import android.annotation.SuppressLint
import android.content.Context
import android.content.SharedPreferences
import android.graphics.PixelFormat
import android.os.Build
import android.util.DisplayMetrics
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import coil.ImageLoader
import coil.decode.GifDecoder
import coil.decode.ImageDecoderDecoder
import coil.load
import java.io.File

class OverlayManager(private val context: Context) {
    private var windowManager: WindowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private var overlayView: ImageView? = null
    private var layoutParams: WindowManager.LayoutParams? = null

    private val prefs: SharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

    private val imageLoader = ImageLoader.Builder(context)
        .components {
            if (Build.VERSION.SDK_INT >= 28) {
                add(ImageDecoderDecoder.Factory())
            } else {
                add(GifDecoder.Factory())
            }
        }
        .build()

    private var currentImageSize: Int = getSizeInPx("M")
    private var isLockScreen: Boolean = true

    private fun getSizeInPx(sizeName: String): Int {
        val dp = when (sizeName) {
            "XS" -> 32f
            "S" -> 64f
            "M" -> 96f
            "L" -> 128f
            "XL" -> 160f
            else -> 96f
        }
        val metrics: DisplayMetrics = context.resources.displayMetrics
        return (dp * metrics.density).toInt()
    }

    private fun clampPosition() {
        if (!isLockScreen || layoutParams == null) return
        val metrics: DisplayMetrics = context.resources.displayMetrics
        val screenWidth = metrics.widthPixels
        val screenHeight = metrics.heightPixels
        val maxX = screenWidth - currentImageSize
        val maxY = screenHeight - currentImageSize
        
        if (layoutParams!!.x < 0) layoutParams!!.x = 0
        if (layoutParams!!.x > maxX) layoutParams!!.x = maxX
        if (layoutParams!!.y < 0) layoutParams!!.y = 0
        if (layoutParams!!.y > maxY) layoutParams!!.y = maxY
    }

    @SuppressLint("ClickableViewAccessibility")
    fun showOverlay(imagePath: String, size: String, lockScreen: Boolean = true) {
        isLockScreen = lockScreen
        
        if (overlayView != null) {
            updateImage(imagePath)
            updateSize(size)
            return
        }

        currentImageSize = getSizeInPx(size)

        overlayView = ImageView(context).apply {
            scaleType = ImageView.ScaleType.FIT_CENTER
        }

        val savedX = prefs.getLong("flutter.overlay_pos_x", -1L).toInt()
        val savedY = prefs.getLong("flutter.overlay_pos_y", -1L).toInt()

        layoutParams = WindowManager.LayoutParams(
            currentImageSize,
            currentImageSize,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = if (savedX != -1) savedX else 100
            y = if (savedY != -1) savedY else 100
        }

        clampPosition()
        setupDragging()

        windowManager.addView(overlayView, layoutParams)

        updateImage(imagePath)
    }

    private fun setupDragging() {
        overlayView?.setOnTouchListener(object : View.OnTouchListener {
            private var initialX = 0
            private var initialY = 0
            private var initialTouchX = 0f
            private var initialTouchY = 0f

            override fun onTouch(v: View, event: MotionEvent): Boolean {
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = layoutParams?.x ?: 0
                        initialY = layoutParams?.y ?: 0
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        layoutParams?.x = initialX + (event.rawX - initialTouchX).toInt()
                        layoutParams?.y = initialY + (event.rawY - initialTouchY).toInt()
                        clampPosition()
                        windowManager.updateViewLayout(overlayView, layoutParams)
                        return true
                    }
                    MotionEvent.ACTION_UP -> {
                        saveCurrentPosition()
                        return true
                    }
                }
                return false
            }
        })
    }

    private fun saveCurrentPosition() {
        val editor = prefs.edit()
        editor.putLong("flutter.overlay_pos_x", (layoutParams?.x ?: 0).toLong())
        editor.putLong("flutter.overlay_pos_y", (layoutParams?.y ?: 0).toLong())
        editor.apply()
    }

    fun updateImage(imagePath: String) {
        if (imagePath.isEmpty()) return
        overlayView?.load(File(imagePath), imageLoader) {
            crossfade(true)
        }
    }

    fun updateSize(size: String) {
        if (overlayView == null) return
        currentImageSize = getSizeInPx(size)
        layoutParams?.width = currentImageSize
        layoutParams?.height = currentImageSize
        clampPosition()
        windowManager.updateViewLayout(overlayView, layoutParams)
        saveCurrentPosition()
    }

    fun updateLockScreen(lockScreen: Boolean) {
        isLockScreen = lockScreen
        if (isLockScreen && overlayView != null) {
            clampPosition()
            windowManager.updateViewLayout(overlayView, layoutParams)
            saveCurrentPosition()
        }
    }

    fun resetPosition() {
        if (overlayView == null || layoutParams == null) return
        
        val metrics: DisplayMetrics = context.resources.displayMetrics
        layoutParams?.x = (metrics.widthPixels / 2) - (currentImageSize / 2)
        layoutParams?.y = (metrics.heightPixels / 2) - (currentImageSize / 2)
        
        clampPosition() // Just in case, though it should be centered.
        windowManager.updateViewLayout(overlayView, layoutParams)
        saveCurrentPosition()
    }

    fun removeOverlay() {
        if (overlayView != null) {
            windowManager.removeView(overlayView)
            overlayView = null
        }
    }
}
