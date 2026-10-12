import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class ReceivingPhotoActions extends StatelessWidget {
  const ReceivingPhotoActions({
    super.key,
    required this.isApproved,
    required this.isCapturing,
    required this.onCapturePhoto,
    required this.onApprovePhoto,
  });

  final bool isApproved;
  final bool isCapturing;
  final VoidCallback onCapturePhoto;
  final VoidCallback onApprovePhoto;

  @override
  Widget build(BuildContext context) => isApproved
      ? Center(
          child: TextButton(
            onPressed: isCapturing ? null : onCapturePhoto,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            ),
            child: Text(
              context.strings.retake_photo,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        )
      : Row(
          spacing: 10,
          children: [
            Expanded(
              child: SizedBox(
                height: 60,
                child: OutlinedButton(
                  onPressed: isCapturing ? null : onCapturePhoto,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black1,
                    backgroundColor: AppColors.white0,
                    side: BorderSide(color: AppColors.grey3, width: 2),
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
                  onPressed: onApprovePhoto,
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
