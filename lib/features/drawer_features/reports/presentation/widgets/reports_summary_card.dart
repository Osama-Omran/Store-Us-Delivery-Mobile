import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_card.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_filters.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

String formatReportPercentage(num number) {
  final value = number.toDouble().clamp(0, 100);
  return '${value.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '')}%';
}

class ReportsSummaryCard extends StatelessWidget {
  const ReportsSummaryCard({
    super.key,
    required this.summary,
    required this.period,
  });

  final ReportsSummary summary;
  final ReportsPeriod period;

  @override
  Widget build(BuildContext context) {
    final amount = formatTripAmount(context, summary.collectedAmount);
    return ReportsCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 300;
          final ring = _DeliveryRateRing(
            percentage: summary.deliveryPercentage,
            size: narrow ? 100 : 120,
          );
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                context.strings.reports_delivery_rate,
                style: Styles.textStyle16.copyWith(
                  color: AppColors.grey4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                period.label(context),
                style: Styles.textStyle14.copyWith(color: AppColors.grey4),
              ),
              const SizedBox(height: 4),
              Text(
                context.strings.reports_total_collection,
                style: Styles.textStyle14.copyWith(color: AppColors.grey4),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  amount,
                  style: Styles.textStyle24.copyWith(
                    color: AppColors.primary,
                    fontSize: 28,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          );
          if (narrow && MediaQuery.textScalerOf(context).scale(16) > 20) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [ring, details],
            );
          }
          return Row(
            spacing: 20,
            children: [ring, Expanded(child: details)],
          );
        },
      ),
    );
  }
}

class _DeliveryRateRing extends StatelessWidget {
  const _DeliveryRateRing({required this.percentage, required this.size});

  final num percentage;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
        label: context.strings.reports_delivery_rate,
        value: formatReportPercentage(percentage),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CircularProgressIndicator(
                  key: const ValueKey('reports-delivery-ring'),
                  value: (percentage.toDouble() / 100).clamp(0.0, 1.0),
                  strokeWidth: 12,
                  color: AppColors.green0,
                  backgroundColor: AppColors.grey5,
                  strokeAlign: BorderSide.strokeAlignInside,
                  strokeCap: StrokeCap.butt,
                  trackGap: 0,
                ),
              ),
              Text(
                formatReportPercentage(percentage),
                textDirection: TextDirection.ltr,
                style: Styles.textStyle24.copyWith(
                  fontSize: 28,
                  color: AppColors.black1,
                ),
              ),
            ],
          ),
        ),
      );
}
