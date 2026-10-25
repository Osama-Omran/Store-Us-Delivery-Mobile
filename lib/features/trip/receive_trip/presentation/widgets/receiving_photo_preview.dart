import 'dart:io';

import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class ReceivingPhotoPreview extends StatelessWidget {
  const ReceivingPhotoPreview({
    super.key,
    required this.imagePath,
    required this.tripNumber,
    required this.capturedAt,
    required this.isApproved,
  });

  final String imagePath;
  final String tripNumber;
  final DateTime capturedAt;
  final bool isApproved;

  @override
  Widget build(BuildContext context) {
    final date = capturedAt;

    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    final formattedTime = TimeOfDay.fromDateTime(date).format(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 1.58,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(imagePath), fit: BoxFit.cover),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                color: AppColors.black0.withValues(alpha: 0.58),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        '$formattedDate - $formattedTime',
                        style: Styles.textStyle13.copyWith(
                          color: AppColors.white0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        tripNumber,
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.white0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (isApproved)
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
                        style: Styles.textStyle13.copyWith(
                          color: AppColors.white0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(Icons.check, color: AppColors.white0, size: 17),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
