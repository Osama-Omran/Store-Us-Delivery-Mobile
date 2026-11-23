import 'package:flutter/services.dart';

/// Legacy native USB bridge kept for compatibility with existing callers.
/// The Store Us receipt actions currently send PNG directly to RawBT.
class UsbEscPosPrinter {
  UsbEscPosPrinter._();

  static const MethodChannel _channel = MethodChannel('storeus/usb_esc_pos');

  static Future<List<UsbPrinterDevice>> availableDevices() async {
    final result = await _channel.invokeListMethod<dynamic>('listDevices');
    return (result ?? const <dynamic>[])
        .whereType<Map>()
        .map((value) => UsbPrinterDevice.fromMap(value))
        .toList(growable: false);
  }

  static Future<void> print({
    required UsbPrinterDevice device,
    required ReceiptDocument receipt,
  }) async {
    if (receipt.lines.isEmpty) throw StateError('Nothing to print');
    await _channel.invokeMethod<void>('print', <String, dynamic>{
      'deviceId': device.deviceId,
      'lines': receipt.lines.map((line) => line.toMap()).toList(),
    });
  }
}

class UsbPrinterDevice {
  const UsbPrinterDevice({
    required this.deviceId,
    required this.name,
    required this.vendorId,
    required this.productId,
    required this.likelyPrinter,
  });

  final int deviceId;
  final String name;
  final int vendorId;
  final int productId;
  final bool likelyPrinter;

  factory UsbPrinterDevice.fromMap(Map<dynamic, dynamic> map) {
    return UsbPrinterDevice(
      deviceId: (map['deviceId'] as num).toInt(),
      name: map['name']?.toString() ?? 'USB printer',
      vendorId: (map['vendorId'] as num).toInt(),
      productId: (map['productId'] as num).toInt(),
      likelyPrinter: map['likelyPrinter'] == true,
    );
  }
}

class ReceiptDocument {
  const ReceiptDocument(this.lines);
  final List<ReceiptLine> lines;
}

/// Print layout metadata is optional, preserving old ReceiptLine callers.
/// `text` remains a complete fallback for the legacy USB ESC/POS bridge.
class ReceiptLine {
  const ReceiptLine(
    this.text, {
    this.size = 23,
    this.bold = false,
    this.align = 'right',
    this.direction = 'rtl',
    this.divider = false,
    this.kind = 'text',
  })  : label = null,
        value = null;

  ReceiptLine.pair(
    String label,
    String value, {
    this.size = 22,
    this.bold = false,
    this.direction = 'rtl',
  })  : text = '$label: $value',
        label = label,
        value = value,
        align = 'right',
        divider = false,
        kind = 'pair';

  ReceiptLine.total(String label, String value)
      : text = '$label: $value',
        label = label,
        value = value,
        size = 27,
        bold = true,
        align = 'right',
        direction = 'rtl',
        divider = false,
        kind = 'total';

  const ReceiptLine.divider()
      : text = '',
        size = 20,
        bold = false,
        align = 'right',
        direction = 'rtl',
        divider = true,
        kind = 'divider',
        label = null,
        value = null;

  const ReceiptLine.spacer()
      : text = '',
        size = 14,
        bold = false,
        align = 'right',
        direction = 'rtl',
        divider = false,
        kind = 'spacer',
        label = null,
        value = null;

  final String text;
  final int size;
  final bool bold;
  final String align;
  final String direction;
  final bool divider;
  final String kind;
  final String? label;
  final String? value;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'text': text,
        'size': size,
        'bold': bold,
        'align': align,
        'direction': direction,
        'divider': divider,
      };
}
