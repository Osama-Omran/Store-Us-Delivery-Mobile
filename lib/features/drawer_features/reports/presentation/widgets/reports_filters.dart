import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/cubit/reports_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/cubit/reports_state.dart';

extension ReportsPeriodLabels on ReportsPeriod {
  String label(BuildContext context) => switch (this) {
    ReportsPeriod.today => context.strings.reports_today,
    ReportsPeriod.week => context.strings.reports_this_week,
    ReportsPeriod.month => context.strings.reports_this_month,
    ReportsPeriod.custom => context.strings.reports_custom_period,
  };
}

class ReportsFilters extends StatelessWidget {
  const ReportsFilters({super.key, required this.state});

  final ReportsState state;

  Future<void> _selectDate(BuildContext context, {required bool from}) async {
    final cubit = ReportsCubit.get(context);
    final date = await showDatePicker(
      context: context,
      initialDate: from ? state.fromDate : state.toDate,
      firstDate: from ? DateTime(2000) : state.fromDate,
      lastDate: from ? state.toDate : DateTime(2100, 12, 31),
    );
    if (!context.mounted || cubit.isClosed || date == null) return;
    cubit.selectDateRange(
      fromDate: from ? date : cubit.state.fromDate,
      toDate: from ? cubit.state.toDate : date,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ReportsCubit.get(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        // ======= Period ======= //
        SingleChildScrollView(
          key: const ValueKey('reports-periods'),
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 10,
            children: [
              for (final period in ReportsPeriod.values)
                Semantics(
                  selected: period == state.period,
                  button: true,
                  child: Material(
                    color: period == state.period
                        ? AppColors.primary
                        : AppColors.white0,
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: period == state.period
                            ? AppColors.primary
                            : AppColors.grey3,
                      ),
                    ),
                    child: InkWell(
                      key: ValueKey('reports-period-${period.name}'),
                      customBorder: const StadiumBorder(),
                      onTap: () => cubit.selectPeriod(period),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Text(
                          period.label(context),
                          style: Styles.textStyle18.copyWith(
                            color: period == state.period
                                ? AppColors.white0
                                : AppColors.grey4,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ======= Custom Dates ======= //
        if (state.period == ReportsPeriod.custom)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Expanded(
                child: _ReportsDateField(
                  key: const ValueKey('reports-from-date'),
                  label: context.strings.reports_from_date,
                  date: state.fromDate,
                  onTap: () => _selectDate(context, from: true),
                ),
              ),
              Expanded(
                child: _ReportsDateField(
                  key: const ValueKey('reports-to-date'),
                  label: context.strings.reports_to_date,
                  date: state.toDate,
                  onTap: () => _selectDate(context, from: false),
                ),
              ),
            ],
          ),

        // ======= Trip Selector ======= //
        LayoutBuilder(
          builder: (context, constraints) => PopupMenuButton<String>(
            key: const ValueKey('reports-trip'),
            position: PopupMenuPosition.under,
            offset: const Offset(0, 2),
            color: AppColors.white0,
            surfaceTintColor: AppColors.white0,
            menuPadding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: constraints.maxWidth),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppColors.grey3),
            ),
            onSelected: cubit.selectTrip,
            itemBuilder: (_) => [
              for (final trip in [
                allReportTrips,
                ...?state.data?.tripPerformance.map((trip) => trip.tripNumber),
              ])
                PopupMenuItem(
                  value: trip,
                  padding: EdgeInsets.zero,
                  height: 44,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    alignment: AlignmentDirectional.centerStart,
                    color: trip == state.tripNumber
                        ? AppColors.primary
                        : AppColors.white0,
                    child: Text(
                      trip == allReportTrips
                          ? context.strings.reports_all_trips
                          : trip,
                      style: Styles.textStyle16.copyWith(
                        color: trip == state.tripNumber
                            ? AppColors.white0
                            : AppColors.black1,
                      ),
                    ),
                  ),
                ),
            ],
            child: Container(
              constraints: const BoxConstraints(minHeight: 60),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white0,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.grey3, width: 2),
              ),
              child: Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: Text(
                      state.tripNumber == allReportTrips
                          ? context.strings.reports_all_trips
                          : state.tripNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Styles.textStyle16.copyWith(
                        color: AppColors.black1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.black1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportsDateField extends StatelessWidget {
  const _ReportsDateField({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        Text(
          label,
          style: Styles.textStyle14.copyWith(
            color: AppColors.grey4,
            fontWeight: FontWeight.w700,
          ),
        ),
        Semantics(
          label: label,
          button: true,
          child: Material(
            color: AppColors.white0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(color: AppColors.grey3, width: 2),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: onTap,
              child: Container(
                constraints: const BoxConstraints(minHeight: 60),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  spacing: 10,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.black1,
                      size: 18,
                    ),
                    Expanded(
                      child: Text(
                        DateFormat('dd/MM/yyyy', 'en').format(date),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.start,
                        style: Styles.textStyle16.copyWith(
                          color: AppColors.black1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
