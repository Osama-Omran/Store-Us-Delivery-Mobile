package com.storeus.usb_esc_pos;

import android.Manifest;
import android.app.Activity;
import android.app.PendingIntent;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothSocket;
import android.content.pm.PackageManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.hardware.usb.UsbConstants;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbDeviceConnection;
import android.hardware.usb.UsbEndpoint;
import android.hardware.usb.UsbInterface;
import android.hardware.usb.UsbManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.text.Layout;
import android.text.StaticLayout;
import android.text.TextDirectionHeuristics;
import android.text.TextPaint;

import androidx.annotation.NonNull;

import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/**
 * Android USB OTG and paired Bluetooth Classic (RFCOMM SPP) ESC/POS printer bridge.
 * Arabic is rasterized with Android's bidi-aware StaticLayout rather than
 * sent as printer codepage text.
 * Hardware-specific printer support must be verified on a real device.
 */
public final class UsbEscPosPrinterPlugin implements FlutterPlugin,
        ActivityAware, PluginRegistry.RequestPermissionsResultListener,
        MethodChannel.MethodCallHandler {
    private static final String CHANNEL = "storeus/usb_esc_pos";
    private static final String USB_PERMISSION_ACTION =
            "com.storeus.usb_esc_pos.USB_PERMISSION";
    private static final int PAPER_DOTS = 576; // Typical printable width on 80 mm / 203 dpi.
    private static final int BT_CONNECT_PERMISSION_REQUEST = 7843;
    private static final UUID SPP_UUID =
            UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");

    private Context context;
    private UsbManager usbManager;
    private BluetoothAdapter bluetoothAdapter;
    private Activity activity;
    private ActivityPluginBinding activityBinding;
    private MethodChannel.Result pendingBluetoothListResult;
    private MethodChannel channel;
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private final ExecutorService worker = Executors.newSingleThreadExecutor();

    private MethodChannel.Result pendingResult;
    private List<Map<String, Object>> pendingLines;
    private int pendingDeviceId;
    private boolean receiverRegistered;
    private boolean waitingForUsbPermission;

    private final BroadcastReceiver permissionReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context receiverContext, Intent intent) {
            if (!USB_PERMISSION_ACTION.equals(intent.getAction()) ||
                    pendingResult == null || !waitingForUsbPermission) {
                return;
            }
            UsbDevice device = findDevice(pendingDeviceId);
            if (device != null && usbManager.hasPermission(device)) {
                startPrint(device);
            } else {
                finishError("USB_PERMISSION_DENIED", "USB printer permission denied");
            }
        }
    };

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        context = binding.getApplicationContext();
        usbManager = (UsbManager) context.getSystemService(Context.USB_SERVICE);
        BluetoothManager manager =
                (BluetoothManager) context.getSystemService(Context.BLUETOOTH_SERVICE);
        bluetoothAdapter = manager == null ? null : manager.getAdapter();
        channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(this);
        IntentFilter filter = new IntentFilter(USB_PERMISSION_ACTION);
        if (Build.VERSION.SDK_INT >= 33) {
            context.registerReceiver(permissionReceiver, filter, Context.RECEIVER_NOT_EXPORTED);
        } else {
            context.registerReceiver(permissionReceiver, filter);
        }
        receiverRegistered = true;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityBinding = binding;
        activity = binding.getActivity();
        binding.addRequestPermissionsResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        if (activityBinding != null) {
            activityBinding.removeRequestPermissionsResultListener(this);
        }
        activityBinding = null;
        activity = null;
    }

    @Override
    public boolean onRequestPermissionsResult(
            int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode != BT_CONNECT_PERMISSION_REQUEST ||
                pendingBluetoothListResult == null) return false;
        MethodChannel.Result pending = pendingBluetoothListResult;
        pendingBluetoothListResult = null;
        if (grantResults.length > 0 &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            listBluetoothDevices(pending);
        } else {
            pending.error("BT_PERMISSION_DENIED", "Nearby devices permission denied", null);
        }
        return true;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (pendingResult != null) {
            finishError("PRINTER_DISCONNECTED", "Printer connection closed");
        }
        if (pendingBluetoothListResult != null) {
            pendingBluetoothListResult.error(
                    "BT_PERMISSION_DENIED", "Printer connection closed", null);
            pendingBluetoothListResult = null;
        }
        if (receiverRegistered) {
            context.unregisterReceiver(permissionReceiver);
            receiverRegistered = false;
        }
        channel.setMethodCallHandler(null);
        channel = null;
        context = null;
        usbManager = null;
        bluetoothAdapter = null;
        worker.shutdown();
    }

    @Override
    @SuppressWarnings("unchecked")
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if ("listDevices".equals(call.method)) {
            List<Map<String, Object>> devices = new ArrayList<>();
            for (UsbDevice device : usbManager.getDeviceList().values()) {
                if (findOutput(device) == null) continue;
                Map<String, Object> map = new HashMap<>();
                map.put("deviceId", device.getDeviceId());
                String productName = safeProductName(device);
                map.put("name", productName != null
                        ? productName : device.getDeviceName());
                map.put("vendorId", device.getVendorId());
                map.put("productId", device.getProductId());
                map.put("likelyPrinter", isLikelyPrinter(device));
                devices.add(map);
            }
            result.success(devices);
            return;
        }
        if ("listBluetoothDevices".equals(call.method)) {
            listBluetoothDevices(result);
            return;
        }
        if ("printBluetooth".equals(call.method)) {
            printBluetooth(call, result);
            return;
        }
        if (!"print".equals(call.method)) {
            result.notImplemented();
            return;
        }
        if (pendingResult != null) {
            result.error("PRINTER_BUSY", "Another print is in progress", null);
            return;
        }
        Integer deviceId = call.argument("deviceId");
        List<Map<String, Object>> lines = call.argument("lines");
        if (deviceId == null || lines == null || lines.isEmpty()) {
            result.error("USB_PRINT_FAILED", "Missing printer or receipt lines", null);
            return;
        }
        UsbDevice device = findDevice(deviceId);
        if (device == null || findOutput(device) == null) {
            result.error("USB_DEVICE_MISSING", "USB printer disconnected", null);
            return;
        }
        pendingResult = result;
        pendingDeviceId = deviceId;
        pendingLines = lines;
        if (usbManager.hasPermission(device)) {
            startPrint(device);
            return;
        }
        try {
            waitingForUsbPermission = true;
            Intent permissionIntent = new Intent(USB_PERMISSION_ACTION);
            permissionIntent.setPackage(context.getPackageName());
            PendingIntent permission = PendingIntent.getBroadcast(
                    context,
                    0,
                    permissionIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_MUTABLE
            );
            usbManager.requestPermission(device, permission);
        } catch (Exception error) {
            finishError("USB_PERMISSION_DENIED", error.getMessage());
        }
    }

    private boolean hasBluetoothPermission() {
        return Build.VERSION.SDK_INT < 31 ||
                context.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT)
                        == PackageManager.PERMISSION_GRANTED;
    }

    private void listBluetoothDevices(MethodChannel.Result result) {
        if (bluetoothAdapter == null) {
            result.error("BT_UNAVAILABLE", "Bluetooth is not supported", null);
            return;
        }
        if (!hasBluetoothPermission()) {
            if (activity == null || pendingBluetoothListResult != null) {
                result.error("BT_PERMISSION_DENIED", "Bluetooth permission unavailable", null);
                return;
            }
            pendingBluetoothListResult = result;
            activity.requestPermissions(
                    new String[] {Manifest.permission.BLUETOOTH_CONNECT},
                    BT_CONNECT_PERMISSION_REQUEST);
            return;
        }
        try {
            if (!bluetoothAdapter.isEnabled()) {
                result.error("BT_DISABLED", "Bluetooth is disabled", null);
                return;
            }
            Set<BluetoothDevice> bonded = bluetoothAdapter.getBondedDevices();
            List<Map<String, Object>> devices = new ArrayList<>();
            for (BluetoothDevice device : bonded) {
                Map<String, Object> entry = new HashMap<>();
                String name = device.getName();
                entry.put("name", name == null || name.isEmpty()
                        ? "Bluetooth device" : name);
                entry.put("address", device.getAddress());
                devices.add(entry);
            }
            devices.sort((a, b) -> String.valueOf(a.get("name"))
                    .compareToIgnoreCase(String.valueOf(b.get("name"))));
            result.success(devices);
        } catch (SecurityException error) {
            result.error("BT_PERMISSION_DENIED", error.getMessage(), null);
        }
    }

    @SuppressWarnings("unchecked")
    private void printBluetooth(MethodCall call, MethodChannel.Result result) {
        if (pendingResult != null) {
            result.error("PRINTER_BUSY", "Another print is in progress", null);
            return;
        }
        if (bluetoothAdapter == null) {
            result.error("BT_UNAVAILABLE", "Bluetooth is not supported", null);
            return;
        }
        if (!hasBluetoothPermission()) {
            result.error("BT_PERMISSION_DENIED", "Nearby devices permission required", null);
            return;
        }
        try {
            if (!bluetoothAdapter.isEnabled()) {
                result.error("BT_DISABLED", "Bluetooth is disabled", null);
                return;
            }
            String address = call.argument("address");
            List<Map<String, Object>> lines = call.argument("lines");
            if (address == null || lines == null || lines.isEmpty()) {
                result.error("BT_PRINT_FAILED", "Missing printer or receipt lines", null);
                return;
            }
            BluetoothDevice device = bluetoothAdapter.getRemoteDevice(address);
            if (!bluetoothAdapter.getBondedDevices().contains(device)) {
                result.error("BT_DEVICE_MISSING", "Printer is not paired", null);
                return;
            }
            pendingResult = result;
            worker.execute(() -> {
                try {
                    printToBluetooth(device, lines);
                    mainHandler.post(this::finishSuccess);
                } catch (Exception error) {
                    mainHandler.post(() ->
                            finishError("BT_PRINT_FAILED", error.getMessage()));
                }
            });
        } catch (IllegalArgumentException error) {
            result.error("BT_DEVICE_MISSING", "Invalid Bluetooth address", null);
        } catch (SecurityException error) {
            result.error("BT_PERMISSION_DENIED", error.getMessage(), null);
        }
    }

    private void printToBluetooth(BluetoothDevice device,
                                  List<Map<String, Object>> lines) throws Exception {
        // Bluetooth Classic SPP. BLE-only printers need a different transport.
        try (BluetoothSocket socket = device.createRfcommSocketToServiceRecord(SPP_UUID)) {
            socket.connect();
            OutputStream stream = socket.getOutputStream();
            printReceipt(stream::write, lines);
            stream.flush();
        }
    }

    private UsbDevice findDevice(int id) {
        if (usbManager == null) return null;
        for (UsbDevice device : usbManager.getDeviceList().values()) {
            if (device.getDeviceId() == id) return device;
        }
        return null;
    }

    private static String safeProductName(UsbDevice device) {
        try {
            return device.getProductName();
        } catch (SecurityException ignored) {
            return null;
        }
    }

    private static boolean isLikelyPrinter(UsbDevice device) {
        if (device.getDeviceClass() == UsbConstants.USB_CLASS_PRINTER) return true;
        for (int i = 0; i < device.getInterfaceCount(); i++) {
            if (device.getInterface(i).getInterfaceClass() == UsbConstants.USB_CLASS_PRINTER) {
                return true;
            }
        }
        String product = safeProductName(device);
        if (product == null) return false;
        String lower = product.toLowerCase(java.util.Locale.ROOT);
        return lower.contains("printer") || lower.contains("xprinter") ||
                lower.contains("xp-p802") || lower.contains("receipt");
    }

    private static final class Output {
        final UsbInterface usbInterface;
        final UsbEndpoint endpoint;

        Output(UsbInterface usbInterface, UsbEndpoint endpoint) {
            this.usbInterface = usbInterface;
            this.endpoint = endpoint;
        }
    }

    private static Output findOutput(UsbDevice device) {
        for (int i = 0; i < device.getInterfaceCount(); i++) {
            UsbInterface usbInterface = device.getInterface(i);
            for (int j = 0; j < usbInterface.getEndpointCount(); j++) {
                UsbEndpoint endpoint = usbInterface.getEndpoint(j);
                if (endpoint.getType() == UsbConstants.USB_ENDPOINT_XFER_BULK &&
                        endpoint.getDirection() == UsbConstants.USB_DIR_OUT) {
                    return new Output(usbInterface, endpoint);
                }
            }
        }
        return null;
    }

    private void startPrint(UsbDevice device) {
        waitingForUsbPermission = false;
        final List<Map<String, Object>> lines = pendingLines;
        worker.execute(() -> {
            try {
                printToUsb(device, lines);
                mainHandler.post(() -> finishSuccess());
            } catch (Exception error) {
                mainHandler.post(() -> finishError("USB_PRINT_FAILED", error.getMessage()));
            }
        });
    }

    private void finishSuccess() {
        MethodChannel.Result result = pendingResult;
        pendingResult = null;
        pendingLines = null;
        waitingForUsbPermission = false;
        if (result != null) result.success(null);
    }

    private void finishError(String code, String message) {
        MethodChannel.Result result = pendingResult;
        pendingResult = null;
        pendingLines = null;
        waitingForUsbPermission = false;
        if (result != null) result.error(code, message, null);
    }

    private void printToUsb(UsbDevice device, List<Map<String, Object>> lines) throws Exception {
        Output output = findOutput(device);
        if (output == null) throw new Exception("No bulk OUT endpoint");
        UsbDeviceConnection connection = usbManager.openDevice(device);
        if (connection == null) throw new Exception("Cannot open USB printer");
        boolean claimed = false;
        try {
            claimed = connection.claimInterface(output.usbInterface, true);
            if (!claimed) throw new Exception("Cannot claim USB printer interface");
            printReceipt(bytes -> writeUsb(connection, output.endpoint, bytes), lines);
        } finally {
            if (claimed) connection.releaseInterface(output.usbInterface);
            connection.close();
        }
    }

    private interface EscPosOutput {
        void write(byte[] bytes) throws Exception;
    }

    private static void printReceipt(EscPosOutput output,
                                     List<Map<String, Object>> lines) throws Exception {
        output.write(new byte[] {0x1b, 0x40}); // ESC @ initialize
        for (Map<String, Object> line : lines) {
            Bitmap bitmap = drawLine(line);
            try {
                sendRaster(output, bitmap);
            } finally {
                bitmap.recycle();
            }
        }
        output.write(new byte[] {0x1b, 0x64, 0x04}); // feed 4 lines
    }

    private static Bitmap drawLine(Map<String, Object> line) {
        if (Boolean.TRUE.equals(line.get("divider"))) {
            Bitmap divider = Bitmap.createBitmap(PAPER_DOTS, 14, Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(divider);
            canvas.drawColor(Color.WHITE);
            Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
            paint.setColor(Color.BLACK);
            paint.setStrokeWidth(2);
            canvas.drawLine(8, 7, PAPER_DOTS - 8, 7, paint);
            return divider;
        }

        String text = String.valueOf(line.get("text"));
        int fontSize = line.get("size") instanceof Number
                ? ((Number) line.get("size")).intValue() : 23;
        fontSize = Math.max(15, Math.min(fontSize, 48));
        boolean bold = Boolean.TRUE.equals(line.get("bold"));
        String alignment = String.valueOf(line.get("align"));
        boolean ltr = "ltr".equals(line.get("direction"));

        TextPaint paint = new TextPaint(Paint.ANTI_ALIAS_FLAG);
        paint.setColor(Color.BLACK);
        paint.setTextSize(fontSize);
        paint.setTypeface(Typeface.create("sans-serif", bold ? Typeface.BOLD : Typeface.NORMAL));
        int contentWidth = PAPER_DOTS - 24;
        Layout.Alignment align = Layout.Alignment.ALIGN_NORMAL;
        if ("center".equals(alignment)) align = Layout.Alignment.ALIGN_CENTER;
        if ("left".equals(alignment)) align = ltr
                ? Layout.Alignment.ALIGN_NORMAL : Layout.Alignment.ALIGN_OPPOSITE;

        StaticLayout layout = StaticLayout.Builder.obtain(text, 0, text.length(), paint, contentWidth)
                .setAlignment(align)
                .setTextDirection(ltr ? TextDirectionHeuristics.LTR : TextDirectionHeuristics.RTL)
                .setIncludePad(false)
                .build();
        int height = Math.max(18, layout.getHeight() + 12);
        Bitmap bitmap = Bitmap.createBitmap(PAPER_DOTS, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        canvas.drawColor(Color.WHITE);
        canvas.translate(12, 6);
        layout.draw(canvas);
        return bitmap;
    }

    private static void sendRaster(EscPosOutput output, Bitmap bitmap) throws Exception {
        final int widthBytes = (PAPER_DOTS + 7) / 8;
        int[] pixels = new int[PAPER_DOTS * 64];
        for (int top = 0; top < bitmap.getHeight(); top += 64) {
            int rows = Math.min(64, bitmap.getHeight() - top);
            bitmap.getPixels(pixels, 0, PAPER_DOTS, 0, top, PAPER_DOTS, rows);
            byte[] raster = new byte[widthBytes * rows];
            for (int y = 0; y < rows; y++) {
                for (int x = 0; x < PAPER_DOTS; x++) {
                    int pixel = pixels[y * PAPER_DOTS + x];
                    int r = Color.red(pixel);
                    int g = Color.green(pixel);
                    int b = Color.blue(pixel);
                    if (Color.alpha(pixel) > 127 && (r + g + b) < 510) {
                        raster[y * widthBytes + x / 8] |= (byte) (0x80 >> (x % 8));
                    }
                }
            }
            // GS v 0, normal-density raster bitmap, x bytes, y dots.
            byte[] header = new byte[] {
                    0x1d, 0x76, 0x30, 0x00,
                    (byte) (widthBytes & 0xff), (byte) ((widthBytes >> 8) & 0xff),
                    (byte) (rows & 0xff), (byte) ((rows >> 8) & 0xff)
            };
            output.write(header);
            output.write(raster);
        }
    }

    private static void writeUsb(UsbDeviceConnection connection,
                                 UsbEndpoint endpoint, byte[] bytes) throws Exception {
        int offset = 0;
        while (offset < bytes.length) {
            int count = Math.min(1024, bytes.length - offset);
            byte[] chunk = Arrays.copyOfRange(bytes, offset, offset + count);
            int written = connection.bulkTransfer(endpoint, chunk, count, 10000);
            if (written <= 0) throw new Exception("USB bulk transfer failed");
            offset += written;
        }
    }
}
