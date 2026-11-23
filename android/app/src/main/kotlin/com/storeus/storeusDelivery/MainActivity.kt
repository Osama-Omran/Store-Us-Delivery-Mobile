package com.storeus.storeusDelivery

import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import android.util.Log
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * RawBT integration lives in the application, not a separately registered Flutter plugin.
 * Flutter invokes: MethodChannel("storeus/rawbt_direct_share").invokeMethod("sendPng", {"path": ...}).
 */
class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "StoreUsRawBT"
        private const val CHANNEL = "storeus/rawbt_direct_share"
        private const val RAWBT_PACKAGE = "ru.a402d.rawbtprinter"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "sendPng" -> sendPng(call.argument<String>("path"), result)
                    else -> result.notImplemented()
                }
            }

        Log.i(TAG, "sendPng handler registered in MainActivity")
    }

    private fun sendPng(path: String?, result: MethodChannel.Result) {
        if (path.isNullOrBlank()) {
            result.error("INVALID_PATH", "Receipt image path is missing", null)
            return
        }

        try {
            val allowedDirectory = File(cacheDir, "rawbt_receipts").canonicalFile
            val receipt = File(path).canonicalFile

            if (!receipt.path.startsWith(allowedDirectory.path + File.separator)) {
                result.error("INVALID_PATH", "Receipt is outside the approved cache directory", null)
                return
            }

            if (!receipt.isFile || !receipt.canRead()) {
                result.error("FILE_NOT_FOUND", "Receipt image does not exist", null)
                return
            }

            val receiptUri = FileProvider.getUriForFile(
                this,
                "$packageName.storeus_rawbt_app_files",
                receipt
            )

            val sendIntent = Intent(Intent.ACTION_SEND).apply {
                type = "image/png"
                setPackage(RAWBT_PACKAGE)
                putExtra(Intent.EXTRA_STREAM, receiptUri)
                clipData = ClipData.newRawUri("Store Us receipt", receiptUri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }

            // Directly targets RawBT; does not open the Android share chooser.
            startActivity(sendIntent)
            Log.i(TAG, "RawBT intent dispatched: ${receipt.name}")
            result.success(null) // Only means dispatched, not physically printed.
        } catch (error: ActivityNotFoundException) {
            Log.e(TAG, "RawBT is not installed or cannot handle PNG", error)
            result.error("RAWBT_NOT_INSTALLED", "RawBT Print is not installed", null)
        } catch (error: SecurityException) {
            Log.e(TAG, "Cannot grant access to receipt image", error)
            result.error("URI_PERMISSION_DENIED", error.message, null)
        } catch (error: IllegalArgumentException) {
            Log.e(TAG, "Invalid receipt URI / FileProvider configuration", error)
            result.error("INVALID_RECEIPT", error.message, null)
        } catch (error: Exception) {
            Log.e(TAG, "Failed to open RawBT", error)
            result.error("RAWBT_SEND_FAILED", error.message, null)
        }
    }
}
