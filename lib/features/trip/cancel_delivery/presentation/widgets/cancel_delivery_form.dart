import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class CancelDeliveryForm extends StatelessWidget {
  const CancelDeliveryForm({
    super.key,
    required this.customerName,
    required this.salesOrder,
    required this.reasons,
    required this.selectedReasonIndex,
    required this.otherReasonController,
    required this.notesController,
    required this.isLoading,
    required this.onReasonSelected,
    required this.onOtherReasonChanged,
  });

  final String customerName;
  final String salesOrder;
  final List<String> reasons;
  final int? selectedReasonIndex;
  final TextEditingController otherReasonController;
  final TextEditingController notesController;
  final bool isLoading;
  final ValueChanged<int> onReasonSelected;
  final VoidCallback onOtherReasonChanged;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    children: [
      // ======= Order Information ======= //
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grey5,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          spacing: 12,
          children: [
            _CancelInfoRow(
              title: context.strings.order_customer_data,
              value: customerName,
            ),
            _CancelInfoRow(title: context.strings.order, value: salesOrder),
          ],
        ),
      ),

      const SizedBox(height: 24),

      // ======= Reasons ======= //
      Text(
        context.strings.cancel_delivery_reason_required,
        style: Styles.textStyle16.copyWith(
          color: AppColors.black1,
          fontWeight: FontWeight.w800,
        ),
      ),

      const SizedBox(height: 12),

      Wrap(
        spacing: 8,
        runSpacing: 9,
        children: [
          for (int i = 0; i < reasons.length; i++)
            ChoiceChip(
              showCheckmark: false,
              selected: selectedReasonIndex == i,
              label: Text(reasons[i]),
              onSelected: isLoading ? null : (_) => onReasonSelected(i),
              backgroundColor: AppColors.white0,
              selectedColor: AppColors.red0,
              side: BorderSide(
                color: selectedReasonIndex == i
                    ? AppColors.red1
                    : AppColors.grey3,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              labelStyle: Styles.textStyle14.copyWith(
                color: selectedReasonIndex == i
                    ? AppColors.white0
                    : AppColors.black1,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),

      // ======= Other Reason ======= //
      if (selectedReasonIndex == 6) ...[
        const SizedBox(height: 12),

        TextField(
          controller: otherReasonController,
          enabled: !isLoading,
          onChanged: (_) => onOtherReasonChanged(),
          maxLines: 2,
          decoration: _inputDecoration(
            context.strings.cancel_delivery_other_reason_hint,
          ),
        ),
      ],

      const SizedBox(height: 24),

      // ======= Optional Notes ======= //
      Text(
        context.strings.order_optional_notes,
        style: Styles.textStyle16.copyWith(
          color: AppColors.black1,
          fontWeight: FontWeight.w800,
        ),
      ),

      const SizedBox(height: 10),

      TextField(
        controller: notesController,
        enabled: !isLoading,
        minLines: 2,
        maxLines: 3,
        decoration: _inputDecoration(
          context.strings.cancel_delivery_notes_hint,
        ),
      ),

      const SizedBox(height: 7),

      Text(
        context.strings.cancel_delivery_notes_not_sent,
        style: Styles.textStyle12.copyWith(color: AppColors.grey4),
      ),

      const SizedBox(height: 20),
    ],
  );

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.grey0,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.grey3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.grey3),
      ),
    );
  }
}

class _CancelInfoRow extends StatelessWidget {
  const _CancelInfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Expanded(
          child: Text(
            title,
            style: Styles.textStyle14.copyWith(color: AppColors.grey4),
          ),
        ),

        Expanded(
          flex: 2,
          child: Text(
            value.isEmpty ? '—' : value,
            textAlign: TextAlign.start,
            style: Styles.textStyle16.copyWith(
              color: AppColors.black1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
