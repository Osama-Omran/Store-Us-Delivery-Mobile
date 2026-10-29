import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/cubit/reports_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/cubit/reports_state.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_distribution_card.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_financial_card.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_statistics.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_summary_card.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_trip_performance_card.dart';

import 'reports_shimmer.dart';

class ReportsContent extends StatelessWidget {
  const ReportsContent({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<ReportsCubit, ReportsState>(
    builder: (context, state) {
      final cubit = ReportsCubit.get(context);
      final summary = state.summary;
      if (state.isLoading) return const ReportsShimmer();
      if (state.errorMessage != null) {
        return _ReportsError(
          message: state.errorMessage!,
          onRetry: () => cubit.load(),
        );
      }
      if (summary == null) {
        return Center(child: Text(context.strings.reports_empty));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReportsSummaryCard(),
          const SizedBox(height: 16),
          ReportsStatistics(),
          const SizedBox(height: 16),
          ReportsDistributionCard(),
          const SizedBox(height: 16),
          ReportsFinancialCard(summary: summary),
          const SizedBox(height: 16),
          ReportsTripPerformanceCard(),
          if (state.data?.warnings.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            for (final warning in state.data!.warnings)
              Text(
                warning,
                style: Styles.textStyle12.copyWith(color: AppColors.grey4),
              ),
          ],
        ],
      );
    },
  );
}

class _ReportsError extends StatelessWidget {
  const _ReportsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        context.localizedErrorMessage(message),
        textAlign: TextAlign.center,
        style: Styles.textStyle14.copyWith(color: AppColors.red1),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: Text(context.strings.reports_retry),
      ),
    ],
  );
}
