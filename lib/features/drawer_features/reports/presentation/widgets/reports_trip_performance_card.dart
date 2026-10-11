import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_card.dart';

class ReportsTripPerformanceCard extends StatelessWidget {
  const ReportsTripPerformanceCard({super.key, required this.trips});

  final List<ReportTripPerformance> trips;

  @override
  Widget build(BuildContext context) {
    return ReportsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.strings.reports_rate_by_trip,
            style: Styles.textStyle18.copyWith(color: AppColors.black1),
          ),
          if (trips.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Text(
                context.strings.reports_empty,
                textAlign: TextAlign.center,
                style: Styles.textStyle14.copyWith(color: AppColors.grey4),
              ),
            )
          else ...[
            const SizedBox(height: 150),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final trip in trips)
                  Expanded(
                    child: Semantics(
                      label: '${trip.tripNumber}: ${trip.deliveryPercentage}%',
                      child: Column(
                        spacing: 10,
                        children: [
                          Text(
                            '${trip.deliveryPercentage}%',
                            textDirection: TextDirection.ltr,
                            style: Styles.textStyle12.copyWith(
                              color: AppColors.black1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            trip.tripNumber.replaceFirst('TRIP-', ''),
                            textDirection: TextDirection.ltr,
                            style: Styles.textStyle10.copyWith(
                              color: AppColors.grey4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
