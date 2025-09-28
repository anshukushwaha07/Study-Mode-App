package com.example.study_mode_app

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.app.usage.UsageStatsManager
import java.util.*

class AppBlockingManager(private val context: Context) {
    // We REMOVE the hardcoded list from here.
    // private val blockedPackages = setOf(...)

    private val handler = Handler(Looper.getMainLooper())
    private var monitoringRunnable: Runnable? = null
    private var isMonitoring = false

    fun startBlocking() {
        if (isMonitoring) return
        
        isMonitoring = true
        startAppMonitoring()
    }

    fun stopBlocking() {
        isMonitoring = false
        monitoringRunnable?.let { handler.removeCallbacks(it) }
    }

    private fun startAppMonitoring() {
        monitoringRunnable = object : Runnable {
            override fun run() {
                if (!isMonitoring) return
                
                checkAndBlockApps()
                handler.postDelayed(this, 1000) // Check every second
            }
        }
        handler.post(monitoringRunnable!!)
    }

    // This is the main updated function
    private fun checkAndBlockApps() {
        // 1. Get the SharedPreferences instance, the same one we used in MainActivity
        val sharedPref = context.getSharedPreferences("study_mode_prefs", Context.MODE_PRIVATE)

        // 2. Read the list of blocked packages we saved earlier.
        // If no list is found, it defaults to an empty set.
        val blockedPackages = sharedPref.getStringSet("blocked_packages", emptySet()) ?: emptySet()
        
        // 3. If the list is empty, there's nothing to do
        if (blockedPackages.isEmpty()) {
            return
        }

        // 4. Get the current app in the foreground
        val currentApp = getCurrentForegroundApp()
        
        // 5. Check if the current app is in our DYNAMIC list
        if (currentApp in blockedPackages) {
            blockCurrentApp()
        }
    }

    private fun getCurrentForegroundApp(): String? {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val currentTime = System.currentTimeMillis()
        
        // Get usage stats for the last 1 minute
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            currentTime - 60000,
            currentTime
        )
        
        if (stats != null && stats.isNotEmpty()) {
            // Find the most recently used app
            return stats.maxByOrNull { it.lastTimeUsed }?.packageName
        }
        
        return null
    }

    private fun blockCurrentApp() {
        // This brings your blocking screen to the front
        val intent = Intent(context, BlockingActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                   Intent.FLAG_ACTIVITY_CLEAR_TOP or
                   Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        context.startActivity(intent)
    }
}
