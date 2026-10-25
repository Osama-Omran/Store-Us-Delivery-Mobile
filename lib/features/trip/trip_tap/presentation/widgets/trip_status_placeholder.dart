import 'package:flutter/material.dart';

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
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 124),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 30, 22, 25),
          decoration: BoxDecoration(
            color: AppColors.white0,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.grey3),
            boxShadow: [
              BoxShadow(
                color: AppColors.black1.withValues(alpha: 0.035),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(23),
                decoration: BoxDecoration(
                  color: AppColors.blue5,
                  borderRadius: BorderRadius.circular(27),
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  size: 51,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 21),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Styles.textStyle20.copyWith(
                  color: AppColors.black1,
                  fontWeight: FontWeight.w900,
                  height: 1.45,
                ),
              ),
              if (status != null) ...[
                const SizedBox(height: 17),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey5,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        context.strings.trip_acceptance_status,
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.grey4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status!,
                        textAlign: TextAlign.center,
                        style: Styles.textStyle16.copyWith(
                          color: AppColors.black1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: 23),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.blue3),
                      backgroundColor: AppColors.blue5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: Text(
                      context.strings.trip_tab_retry,
                      style: Styles.base.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
