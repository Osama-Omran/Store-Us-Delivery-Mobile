import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class DeliveryPaymentAmountField extends StatelessWidget {
  const DeliveryPaymentAmountField({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.amountMatches,
    required this.showMismatch,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool isLoading;
  final bool amountMatches;
  final bool showMismatch;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    enabled: !isLoading,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.right,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: '0',
      suffixText: context.strings.egp_currency,
      filled: true,
      fillColor: AppColors.white0,
      contentPadding: const EdgeInsets.all(20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(
          color: amountMatches
              ? AppColors.green0
              : showMismatch
              ? AppColors.red1
              : AppColors.primary,
          width: 1.7,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
    ),
    style: Styles.textStyle26.copyWith(
      fontWeight: FontWeight.w800,
      color: AppColors.black1,
    ),
  );
}
