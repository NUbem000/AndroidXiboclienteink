package com.xibo.eink.ui.activities

import android.os.Bundle
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager
import androidx.appcompat.app.AppCompatActivity
import com.xibo.eink.databinding.ActivityMainBinding
import com.xibo.eink.eink.EinkDisplayManager
import dagger.hilt.android.AndroidEntryPoint
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    @Inject
    lateinit var einkManager: EinkDisplayManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupFullscreenMode()
        setupEinkDisplay()
        setupClickListeners()

        Timber.i("MainActivity created")
    }

    private fun setupFullscreenMode() {
        // Keep screen on
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        // Hide system bars
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            window.insetsController?.let { controller ->
                controller.hide(WindowInsets.Type.systemBars())
                controller.systemBarsBehavior = WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = (
                    View.SYSTEM_UI_FLAG_FULLSCREEN
                            or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                            or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                            or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                            or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                            or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    )
        }

        // Disable animations
        window.setWindowAnimations(0)
    }

    private fun setupEinkDisplay() {
        // Initialize E-ink manager
        val initialized = einkManager.initialize()

        if (initialized) {
            binding.statusText.text = "✓ E-ink display initialized"
            binding.deviceInfoText.text = buildDeviceInfo()

            // Perform initial full refresh
            einkManager.fullRefresh()

            Timber.i("E-ink display initialized successfully")
        } else {
            binding.statusText.text = "✗ E-ink device not available"
            binding.deviceInfoText.text = "Running in standard display mode"

            Timber.w("E-ink device not available, running in standard mode")
        }
    }

    private fun setupClickListeners() {
        binding.btnFullRefresh.setOnClickListener {
            Timber.d("Full refresh button clicked")
            val success = einkManager.fullRefresh()
            updateRefreshCount()
            showToast(if (success) "Full refresh triggered" else "Full refresh failed")
        }

        binding.btnPartialRefresh.setOnClickListener {
            Timber.d("Partial refresh button clicked")
            val success = einkManager.partialRefresh()
            updateRefreshCount()
            showToast(if (success) "Partial refresh triggered" else "Partial refresh failed")
        }

        binding.btnClear.setOnClickListener {
            Timber.d("Clear screen button clicked")
            val success = einkManager.clearScreen()
            showToast(if (success) "Screen cleared" else "Clear failed")
        }

        binding.btnTestPattern.setOnClickListener {
            Timber.d("Test pattern button clicked")
            showTestPattern()
        }
    }

    private fun buildDeviceInfo(): String {
        val available = einkManager.isDeviceAvailable()
        val refreshCount = einkManager.getRefreshCount()

        return buildString {
            appendLine("Device: ${android.os.Build.MODEL}")
            appendLine("Manufacturer: ${android.os.Build.MANUFACTURER}")
            appendLine("Android: ${android.os.Build.VERSION.RELEASE}")
            appendLine("E-ink Available: ${if (available) "Yes" else "No"}")
            appendLine("Refresh Count: $refreshCount")
        }
    }

    private fun updateRefreshCount() {
        val count = einkManager.getRefreshCount()
        binding.refreshCountText.text = "Refresh Count: $count"
    }

    private fun showTestPattern() {
        // Toggle between black and white for testing
        val isBlack = binding.root.tag as? Boolean ?: false
        binding.root.setBackgroundColor(
            if (isBlack) android.graphics.Color.WHITE else android.graphics.Color.BLACK
        )
        binding.root.tag = !isBlack

        einkManager.partialRefresh()
        updateRefreshCount()
    }

    private fun showToast(message: String) {
        android.widget.Toast.makeText(this, message, android.widget.Toast.LENGTH_SHORT).show()
    }

    override fun onDestroy() {
        super.onDestroy()
        Timber.i("MainActivity destroyed")
    }
}
