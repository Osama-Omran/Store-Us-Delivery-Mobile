import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/trip_map/data/models/trip_map_stop.dart';

class TripStopMarkerFactory {
  const TripStopMarkerFactory._();

  static Future<BitmapDescriptor> create(
    TripMapStop stop, {
    required bool selected,
  }) async {
    const logicalSize = 58.0;
    const pixelRatio = 3.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(pixelRatio);
    final center = const Offset(logicalSize / 2, logicalSize / 2);
    final primary = AppColors.primary;
    final cancelled = stop.status == TripOrderStatus.cancelled;
    final partially = stop.status == TripOrderStatus.partiallyDelivered;
    final delivered = stop.status == TripOrderStatus.delivered;
    final fill = cancelled
        ? AppColors.red1
        : partially
            ? AppColors.orange0
            : selected
                ? primary
                : AppColors.white0;
    final textColor = (cancelled || partially || selected)
        ? AppColors.white0
        : AppColors.black1;
    final radius = selected ? 25.0 : 22.0;

    canvas.drawCircle(
      center + const Offset(0, 2),
      radius + (selected ? 5 : 2),
      Paint()..color = primary.withValues(alpha: selected ? .22 : .08),
    );
    canvas.drawCircle(center, radius, Paint()..color = fill);
    if (!cancelled && !partially && !selected) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = AppColors.grey3
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    // Delivered stops are white as in the supplied design.
    final label = cancelled ? '×' : stop.number.toString();
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: delivered ? AppColors.black1 : textColor,
          fontSize: cancelled ? 31 : selected ? 21 : 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      (logicalSize * pixelRatio).round(),
      (logicalSize * pixelRatio).round(),
    );
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    picture.dispose();
    if (bytes == null) throw StateError('Cannot render stop marker');
    return BitmapDescriptor.bytes(
      bytes.buffer.asUint8List(),
      width: logicalSize,
      height: logicalSize,
    );
  }
}
