
import 'package:flutter/material.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class ContactSupportInfoCard extends StatelessWidget {
  const ContactSupportInfoCard({
    super.key,
    required this.phone,
    this.workingHours,
  });

  final String phone;
  final String? workingHours;

  @override
  Widget build(BuildContext context) {
    final hasWorkingHours = workingHours?.trim().isNotEmpty == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
        boxShadow: [
          BoxShadow(
            color: AppColors.black1.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        spacing: 14,
        children: [
          // ======= Support Phone ======= //
          _ContactInfoRow(
            label: context.strings.contact_support_number,
            value: phone,
            isPhone: true,
          ),

          // ======= Working Hours ======= //
          if (hasWorkingHours)
            _ContactInfoRow(
              label: context.strings.contact_working_hours,
              value: workingHours!,
            ),
        ],
      ),
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  const _ContactInfoRow({
    required this.label,
    required this.value,
    this.isPhone = false,
  });

  final String label;
  final String value;
  final bool isPhone;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Expanded(
          child: Text(
            label,
            style: Styles.textStyle14.copyWith(
              color: AppColors.grey4,
            ),
          ),
        ),

        Text(
          value.trim().isEmpty ? '—' : value,
          textDirection: isPhone
              ? TextDirection.ltr
              : TextDirection.rtl,
          style: Styles.textStyle16.copyWith(
            color: AppColors.black1,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
