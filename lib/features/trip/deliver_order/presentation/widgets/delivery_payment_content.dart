import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_flow_data.dart';

import 'delivery_payment_amount_field.dart';
import 'delivery_payment_summary_card.dart';

/// One amount field, cash only, and an optional receipt photo.
/// The parent sends the selected image with the delivery confirmation request.
class DeliveryPaymentContent extends StatelessWidget {
  const DeliveryPaymentContent({
    super.key,
    required this.flow,
    required this.expected,
    required this.amountController,
    required this.isLoading,
    required this.amountMatches,
    required this.showMismatch,
    required this.onAmountChanged,
    required this.receiptPhoto,
    required this.onChooseReceipt,
    required this.onRemoveReceipt,
  });

  final DeliveryFlowData flow;
  final num? expected;
  final TextEditingController amountController;
  final bool isLoading;
  final bool amountMatches;
  final bool showMismatch;
  final ValueChanged<String> onAmountChanged;
  final XFile? receiptPhoto;
  final VoidCallback onChooseReceipt;
  final VoidCallback onRemoveReceipt;

  @override
  Widget build(BuildContext context) => ListView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
    children: [
      DeliveryPaymentSummaryCard(
        originalTotal: flow.originalTotal,
        expected: expected,
      ),
      const SizedBox(height: 24),
      Text(
        context.strings.delivery_collected_amount,
        style: Styles.textStyle17.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 10),
      DeliveryPaymentAmountField(
        controller: amountController,
        isLoading: isLoading,
        amountMatches: amountMatches,
        showMismatch: showMismatch,
        onChanged: onAmountChanged,
      ),
      const SizedBox(height: 10),
      if (amountMatches)
        _StatusMessage(
          message: context.strings.delivery_amount_matches,
          success: true,
        )
      else if (showMismatch)
        _StatusMessage(
          message: context.strings.delivery_amount_mismatch,
          success: false,
        ),
      if (flow.hasMissingLineIds) ...[
        const SizedBox(height: 12),
        _StatusMessage(
          message: context.strings.delivery_missing_line_ids,
          success: false,
        ),
      ],
      const SizedBox(height: 26),
      Text(
        context.strings.delivery_payment_method,
        style: Styles.textStyle17.copyWith(
          color: AppColors.black1,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.blue4,
          border: Border.all(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(Icons.payments_outlined, color: AppColors.primary, size: 27),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.strings.delivery_cash,
                style: Styles.textStyle17.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
      const SizedBox(height: 26),
      Row(
        children: [
          Icon(Icons.receipt_long_outlined, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.strings.delivery_receipt_optional,
              style: Styles.textStyle17.copyWith(
                color: AppColors.black1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (receiptPhoto != null) ...[
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.file(
            File(receiptPhoto!.path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: 156,
            errorBuilder: (_, _, _) => Container(
              height: 110,
              alignment: Alignment.center,
              color: AppColors.grey5,
              child: Text(context.strings.delivery_receipt_preview_failed),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onChooseReceipt,
                icon: const Icon(Icons.autorenew_rounded),
                label: Text(context.strings.delivery_receipt_replace),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onRemoveReceipt,
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(context.strings.delivery_receipt_remove),
              ),
            ),
          ],
        ),
      ] else
        OutlinedButton.icon(
          onPressed: isLoading ? null : onChooseReceipt,
          icon: const Icon(Icons.add_a_photo_outlined),
          label: Text(context.strings.delivery_receipt_add),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
    ],
  );
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message, required this.success});

  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: success
            ? AppColors.green1
            : AppColors.red1.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        context.localizedErrorMessage(message),
        style: Styles.base.copyWith(
          color: success ? AppColors.green0 : AppColors.red1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
