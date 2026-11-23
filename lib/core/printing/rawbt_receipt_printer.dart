import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storeus_delivery/core/printing/usb_esc_pos_printer.dart';

/// Renders a high-contrast, Arabic-safe 80 mm receipt as a PNG and dispatches
/// it directly to RawBT. No share chooser or Android print dialog is used.
class RawBtReceiptPrinter {
  RawBtReceiptPrinter._();

  // 80 mm / 203 dpi printer. Use 512 if the actual printable area clips edges.
  static const int _widthPx = 576;
  static const double _padding = 26;
  static const double _contentWidth = _widthPx - _padding * 2;
  static const int _maxHeightPx = 10000;
  static const MethodChannel _channel = MethodChannel('storeus/rawbt_direct_share');

  static Future<void> print(ReceiptDocument receipt) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('الطباعة عبر RawBT متاحة على Android فقط.');
    }
    if (receipt.lines.isEmpty) throw StateError('لا توجد بيانات للطباعة.');

    final png = await _renderPng(receipt.lines);
    final temp = await getTemporaryDirectory();
    final dir = Directory('${temp.path}${Platform.pathSeparator}rawbt_receipts');
    await dir.create(recursive: true);
    final file = File(
      '${dir.path}${Platform.pathSeparator}'
      'storeus_receipt_${DateTime.now().microsecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(png, flush: true);

    // The native bridge uses ACTION_SEND + setPackage(RawBT).
    // Dispatch success is NOT proof that the printer printed a paper receipt.
    await _channel.invokeMethod<void>('sendPng', <String, dynamic>{
      'path': file.path,
    });
  }

  static Future<void> share(ReceiptDocument receipt) => print(receipt);

  static Future<Uint8List> _renderPng(List<ReceiptLine> lines) async {
    final height = (_padding * 2 +
            lines.fold<double>(0, (sum, line) => sum + _lineHeight(line)) +
            38)
        .ceil();

    if (height > _maxHeightPx) {
      throw StateError('كشف الرحلة طويل جدًا لصورة واحدة. يلزم تقسيمه إلى صفحات.');
    }

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawColor(const ui.Color(0xFFFFFFFF), ui.BlendMode.src);

    var y = _padding;
    for (final line in lines) {
      _paintLine(canvas, line, y);
      y += _lineHeight(line);
    }

    final picture = recorder.endRecording();
    try {
      final image = await picture.toImage(_widthPx, height);
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        if (data == null) throw StateError('تعذر تجهيز صورة الفاتورة.');
        return data.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  }

  static double _lineHeight(ReceiptLine line) {
    switch (line.kind) {
      case 'spacer':
        return 14;
      case 'divider':
        return 22;
      case 'pair':
      case 'total':
        final label = _painter(
          line.label ?? '',
          size: line.kind == 'total' ? 22 : 19,
          bold: line.kind == 'total',
          color: _ink,
          maxWidth: _pairLabelWidth,
        );
        final value = _painter(
          line.value ?? '',
          size: line.kind == 'total' ? 25 : 21,
          bold: line.kind == 'total' || line.bold,
          color: _ink,
          maxWidth: _pairValueWidth - (line.kind == 'total' ? 20 : 0),
          direction: _valueDirection(line.value ?? ''),
          align: TextAlign.left,
        );
        final contentHeight = math.max(label.height, value.height);
        label.dispose();
        value.dispose();
        return contentHeight + (line.kind == 'total' ? 38 : 16);
      case 'code':
        final painter = _linePainter(line, maxWidth: _contentWidth - 26);
        final height = painter.height + 24;
        painter.dispose();
        return height;
      case 'section':
        final painter = _linePainter(line, maxWidth: _contentWidth - 20);
        final height = painter.height + 32;
        painter.dispose();
        return height;
      case 'item':
        final painter = _linePainter(line, maxWidth: _contentWidth - 22);
        final height = painter.height + 18;
        painter.dispose();
        return height;
      default:
        final painter = _linePainter(line);
        final height = painter.height + (line.kind == 'brand' ? 4 : 9);
        painter.dispose();
        return height;
    }
  }

  static const ui.Color _ink = ui.Color(0xFF111111);
  static const ui.Color _muted = ui.Color(0xFF555555);
  static const ui.Color _rule = ui.Color(0xFF888888);
  static const double _pairLabelWidth = 196;
  static const double _pairValueWidth = _contentWidth - _pairLabelWidth - 12;

  static void _paintLine(ui.Canvas canvas, ReceiptLine line, double y) {
    final height = _lineHeight(line);

    if (line.kind == 'spacer') return;

    if (line.divider || line.kind == 'divider') {
      final paint = ui.Paint()
        ..color = _rule
        ..strokeWidth = 1;
      for (var x = _padding; x < _widthPx - _padding; x += 14) {
        canvas.drawLine(
          ui.Offset(x, y + 10),
          ui.Offset(math.min(x + 7, _widthPx - _padding), y + 10),
          paint,
        );
      }
      return;
    }

    if (line.kind == 'code') {
      final box = ui.RRect.fromRectAndRadius(
        ui.Rect.fromLTWH(_padding, y + 1, _contentWidth, height - 4),
        const ui.Radius.circular(9),
      );
      canvas.drawRRect(
        box,
        ui.Paint()
          ..color = _ink
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      final painter = _linePainter(line, maxWidth: _contentWidth - 26);
      painter.paint(canvas, ui.Offset(_padding + 13, y + (height - painter.height) / 2 - 1));
      painter.dispose();
      return;
    }

    if (line.kind == 'section') {
      canvas.drawRRect(
        ui.RRect.fromRectAndRadius(
          ui.Rect.fromLTWH(_widthPx - _padding - 5, y + 10, 5, 25),
          const ui.Radius.circular(2),
        ),
        ui.Paint()..color = _ink,
      );
      final painter = _linePainter(line, maxWidth: _contentWidth - 20);
      painter.paint(canvas, ui.Offset(_padding, y + 8));
      painter.dispose();
      canvas.drawLine(
        ui.Offset(_padding, y + height - 5),
        ui.Offset(_widthPx - _padding, y + height - 5),
        ui.Paint()
          ..color = const ui.Color(0xFFCCCCCC)
          ..strokeWidth = 1,
      );
      return;
    }

    if (line.kind == 'item') {
      canvas.drawRRect(
        ui.RRect.fromRectAndRadius(
          ui.Rect.fromLTWH(_widthPx - _padding - 6, y + 12, 6, 6),
          const ui.Radius.circular(1),
        ),
        ui.Paint()..color = _ink,
      );
      final painter = _linePainter(line, maxWidth: _contentWidth - 22);
      painter.paint(canvas, ui.Offset(_padding, y + 6));
      painter.dispose();
      return;
    }

    if (line.kind == 'pair' || line.kind == 'total') {
      final total = line.kind == 'total';
      if (total) {
        final border = ui.RRect.fromRectAndRadius(
          ui.Rect.fromLTWH(_padding, y + 2, _contentWidth, height - 4),
          const ui.Radius.circular(11),
        );
        canvas.drawRRect(
          border,
          ui.Paint()
            ..color = _ink
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      final label = _painter(
        line.label ?? '',
        size: total ? 22 : 19,
        bold: total,
        color: total ? _ink : _muted,
        maxWidth: _pairLabelWidth,
      );
      final value = _painter(
        line.value ?? '',
        size: total ? 25 : 21,
        bold: total || line.bold,
        color: _ink,
        maxWidth: _pairValueWidth - (total ? 20 : 0),
        direction: _valueDirection(line.value ?? ''),
        align: TextAlign.left,
      );
      final inset = total ? 18.0 : 6.0;
      final contentHeight = math.max(label.height, value.height);
      final top = y + (height - contentHeight) / 2;
      label.paint(
        canvas,
        ui.Offset(_padding + _pairValueWidth + 12, top),
      );
      value.paint(canvas, ui.Offset(_padding + (total ? inset : 0), top));
      label.dispose();
      value.dispose();
      return;
    }

    final painter = _linePainter(line);
    painter.paint(canvas, ui.Offset(_padding, y));
    painter.dispose();
  }

  static TextPainter _linePainter(ReceiptLine line, {double maxWidth = _contentWidth}) {
    final muted = line.kind == 'note' ||
        line.kind == 'caption' ||
        line.kind == 'eyebrow' ||
        line.kind == 'footer';
    return _painter(
      line.text,
      size: line.size.toDouble(),
      bold: line.bold || line.kind == 'brand' || line.kind == 'title',
      color: muted ? _muted : _ink,
      maxWidth: maxWidth,
      direction: line.direction == 'ltr' ? TextDirection.ltr : TextDirection.rtl,
      align: switch (line.align) {
        'center' => TextAlign.center,
        'left' => TextAlign.left,
        _ => TextAlign.right,
      },
      letterSpacing: line.kind == 'brand' ? 1.6 : null,
    );
  }

  static TextPainter _painter(
    String text, {
    required double size,
    required bool bold,
    required ui.Color color,
    required double maxWidth,
    TextDirection direction = TextDirection.rtl,
    TextAlign align = TextAlign.right,
    double? letterSpacing,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
          height: 1.28,
          letterSpacing: letterSpacing,
        ),
      ),
      textDirection: direction,
      textAlign: align,
    );
    painter.layout(maxWidth: maxWidth);
    return painter;
  }

  static TextDirection _valueDirection(String value) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}
