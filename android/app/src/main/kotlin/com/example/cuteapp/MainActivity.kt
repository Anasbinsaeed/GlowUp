package com.example.cuteapp

import android.media.RingtoneManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.cuteapp/ringtone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "playDefaultNotification" -> {
                        try {
                            val uri = RingtoneManager.getDefaultUri(
                                RingtoneManager.TYPE_NOTIFICATION
                            )
                            val ringtone = RingtoneManager.getRingtone(applicationContext, uri)
                            ringtone?.play()
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("RINGTONE_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
