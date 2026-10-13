import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/cubit/reports_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/cubit/reports_state.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_distribution_card.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_filters.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_financial_card.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_header.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_statistics.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_summary_card.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_trip_performance_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => getIt<ReportsCubit>()..load(),
        child: const _ReportsBody(),
      );
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.grey0,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const ReportsHeader(),
              Expanded(
                child: BlocBuilder<ReportsCubit, ReportsState>(
                  builder: (context, state) {
                    final cubit = ReportsCubit.get(context);
                    final summary = state.summary;
                    return RefreshIndicator(
                      onRefresh: () => cubit.load(),
                      child: ListView(
                        key: const ValueKey('reports-scroll'),
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 125),
                        children: [
                          ReportsFilters(state: state),
                          const SizedBox(height: 16),
                          if (state.isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 80),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (state.errorMessage != null)
                            _ReportsError(
                              message: state.errorMessage!,
                              onRetry: () => cubit.load(),
                            )
                          else if (summary == null)
                            Center(child: Text(context.strings.reports_empty))
                          else ...[
                            ReportsSummaryCard(
                              summary: summary,
                              period: state.period,
                            ),
                            const SizedBox(height: 16),
                            ReportsStatistics(summary: summary),
                            const SizedBox(height: 16),
                            ReportsDistributionCard(
                              distribution: state.distribution,
                            ),
                            const SizedBox(height: 16),
                            ReportsFinancialCard(summary: summary),
                            const SizedBox(height: 16),
                            ReportsTripPerformanceCard(
                              trips: state.displayedTrips,
                            ),
                            if (state.data?.warnings.isNotEmpty == true) ...[
                              const SizedBox(height: 12),
                              for (final warning in state.data!.warnings)
                                Text(
                                  warning,
                                  style: Styles.textStyle12.copyWith(
                                    color: AppColors.grey4,
                                  ),
                                ),
                            ],
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
            message,
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
