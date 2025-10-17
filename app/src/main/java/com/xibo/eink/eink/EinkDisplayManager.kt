package com.xibo.eink.eink

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Paint
import timber.log.Timber
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Manager for E-ink display control
 * Handles refresh modes, ghosting prevention, and bitmap optimization
 */
@Singleton
class EinkDisplayManager @Inject constructor(
    private val context: Context
) {

    companion object {
        // Refresh modes
        const val MODE_INIT = 0
        const val MODE_DU = 1         // Direct Update (fast)
        const val MODE_GC16 = 2       // Grayscale 16 (quality)
        const val MODE_GL16 = 3       // Grayscale 16
        const val MODE_A2 = 4         // Animation (fastest)
        const val MODE_FULL = 5       // Full refresh
        const val MODE_PARTIAL = 6    // Partial refresh

        init {
            System.loadLibrary("eink_controller")
        }
    }

    private var isInitialized = false
    private var currentMode = MODE_GC16

    // Native methods
    private external fun nativeInit(): Boolean
    private external fun nativeRelease()
    private external fun nativeFullRefresh(): Boolean
    private external fun nativePartialRefresh(): Boolean
    private external fun nativeSetRefreshMode(mode: Int): Boolean
    private external fun nativeClearScreen(): Boolean
    private external fun nativeGetRefreshCount(): Int
    private external fun nativeIsDeviceAvailable(): Boolean

    /**
     * Initialize the E-ink controller
     */
    fun initialize(): Boolean {
        if (isInitialized) {
            Timber.d("E-ink controller already initialized")
            return true
        }

        Timber.i("Initializing E-ink controller...")

        return try {
            isInitialized = nativeInit()
            if (isInitialized) {
                Timber.i("E-ink controller initialized successfully")
                setRefreshMode(MODE_GC16)
            } else {
                Timber.e("Failed to initialize E-ink controller")
            }
            isInitialized
        } catch (e: Exception) {
            Timber.e(e, "Error initializing E-ink controller")
            false
        }
    }

    /**
     * Release the E-ink controller
     */
    fun release() {
        if (!isInitialized) return

        try {
            nativeRelease()
            isInitialized = false
            Timber.i("E-ink controller released")
        } catch (e: Exception) {
            Timber.e(e, "Error releasing E-ink controller")
        }
    }

    /**
     * Perform full screen refresh (clears ghosting)
     */
    fun fullRefresh(): Boolean {
        if (!ensureInitialized()) return false

        return try {
            val result = nativeFullRefresh()
            Timber.d("Full refresh: ${if (result) "success" else "failed"}")
            result
        } catch (e: Exception) {
            Timber.e(e, "Error during full refresh")
            false
        }
    }

    /**
     * Perform partial screen refresh (faster, but may cause ghosting)
     */
    fun partialRefresh(): Boolean {
        if (!ensureInitialized()) return false

        return try {
            val result = nativePartialRefresh()
            Timber.d("Partial refresh: ${if (result) "success" else "failed"}")
            result
        } catch (e: Exception) {
            Timber.e(e, "Error during partial refresh")
            false
        }
    }

    /**
     * Set refresh mode
     */
    fun setRefreshMode(mode: Int): Boolean {
        if (!ensureInitialized()) return false

        return try {
            val result = nativeSetRefreshMode(mode)
            if (result) {
                currentMode = mode
                Timber.d("Refresh mode set to: $mode")
            }
            result
        } catch (e: Exception) {
            Timber.e(e, "Error setting refresh mode")
            false
        }
    }

    /**
     * Clear screen
     */
    fun clearScreen(): Boolean {
        if (!ensureInitialized()) return false

        return try {
            nativeClearScreen()
        } catch (e: Exception) {
            Timber.e(e, "Error clearing screen")
            false
        }
    }

    /**
     * Get current refresh count
     */
    fun getRefreshCount(): Int {
        return try {
            nativeGetRefreshCount()
        } catch (e: Exception) {
            Timber.e(e, "Error getting refresh count")
            0
        }
    }

    /**
     * Check if E-ink device is available
     */
    fun isDeviceAvailable(): Boolean {
        return try {
            nativeIsDeviceAvailable()
        } catch (e: Exception) {
            Timber.e(e, "Error checking device availability")
            false
        }
    }

    /**
     * Optimize bitmap for E-ink display
     * Applies dithering and contrast enhancement
     */
    fun optimizeBitmap(source: Bitmap): Bitmap {
        Timber.d("Optimizing bitmap for E-ink: ${source.width}x${source.height}")

        // Create mutable copy
        val optimized = Bitmap.createBitmap(source.width, source.height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(optimized)

        // Apply contrast and brightness adjustments
        val paint = Paint().apply {
            colorFilter = createEinkColorFilter()
            isAntiAlias = false
            isDither = true
        }

        canvas.drawBitmap(source, 0f, 0f, paint)

        return optimized
    }

    /**
     * Create color filter optimized for E-ink
     * Increases contrast and converts to grayscale
     */
    private fun createEinkColorFilter(): ColorMatrixColorFilter {
        val matrix = ColorMatrix().apply {
            // Convert to grayscale
            setSaturation(0f)

            // Increase contrast
            val contrast = 1.3f
            val offset = (1 - contrast) / 2 * 255

            val contrastMatrix = floatArrayOf(
                contrast, 0f, 0f, 0f, offset,
                0f, contrast, 0f, 0f, offset,
                0f, 0f, contrast, 0f, offset,
                0f, 0f, 0f, 1f, 0f
            )

            postConcat(ColorMatrix(contrastMatrix))
        }

        return ColorMatrixColorFilter(matrix)
    }

    private fun ensureInitialized(): Boolean {
        if (!isInitialized) {
            Timber.w("E-ink controller not initialized, attempting to initialize...")
            return initialize()
        }
        return true
    }
}
