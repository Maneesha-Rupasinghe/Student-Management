package com.example.study_manager

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.content.Intent

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.app/badges"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateBadgeCount") {
                val count = call.argument<Int>("count") ?: 0
                val packageName = call.argument<String>("packageName") ?: packageName
                updateBadgeCount(count, packageName)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun updateBadgeCount(count: Int, packageName: String) {
        try {
            val intent = Intent("android.intent.action.BADGE_COUNT_UPDATE")
            intent.putExtra("badge_count", count)
            intent.putExtra("badge_count_package_name", packageName)
            intent.putExtra("badge_count_class_name", MainActivity::class.java.name)
            sendBroadcast(intent)
            println("Badge count updated to $count")
        } catch (e: Exception) {
            println("Error updating badge count: $e")
        }
    }
}
