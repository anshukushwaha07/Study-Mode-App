
// package com.example.study_mode_app

// import io.flutter.embedding.android.FlutterActivity
// import io.flutter.embedding.engine.FlutterEngine
// import io.flutter.plugin.common.MethodChannel
// import android.content.Intent
// import android.content.Context
// import android.content.SharedPreferences
// import android.provider.Settings
// import android.app.AppOpsManager
// import android.os.Process

// class MainActivity: FlutterActivity() {
//     private val CHANNEL = "study_mode_channel"
    
//     private lateinit var appBlockingManager: AppBlockingManager

//     override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//         super.configureFlutterEngine(flutterEngine)
        
//         appBlockingManager = AppBlockingManager(this)
        
//         MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//             when (call.method) {
//                 "checkPermissions" -> {
//                     result.success(hasUsageStatsPermission() && hasOverlayPermission())
//                 }
//                 "requestPermissions" -> {
//                     requestPermissions()
//                     result.success(null)
//                 }
//                 "getStudyModeState" -> {
//                     result.success(getStudyModeState())
//                 }
//                 "setStudyMode" -> {
                    
//                     val enabled = call.argument<Boolean>("enabled") ?: false
//                     val blockedPackages = call.argument<List<String>>("blockedPackages")
                    
                    
//                     setStudyMode(enabled, blockedPackages)
//                     result.success(null)
//                 }
//                 else -> {
//                     result.notImplemented()
//                 }
//             }
//         }
//     }

//     private fun hasUsageStatsPermission(): Boolean {
//         val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
//         val mode = appOps.checkOpNoThrow(
//             AppOpsManager.OPSTR_GET_USAGE_STATS,
//             Process.myUid(),
//             packageName
//         )
//         return mode == AppOpsManager.MODE_ALLOWED
//     }

//     private fun hasOverlayPermission(): Boolean {
//         return Settings.canDrawOverlays(this)
//     }

//     private fun requestPermissions() {
//         if (!hasUsageStatsPermission()) {
//             val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
//             startActivity(intent)
//         }
        
//         if (!hasOverlayPermission()) {
//             val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
//             startActivity(intent)
//         }
//     }

//     private fun getStudyModeState(): Boolean {
//         val sharedPref = getSharedPreferences("study_mode_prefs", Context.MODE_PRIVATE)
//         return sharedPref.getBoolean("study_mode_enabled", false)
//     }

   
//     private fun setStudyMode(enabled: Boolean, blockedPackages: List<String>?) {
//         val sharedPref = getSharedPreferences("study_mode_prefs", Context.MODE_PRIVATE)
//         with(sharedPref.edit()) {
//             putBoolean("study_mode_enabled", enabled)
            
//             if (enabled && blockedPackages != null) {
                
//                 putStringSet("blocked_packages", blockedPackages.toSet())
//             } else {
                
//                 remove("blocked_packages")
//             }
//             apply()
//         }
        
//         if (enabled) {
            
//             appBlockingManager.startBlocking()
//         } else {
            
//             appBlockingManager.stopBlocking()
//         }
//     }
// }


package com.example.study_mode_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.content.Context
import android.content.SharedPreferences
import android.provider.Settings
import android.app.AppOpsManager
import android.os.Process

/**
 * The main and only activity for the Android host of this Flutter application.
 * It handles platform channel communication to manage native Android features
 * like permissions and background services for app blocking.
 */
 
class MainActivity: FlutterActivity() {
    // The unique identifier for the MethodChannel. Must match the one in the Flutter code.
    private val CHANNEL = "study_mode_channel"
    
    // Manages the lifecycle of the background service responsible for app blocking.
    private lateinit var appBlockingManager: AppBlockingManager

    /**
     * Sets up the connection between Flutter and the native Android platform.
     * This is where the MethodChannel and its handlers are registered.
     */
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize the manager for the app blocking service.
        appBlockingManager = AppBlockingManager(this)
        
        // Create a MethodChannel to receive calls from the Flutter UI.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            // Route method calls from Flutter to the appropriate native function.
            when (call.method) {
                // Handles the call to check if all necessary permissions are granted.
                "checkPermissions" -> {
                    result.success(hasUsageStatsPermission() && hasOverlayPermission())
                }
                // Handles the call to request permissions from the user.
                "requestPermissions" -> {
                    requestPermissions()
                    result.success(null)
                }
                // Handles the call to get the current saved state of Study Mode.
                "getStudyModeState" -> {
                    result.success(getStudyModeState())
                }
                // Handles the call to enable or disable Study Mode.
                "setStudyMode" -> {
                    // Extract arguments from the Flutter call.
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    val blockedPackages = call.argument<List<String>>("blockedPackages")
                    
                    // Call the native function to update the state.
                    setStudyMode(enabled, blockedPackages)
                    result.success(null)
                }
                // Handle any unknown method calls.
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Checks if the app has been granted "Usage Access" permission.
     * This is required to see which app is currently in the foreground.
     */
    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    /**
     * Checks if the app has been granted "Display over other apps" permission.
     * This is required to show the blocking screen on top of a blocked app.
     */
    private fun hasOverlayPermission(): Boolean {
        return Settings.canDrawOverlays(this)
    }

    /**
     * Launches the system settings screens for the user to grant the required permissions.
     */
    private fun requestPermissions() {
        // Open Usage Access settings if permission is not granted.
        if (!hasUsageStatsPermission()) {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            startActivity(intent)
        }
        
        // Open Overlay settings if permission is not granted.
        if (!hasOverlayPermission()) {
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
            startActivity(intent)
        }
    }

    /**
     * Retrieves the saved on/off state of Study Mode from SharedPreferences.
     */
    private fun getStudyModeState(): Boolean {
        val sharedPref = getSharedPreferences("study_mode_prefs", Context.MODE_PRIVATE)
        return sharedPref.getBoolean("study_mode_enabled", false)
    }

   
    /**
     * Updates the Study Mode state, saves it to SharedPreferences, and starts or stops
     * the app blocking service accordingly.
     *
     * @param enabled True to enable Study Mode, false to disable it.
     * @param blockedPackages A list of app package names to block when Study Mode is enabled.
     */
    private fun setStudyMode(enabled: Boolean, blockedPackages: List<String>?) {
        val sharedPref = getSharedPreferences("study_mode_prefs", Context.MODE_PRIVATE)
        with(sharedPref.edit()) {
            // Save the current on/off state.
            putBoolean("study_mode_enabled", enabled)
            
            // If enabling and a list is provided, save the list of blocked apps.
            if (enabled && blockedPackages != null) {
                putStringSet("blocked_packages", blockedPackages.toSet())
            } else {
                // If disabling, remove the old list of blocked apps.
                remove("blocked_packages")
            }
            apply() // Asynchronously save the changes.
        }
        
        // Start or stop the background service based on the new state.
        if (enabled) {
            appBlockingManager.startBlocking()
        } else {
            appBlockingManager.stopBlocking()
        }
    }
}