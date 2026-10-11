import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/cubit/reports_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/cubit/reports_state.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_distribution_card.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_filters.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_header.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_statistics.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_summary_card.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_trip_performance_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReportsCubit>(),
      child: const _ReportsBody(),
    );
  }
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey0,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ======= Header ======= //
            const ReportsHeader(),
            Expanded(
              child: BlocBuilder<ReportsCubit, ReportsState>(
                builder: (context, state) => ListView(
                  key: const ValueKey('reports-scroll'),
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 125),
                  children: [
                    // ======= Filters ======= //
                    ReportsFilters(state: state),
                    const SizedBox(height: 16),
                    // ======= Delivery and Collection ======= //
                    ReportsSummaryCard(
                      summary: state.data.summary,
                      period: state.period,
                    ),
                    const SizedBox(height: 16),
                    ReportsStatistics(summary: state.data.summary),
                    const SizedBox(height: 16),
                    // ======= Order Distribution and Trip Performance ======= //
                    ReportsDistributionCard(summary: state.data.summary),
                    const SizedBox(height: 16),
                    ReportsTripPerformanceCard(
                      trips: state.data.tripPerformance,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
