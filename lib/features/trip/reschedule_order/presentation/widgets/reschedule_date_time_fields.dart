import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class RescheduleDateTimeFields extends StatelessWidget {
  const RescheduleDateTimeFields({
    super.key,
    required this.dateLabel,
    required this.timeLabel,
    required this.isDateSelected,
    required this.isTimeSelected,
    required this.showDateError,
    required this.showTimeError,
    required this.isLoading,
    required this.onSelectDate,
    required this.onSelectTime,
  });

  final String dateLabel;
  final String timeLabel;
  final bool isDateSelected;
  final bool isTimeSelected;
  final bool showDateError;
  final bool showTimeError;
  final bool isLoading;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _RequiredPickerField(
            title: context.strings.reschedule_new_date,
            value: dateLabel,
            isSelected: isDateSelected,
            showError: showDateError,
            errorMessage: isArabic
                ? 'يرجى اختيار تاريخ إعادة الجدولة'
                : 'Please select a rescheduling date',
            icon: Icons.calendar_today_outlined,
            isLoading: isLoading,
            onPressed: onSelectDate,
            forceLtr: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RequiredPickerField(
            title: context.strings.reschedule_new_time,
            value: timeLabel,
            isSelected: isTimeSelected,
            showError: showTimeError,
            errorMessage: isArabic
                ? 'يرجى اختيار وقت إعادة الجدولة'
                : 'Please select a rescheduling time',
            icon: Icons.access_time_outlined,
            isLoading: isLoading,
            onPressed: onSelectTime,
          ),
        ),
      ],
    );
  }
}

class _RequiredPickerField extends StatelessWidget {
  const _RequiredPickerField({
    required this.title,
    required this.value,
    required this.isSelected,
    required this.showError,
    required this.errorMessage,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
    this.forceLtr = false,
  });

  final String title;
  final String value;
  final bool isSelected;
  final bool showError;
  final String errorMessage;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;
  final bool forceLtr;

  @override
  Widget build(BuildContext context) {
    final valueColor = isSelected ? AppColors.black1 : AppColors.grey4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: Styles.base.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.black1,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: Styles.base.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.red1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(58),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide(
              color: showError ? AppColors.red1 : AppColors.grey3,
              width: showError ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  textDirection: forceLtr && isSelected
                      ? TextDirection.ltr
                      : null,
                  textAlign: TextAlign.center,
                  style: Styles.base.copyWith(
                    color: valueColor,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(icon, size: 19, color: valueColor),
            ],
          ),
        ),
        if (showError) ...[
          const SizedBox(height: 6),
          Text(
            errorMessage,
            style: Styles.textStyle12.copyWith(color: AppColors.red1),
          ),
        ],
      ],
    );
  }
}
