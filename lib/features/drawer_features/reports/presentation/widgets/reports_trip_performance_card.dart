import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../cubit/reports_cubit.dart';
import 'reports_card.dart';
import 'reports_summary_card.dart';

class ReportsTripPerformanceCard extends StatelessWidget {
  const ReportsTripPerformanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final trips = ReportsCubit.get(context).state.displayedTrips;
    return ReportsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Text(
            context.strings.reports_rate_by_trip,
            style: Styles.textStyle18.copyWith(color: AppColors.black1),
          ),
          if (trips.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Text(
                context.strings.reports_empty,
                textAlign: TextAlign.center,
                style: Styles.textStyle14.copyWith(color: AppColors.grey4),
              ),
            )
          else
            for (final trip in trips)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 7,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          trip.tripNumber,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.start,
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.black1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        formatReportPercentage(trip.deliveryPercentage),
                        textDirection: TextDirection.ltr,
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (trip.deliveryPercentage.toDouble() / 100).clamp(
                        0.0,
                        1.0,
                      ),
                      minHeight: 8,
                      backgroundColor: AppColors.grey5,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}
