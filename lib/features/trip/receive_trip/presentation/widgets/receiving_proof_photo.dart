import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/custom_trip_container.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/face_check_result.dart';

import 'receiving_photo_actions.dart';
import 'receiving_photo_placeholder.dart';
import 'receiving_photo_preview.dart';

import 'package:storeus_delivery/core/theme/text_styles.dart';

class ReceivingProofPhoto extends StatefulWidget {
  const ReceivingProofPhoto({
    super.key,
    required this.tripNumber,
    required this.onPhotoApprovalChanged,
  });

  final String tripNumber;
  final ValueChanged<ReceivingProofModel?> onPhotoApprovalChanged;

  @override
  State<ReceivingProofPhoto> createState() => _ReceivingProofPhotoState();
}

class _ReceivingProofPhotoState extends State<ReceivingProofPhoto> {
  final ImagePicker _picker = ImagePicker();
  final FaceValidator _faceValidator = FaceValidator();

  ReceivingProofModel? _proof;
  bool _isApproved = false;
  bool _isCapturing = false;
  bool _isValidating = false;
  String? _errorMessage;

  @override
  void dispose() {
    _faceValidator.dispose();
    super.dispose();
  }

  String _messageFor(FaceCheckResult result) {
    final s = context.strings;
    switch (result) {
      case FaceCheckResult.noFace:
        return s.face_not_detected;
      case FaceCheckResult.multipleFaces:
        return s.face_multiple_detected;
      case FaceCheckResult.tooSmall:
        return s.face_too_small;
      case FaceCheckResult.notFrontal:
        return s.face_not_frontal;
      case FaceCheckResult.eyesClosed:
        return s.face_eyes_closed;
      case FaceCheckResult.failed:
      case FaceCheckResult.ok:
        return s.proof_photo_error;
    }
  }

// widget file
Future<void> _capturePhoto() async {
  if (_isCapturing || _isValidating) return;

  setState(() {
    _isCapturing = true;
    _errorMessage = null;
  });

  try {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1280,
      preferredCameraDevice: CameraDevice.front,
    );

    if (!mounted || image == null) return;

    setState(() {
      _isCapturing = false;
      _isValidating = true;
    });

    FaceCheckResult result;
    try {
      result = await _faceValidator.validate(image.path);
    } catch (e) {
      debugPrint('Face validation failed: $e');
      if (!mounted) return;
      setState(() {
        _proof = null;
        _isApproved = false;
        _errorMessage = _messageFor(FaceCheckResult.failed);
      });
      widget.onPhotoApprovalChanged(null);
      return;
    }

    if (!mounted) return;

    if (result != FaceCheckResult.ok) {
      setState(() {
        _proof = null;
        _isApproved = false;
        _errorMessage = _messageFor(result);
      });
      widget.onPhotoApprovalChanged(null);
      return;
    }

    setState(() {
      _proof = ReceivingProofModel(
        image: image,
        tripNumber: widget.tripNumber,
        capturedAt: DateTime.now(),
      );
      _isApproved = false;
    });
    widget.onPhotoApprovalChanged(null);
  } catch (e) {
    if (!mounted) return;
    setState(() => _errorMessage = context.strings.proof_photo_error);
  } finally {
    if (mounted) {
      setState(() {
        _isCapturing = false;
        _isValidating = false;
      });
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
    final proof = _proof;
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
                  style: Styles.base.copyWith(color: AppColors.black1),
                ),
                TextSpan(
                  text: ' *',
                  style: Styles.base.copyWith(color: AppColors.red0),
                ),
              ],
            ),
            textAlign: TextAlign.start,
            style: Styles.textStyle18,
          ),

          if (proof == null) ...[
            ReceivingPhotoPlaceholder(
              isBusy: _isCapturing || _isValidating,
              onCapturePhoto: _capturePhoto,
            ),
            if (_errorMessage != null)
              Row(
                spacing: 6,
                children: [
                  Icon(Icons.error_outline, color: AppColors.red0, size: 18),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: Styles.textStyle13.copyWith(
                        color: AppColors.red0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
          ] else ...[
            ReceivingPhotoPreview(
              imagePath: proof.image.path,
              tripNumber: proof.tripNumber,
              capturedAt: proof.capturedAt,
              isApproved: _isApproved,
            ),
            ReceivingPhotoActions(
              isApproved: _isApproved,
              isCapturing: _isCapturing,
              onCapturePhoto: _capturePhoto,
              onApprovePhoto: _approvePhoto,
            ),
          ],
        ],
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
