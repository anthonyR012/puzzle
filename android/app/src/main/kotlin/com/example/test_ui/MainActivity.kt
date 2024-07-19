package com.example.test_ui
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale


class MainActivity: FlutterActivity() {
    private lateinit var methodChannel: MethodChannel
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val binaryMessenger = flutterEngine.dartExecutor.binaryMessenger;
        methodChannel = MethodChannel(binaryMessenger, "com.example/timezone")
        methodChannel.setMethodCallHandler { call, result ->
            // Handle method calls here
            when (call.method) {
                "isAutoTimeZoneEnabled" -> {
                    try{
                        result.success(isAutoTimeZoneEnabled())
                    }catch (e : Exception){
                        result.success("err_"+e.message.toString())
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun isAutoTimeZoneEnabled(): Boolean {
        return Settings.Global.getInt(contentResolver, Settings.Global.AUTO_TIME) > 0
                && Settings.Global.getInt(contentResolver, Settings.Global.AUTO_TIME_ZONE) > 0
    }


}