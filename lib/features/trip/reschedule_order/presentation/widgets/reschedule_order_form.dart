import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class RescheduleOrderForm extends StatelessWidget {
  const RescheduleOrderForm({
    super.key,
    required this.customerName,
    required this.salesOrder,
    required this.address,
    required this.dateTimeFields,
    required this.dateIsPast,
    required this.reasonDropdown,
    required this.notesController,
    required this.isLoading,
  });

  final String customerName;
  final String salesOrder;
  final String address;
  final Widget dateTimeFields;
  final bool dateIsPast;
  final Widget reasonDropdown;
  final TextEditingController notesController;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    children: [
      // ======= Customer Summary ======= //
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grey5,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          spacing: 10,
          children: [
            _RescheduleInfoRow(
              label: context.strings.order_customer_data,
              value: customerName,
            ),
            _RescheduleInfoRow(label: context.strings.order, value: salesOrder),
            _RescheduleInfoRow(
              label: context.strings.order_correct_address,
              value: address.isNotEmpty ? address : '—',
            ),
          ],
        ),
      ),

      const SizedBox(height: 22),

      // ======= Date & Time ======= //
      dateTimeFields,

      const SizedBox(height: 12),

      if (dateIsPast)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            context.strings.reschedule_date_must_be_future,
            style: Styles.textStyle13.copyWith(color: AppColors.red1),
          ),
        ),

      const SizedBox(height: 16),

      // ======= Reason ======= //
      Text(
        context.strings.reschedule_reason,
        style: Styles.textStyle16.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.black1,
        ),
      ),

      const SizedBox(height: 12),

      reasonDropdown,

      const SizedBox(height: 22),

      // ======= Optional Notes ======= //
      Text(
        context.strings.order_optional_notes,
        style: Styles.textStyle16.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.black1,
        ),
      ),

      const SizedBox(height: 9),

      TextField(
        controller: notesController,
        enabled: !isLoading,
        minLines: 2,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: context.strings.reschedule_notes_hint,
          filled: true,
          fillColor: AppColors.grey0,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.grey3),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.grey3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),

      const SizedBox(height: 6),

      Text(
        context.strings.reschedule_notes_not_sent,
        style: Styles.textStyle12.copyWith(color: AppColors.grey4, height: 1.5),
      ),

      const SizedBox(height: 16),
    ],
  );
}

class _RescheduleInfoRow extends StatelessWidget {
  const _RescheduleInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: Styles.textStyle13.copyWith(color: AppColors.grey4),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            value.isNotEmpty ? value : '—',
            style: Styles.textStyle15.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.black1,
            ),
          ),
        ),
      ],
    );
  }
}
