import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/custom_trip_container.dart';

class ReceivingProofPhoto extends StatefulWidget {
  const ReceivingProofPhoto({
    super.key,
    required this.tripNumber,
    required this.onPhotoApprovalChanged,
  });

  final String tripNumber;
  final ValueChanged<ReceivingProofModel?> onPhotoApprovalChanged;

  @override
  State<ReceivingProofPhoto> createState() =>
      _ReceivingProofPhotoState();
}

class _ReceivingProofPhotoState extends State<ReceivingProofPhoto> {
  final ImagePicker _picker = ImagePicker();

  ReceivingProofModel? _proof;
  bool _isApproved = false;
  bool _isCapturing = false;

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (!mounted || image == null) return;

      final proof = ReceivingProofModel(
        image: image,
        tripNumber: widget.tripNumber,
        capturedAt: DateTime.now(),
      );

      setState(() {
        _proof = proof;
        _isApproved = false;
      });

      widget.onPhotoApprovalChanged(null);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.strings.proof_photo_error),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  void _approvePhoto() {
    if (_proof == null) return;

    setState(() => _isApproved = true);
    widget.onPhotoApprovalChanged(_proof);
  }

  @override
  Widget build(BuildContext context) {
    return CustomTripContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: context.strings.receiving_proof_photo,
                  style: TextStyle(color: AppColors.black1),
                ),
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.red0),
                ),
              ],
            ),
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          if (_proof == null)
            _buildCameraPlaceholder(context)
          else ...[
            _buildPhotoPreview(context),
            if (_isApproved)
              _buildApprovedActions(context)
            else
              _buildPreviewActions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildCameraPlaceholder(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: AppColors.blue0,
      ),
      child: Material(
        color: AppColors.lightPrimary,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _isCapturing ? null : _capturePhoto,
          child: SizedBox(
            width: double.infinity,
            height: 198,
            child: _isCapturing
                ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 12,
              children: [
                Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.primary,
                  size: 44,
                ),
                Text(
                  context.strings.open_camera_and_capture,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  context.strings.proof_photo_auto_details,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(BuildContext context) {
    final proof = _proof!;

    final date = proof.capturedAt;

    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    final formattedTime =
    TimeOfDay.fromDateTime(date).format(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 1.58,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(proof.image.path),
              fit: BoxFit.cover,
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                color: AppColors.black0.withValues(
                  alpha: 0.58,
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        '$formattedDate - $formattedTime',
                        style: TextStyle(
                          color: AppColors.white0,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        proof.tripNumber,
                        style: TextStyle(
                          color: AppColors.white0,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_isApproved)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green0,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 5,
                    children: [
                      Text(
                        context.strings.photo_approved,
                        style: TextStyle(
                          color: AppColors.white0,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        Icons.check,
                        color: AppColors.white0,
                        size: 17,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewActions(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: SizedBox(
            height: 60,
            child: OutlinedButton(
              onPressed: _isCapturing ? null : _capturePhoto,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.black1,
                backgroundColor: AppColors.white0,
                side: BorderSide(
                  color: AppColors.grey3,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(
                context.strings.retake_photo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 60,
            child: ElevatedButton(
              onPressed: _approvePhoto,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white0,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(
                context.strings.use_photo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApprovedActions(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: _isCapturing ? null : _capturePhoto,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 2,
          ),
        ),
        child: Text(
          context.strings.retake_photo,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class ReceivingProofModel {
  final XFile image;
  final String tripNumber;
  final DateTime capturedAt;

  const ReceivingProofModel({
    required this.image,
    required this.tripNumber,
    required this.capturedAt,
  });
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            1,
            1,
            size.width - 2,
            size.height - 2,
          ),
          const Radius.circular(20),
        ),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            math.min(distance + 7, metric.length),
          ),
          paint,
        );
        distance += 12;
      }
    }
  }

  @override
  bool shouldRepaint(
      covariant _DashedBorderPainter oldDelegate,
      ) {
    return oldDelegate.color != color;
  }
}
