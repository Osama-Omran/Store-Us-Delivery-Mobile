
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class ConfirmReceivingBottomSheet extends StatelessWidget {
  const ConfirmReceivingBottomSheet({
    super.key,
    required this.onConfirm,
    this.isLoading = false,
    this.isProofApproved = false,
  });

  final VoidCallback? onConfirm;
  final bool isLoading;
  final bool isProofApproved;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      decoration: BoxDecoration(
        color: AppColors.white0,
        border: Border(
          top: BorderSide(
            color: AppColors.grey3,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  context.strings.confirm_receiving,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black1,
                  ),
                ),
                Text(
                  context.strings.confirm_receiving_description,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey4,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                onPressed: isLoading || !isProofApproved
                    ? null
                    : onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.blue0,
                  foregroundColor: AppColors.white0,
                  disabledForegroundColor: AppColors.white0,
                  elevation: 5,
                  shadowColor: AppColors.blue1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.white0,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  context.strings.confirm_receiving_van,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (!isProofApproved)
              Text(
                context.strings.confirm_receiving_warning,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.orange0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
