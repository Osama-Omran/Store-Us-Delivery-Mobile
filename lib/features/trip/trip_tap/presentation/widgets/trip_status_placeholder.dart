
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class TripStatusPlaceholder extends StatelessWidget {
  const TripStatusPlaceholder({
    super.key,
    required this.title,
    this.status,
    this.onRetry,
  });

  final String title;
  final String? status;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.blue4,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),

            const Gap(8),

            Text(
              title,
              textAlign: TextAlign.center,
              style: Styles.textStyle20.copyWith(
                color: AppColors.black1,
                fontWeight: FontWeight.w800,
              ),
            ),

            if (status != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey5,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  spacing: 4,
                  children: [
                    Text(
                      context.strings.trip_acceptance_status,
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.grey4,
                      ),
                    ),
                    Text(
                      status!,
                      textAlign: TextAlign.center,
                      style: Styles.textStyle16.copyWith(
                        color: AppColors.black1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (onRetry != null) ...[
              const Gap(8),

              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  context.strings.trip_tab_retry,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
