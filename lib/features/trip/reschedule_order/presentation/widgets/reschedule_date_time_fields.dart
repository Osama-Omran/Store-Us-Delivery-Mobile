import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class RescheduleDateTimeFields extends StatelessWidget {
  const RescheduleDateTimeFields({
    super.key,
    required this.dateLabel,
    required this.timeLabel,
    required this.isLoading,
    required this.onSelectDate,
    required this.onSelectTime,
  });

  final String dateLabel;
  final String timeLabel;
  final bool isLoading;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              context.strings.reschedule_new_date,
              style: Styles.base.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.black1,
              ),
            ),

            OutlinedButton(
              onPressed: isLoading ? null : onSelectDate,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(58),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(color: AppColors.grey3),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      dateLabel,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.center,
                      style: Styles.base.copyWith(
                        color: AppColors.black1,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 19,
                    color: AppColors.black1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      const SizedBox(width: 10),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              context.strings.reschedule_new_time,
              style: Styles.base.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.black1,
              ),
            ),

            OutlinedButton(
              onPressed: isLoading ? null : onSelectTime,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(58),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(color: AppColors.grey3),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      timeLabel,
                      textAlign: TextAlign.center,
                      style: Styles.base.copyWith(
                        color: AppColors.black1,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.access_time_outlined,
                    size: 19,
                    color: AppColors.black1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
