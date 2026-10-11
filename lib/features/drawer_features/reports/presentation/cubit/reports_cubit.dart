import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';
import 'package:storeus_delivery/features/drawer_features/reports/data/sample/sample_reports.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/cubit/reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit()
    : super(
        ReportsState(
          data: buildSampleReports(period: ReportsPeriod.today),
          fromDate: sampleReportsFromDate,
          toDate: sampleReportsToDate,
        ),
      );

  static ReportsCubit get(BuildContext context) => BlocProvider.of(context);

  // ======= Report Filters ======= //
  void selectPeriod(ReportsPeriod period) {
    if (period == state.period) return;
    _select(period: period);
  }

  void selectTrip(String tripNumber) {
    if (tripNumber == state.tripNumber) return;
    if (tripNumber != allReportTrips &&
        !reportTripNumbers.contains(tripNumber)) {
      return;
    }
    _select(tripNumber: tripNumber);
  }

  void selectDateRange({required DateTime fromDate, required DateTime toDate}) {
    final from = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final to = DateTime(toDate.year, toDate.month, toDate.day);
    if (from.isAfter(to)) return;
    if (from == state.fromDate && to == state.toDate) return;
    _select(fromDate: from, toDate: to);
  }

  void _select({
    ReportsPeriod? period,
    String? tripNumber,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    final selectedPeriod = period ?? state.period;
    final selectedTrip = tripNumber ?? state.tripNumber;
    final from = fromDate ?? state.fromDate;
    final to = toDate ?? state.toDate;
    emit(
      ReportsState(
        period: selectedPeriod,
        tripNumber: selectedTrip,
        fromDate: from,
        toDate: to,
        data: buildSampleReports(
          period: selectedPeriod,
          tripNumber: selectedTrip,
          fromDate: from,
          toDate: to,
        ),
      ),
    );
  }
}
