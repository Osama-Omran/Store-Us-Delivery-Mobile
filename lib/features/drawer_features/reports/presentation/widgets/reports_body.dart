import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../cubit/reports_cubit.dart';
import 'reports_header.dart';
import 'reports_filters.dart';
import 'reports_content.dart';

class ReportsBody extends StatelessWidget {
  const ReportsBody({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.grey0,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          const ReportsHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ReportsCubit.get(context).load(),
              child: ListView(
                key: const ValueKey('reports-scroll'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 125),
                children: const [
                  ReportsFilters(),
                  SizedBox(height: 16),
                  ReportsContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
