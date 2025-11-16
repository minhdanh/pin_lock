package nl.dutchcodingcompany.pin_lock

import android.app.Activity
import android.view.WindowManager.LayoutParams
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** PinLockPlugin */
class PinLockPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var hideAppContent: Boolean = true
    private var blockScreenshots: Boolean = true

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "pin_lock")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "setHideAppContent" -> {
                (call.arguments as? Map<*, *>)?.let { arguments ->
                    (arguments["shouldHide"] as? Boolean)?.let { shouldHide ->
                        hideAppContent = shouldHide
                    }
                    (arguments["blockScreenshots"] as? Boolean)?.let { block ->
                        blockScreenshots = block
                    }
                    updateSecureFlag()
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }

    }

    private fun updateSecureFlag() {
        if (hideAppContent && blockScreenshots) {
            activity?.window?.addFlags(LayoutParams.FLAG_SECURE)
        } else {
            activity?.window?.clearFlags(LayoutParams.FLAG_SECURE)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        updateSecureFlag()
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        updateSecureFlag()
    }

    override fun onDetachedFromActivity() {
        activity = null
    }


}
