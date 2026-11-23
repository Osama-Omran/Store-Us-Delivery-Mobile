package com.storeus.rawbt_direct_share;

import android.app.Activity;
import android.content.ClipData;
import android.content.Context;
import android.content.Intent;
import android.content.ActivityNotFoundException;
import android.net.Uri;

import androidx.core.content.FileProvider;

import java.io.File;
import java.io.IOException;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Sends a PNG receipt to RawBT only, without opening Android's share chooser.
 * Uses a content:// URI with a read grant (never a file:// URI).
 */
public final class RawBtDirectSharePlugin
        implements FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private static final String CHANNEL = "storeus/rawbt_direct_share";
    private static final String RAWBT_PACKAGE = "ru.a402d.rawbtprinter";

    private Context context;
    private Activity activity;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        context = binding.getApplicationContext();
        channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        if (channel != null) {
            channel.setMethodCallHandler(null);
            channel = null;
        }
        context = null;
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (!"sendPng".equals(call.method)) {
            result.notImplemented();
            return;
        }

        if (context == null || activity == null) {
            result.error("NO_ACTIVITY", "No foreground Android activity is attached", null);
            return;
        }

        final String path = call.argument("path");
        if (path == null || path.trim().isEmpty()) {
            result.error("INVALID_PATH", "Receipt PNG path is missing", null);
            return;
        }

        try {
            final File file = new File(path).getCanonicalFile();
            final File allowedDir = new File(context.getCacheDir(), "rawbt_receipts")
                    .getCanonicalFile();
            final String allowedPrefix = allowedDir.getPath() + File.separator;

            if (!file.getPath().startsWith(allowedPrefix)) {
                result.error("INVALID_PATH", "Receipt must be inside the private receipt cache", null);
                return;
            }
            if (!file.isFile() || !file.canRead()) {
                result.error("FILE_NOT_FOUND", "Receipt PNG does not exist", null);
                return;
            }

            final Uri uri = FileProvider.getUriForFile(
                    context,
                    context.getPackageName() + ".storeus_rawbt_files",
                    file
            );

            final Intent intent = new Intent(Intent.ACTION_SEND);
            intent.setType("image/png");
            intent.setPackage(RAWBT_PACKAGE);
            intent.putExtra(Intent.EXTRA_STREAM, uri);
            intent.setClipData(ClipData.newRawUri("Store Us receipt", uri));
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

            // No Intent.createChooser(): RawBT is the only allowed target.
            activity.startActivity(intent);
            result.success(null); // Intent dispatched; actual printing is managed by RawBT.
        } catch (ActivityNotFoundException e) {
            result.error("RAWBT_NOT_INSTALLED", "RawBT Print is not installed or cannot receive PNG", null);
        } catch (SecurityException e) {
            result.error("URI_PERMISSION_DENIED", "RawBT cannot read the receipt image", e.getMessage());
        } catch (IOException | IllegalArgumentException e) {
            result.error("INVALID_RECEIPT", "Could not prepare receipt URI", e.getMessage());
        } catch (Exception e) {
            result.error("RAWBT_SEND_FAILED", "Could not open RawBT", e.getMessage());
        }
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }
}
