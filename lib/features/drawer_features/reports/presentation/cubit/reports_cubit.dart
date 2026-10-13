import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';
import 'package:storeus_delivery/features/drawer_features/reports/domain/usecases/get_reports_overview_usecase.dart';

import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit(this._usecase)
    : super(ReportsState(fromDate: DateTime.now(), toDate: DateTime.now()));

  final GetReportsOverviewUsecase _usecase;
  int _requestId = 0;

  static ReportsCubit get(BuildContext context) => context.read<ReportsCubit>();

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static ({DateTime from, DateTime to}) _dates(
    ReportsPeriod period,
    DateTime from,
    DateTime to,
  ) {
    final today = _dateOnly(DateTime.now());
    return switch (period) {
      ReportsPeriod.today => (from: today, to: today),
      ReportsPeriod.week => (
        from: today.subtract(Duration(days: today.weekday - 1)),
        to: today.add(Duration(days: 7 - today.weekday)),
      ),
      ReportsPeriod.month => (
        from: DateTime(today.year, today.month, 1),
        to: DateTime(today.year, today.month + 1, 0),
      ),
      ReportsPeriod.custom => (from: _dateOnly(from), to: _dateOnly(to)),
    };
  }

  Future<void> load({
    ReportsPeriod? period,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final selected = period ?? state.period;
    final range = _dates(
      selected,
      fromDate ?? state.fromDate,
      toDate ?? state.toDate,
    );
    if (range.from.isAfter(range.to)) return;

    final keepTrip = period == null && fromDate == null && toDate == null
        ? state.tripNumber
        : allReportTrips;
    final requestId = ++_requestId;
    emit(
      ReportsState(
        period: selected,
        fromDate: range.from,
        toDate: range.to,
        tripNumber: allReportTrips,
        isLoading: true,
      ),
    );

    try {
      final result = await _usecase.call(
        from: DateFormat('yyyy-MM-dd').format(range.from),
        to: DateFormat('yyyy-MM-dd').format(range.to),
      );
      if (isClosed || _requestId != requestId) return;

      result.when(
        success: (data) => emit(
          ReportsState(
            period: selected,
            fromDate: range.from,
            toDate: range.to,
            data: data,
            tripNumber:
                keepTrip == allReportTrips ||
                    data.tripPerformance.any(
                      (trip) => trip.tripNumber == keepTrip,
                    )
                ? keepTrip
                : allReportTrips,
          ),
        ),
        failure: (error) => emit(
          ReportsState(
            period: selected,
            fromDate: range.from,
            toDate: range.to,
            errorMessage: error.apiErrorModel.message,
          ),
        ),
      );
    } catch (_) {
      if (isClosed || _requestId != requestId) return;
      emit(
        ReportsState(
          period: selected,
          fromDate: range.from,
          toDate: range.to,
          errorMessage: 'تعذر تحميل التقارير',
        ),
      );
    }
  }

  void selectPeriod(ReportsPeriod period) {
    if (period == state.period) return;
    load(period: period);
  }

  void selectTrip(String tripNumber) {
    if (tripNumber == state.tripNumber || state.data == null) return;
    if (tripNumber != allReportTrips &&
        !state.data!.tripPerformance.any(
          (trip) => trip.tripNumber == tripNumber,
        )) {
      return;
    }
    emit(
      ReportsState(
        period: state.period,
        fromDate: state.fromDate,
        toDate: state.toDate,
        tripNumber: tripNumber,
        data: state.data,
      ),
    );
  }

  void selectDateRange({required DateTime fromDate, required DateTime toDate}) {
    final from = _dateOnly(fromDate);
    final to = _dateOnly(toDate);
    if (from.isAfter(to)) return;
    if (state.period == ReportsPeriod.custom &&
        from.isAtSameMomentAs(state.fromDate) &&
        to.isAtSameMomentAs(state.toDate)) {
      return;
    }
    load(period: ReportsPeriod.custom, fromDate: from, toDate: to);
  }
}
