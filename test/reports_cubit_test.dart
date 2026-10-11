import 'package:flutter_test/flutter_test.dart';
import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';
import 'package:storeus_delivery/features/drawer_features/reports/data/sample/sample_reports.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/cubit/reports_cubit.dart';

void main() {
  test(
    'today and initial custom range reproduce the reference summaries',
    () async {
      final cubit = ReportsCubit();
      addTearDown(cubit.close);
      expect(cubit.state.period, ReportsPeriod.today);
      expect(cubit.state.tripNumber, allReportTrips);
      expect(cubit.state.fromDate, DateTime(2026, 9, 1));
      expect(cubit.state.toDate, DateTime(2026, 10, 4));
      final today = cubit.state.data.summary;
      expect(
        [
          today.totalOrders,
          today.deliveredOrders,
          today.partialOrders,
          today.undeliveredOrders,
          today.deliveryPercentage,
          today.collectedAmount,
        ],
        [22, 18, 2, 2, 82, 14650],
      );
      expect(
        cubit.state.data.tripPerformance.map((trip) => trip.deliveryPercentage),
        [88, 95, 90, 100, 92],
      );
      cubit.selectPeriod(ReportsPeriod.custom);
      final custom = cubit.state.data.summary;
      expect(
        [
          custom.totalOrders,
          custom.deliveredOrders,
          custom.partialOrders,
          custom.undeliveredOrders,
          custom.deliveryPercentage,
          custom.collectedAmount,
        ],
        [64, 58, 4, 2, 91, 42100],
      );
    },
  );

  test(
    'period and trip changes keep totals consistent and preserve selections',
    () async {
      final cubit = ReportsCubit();
      addTearDown(cubit.close);
      for (final period in ReportsPeriod.values) {
        cubit.selectPeriod(period);
        for (final trip in reportTripNumbers) {
          cubit.selectTrip(trip);
          final summary = cubit.state.data.summary;
          expect(summary.totalOrders, greaterThan(0));
          expect(summary.collectedAmount, greaterThan(0));
          expect(summary.deliveryPercentage, inInclusiveRange(0, 100));
          expect(cubit.state.data.tripPerformance.single.tripNumber, trip);
          expect(cubit.state.fromDate, sampleReportsFromDate);
          expect(cubit.state.toDate, sampleReportsToDate);
        }
        final selectedTrip = cubit.state.tripNumber;
        cubit.selectPeriod(ReportsPeriod.today);
        expect(cubit.state.tripNumber, selectedTrip);
        cubit.selectTrip(allReportTrips);
        expect(cubit.state.data.tripPerformance, hasLength(5));
      }
    },
  );

  test(
    'custom range includes both endpoints and survives period switching',
    () async {
      final cubit = ReportsCubit();
      addTearDown(cubit.close);
      cubit.selectPeriod(ReportsPeriod.custom);
      cubit.selectDateRange(
        fromDate: DateTime(2026, 9, 1, 15),
        toDate: DateTime(2026, 9, 1, 20),
      );
      expect(cubit.state.fromDate, DateTime(2026, 9, 1));
      expect(cubit.state.toDate, DateTime(2026, 9, 1));
      expect(cubit.state.data.summary.totalOrders, 2);
      cubit.selectPeriod(ReportsPeriod.week);
      expect(cubit.state.data.summary.totalOrders, 44);
      cubit.selectPeriod(ReportsPeriod.month);
      expect(cubit.state.data.summary.totalOrders, 86);
      cubit.selectPeriod(ReportsPeriod.custom);
      expect(cubit.state.data.summary.totalOrders, 2);
      expect(cubit.state.toDate, DateTime(2026, 9, 1));
    },
  );

  test(
    'out-of-range custom dates return a zero summary without trip metrics',
    () async {
      final cubit = ReportsCubit();
      addTearDown(cubit.close);
      cubit.selectPeriod(ReportsPeriod.custom);
      cubit.selectDateRange(
        fromDate: DateTime(2025, 1, 1),
        toDate: DateTime(2025, 2, 1),
      );
      expect(cubit.state.data.isEmpty, isTrue);
      expect(cubit.state.data.summary.deliveryPercentage, 0);
      expect(cubit.state.data.summary.collectedAmount, 0);
      expect(cubit.state.data.tripPerformance, isEmpty);
      cubit.selectTrip('TRIP-0021');
      expect(cubit.state.data.isEmpty, isTrue);
      expect(cubit.state.data.summary.deliveryPercentage, 0);
    },
  );

  test(
    'invalid ranges, unknown trips, and repeated selections preserve state',
    () async {
      final cubit = ReportsCubit();
      addTearDown(cubit.close);
      final initial = cubit.state;
      cubit.selectDateRange(
        fromDate: DateTime(2026, 10, 5),
        toDate: DateTime(2026, 10, 4),
      );
      cubit.selectTrip('TRIP-9999');
      cubit.selectPeriod(ReportsPeriod.today);
      cubit.selectTrip(allReportTrips);
      cubit.selectDateRange(
        fromDate: sampleReportsFromDate,
        toDate: sampleReportsToDate,
      );
      expect(cubit.state, same(initial));
    },
  );

  test(
    'a trip with zero orders has no collection in a short custom range',
    () async {
      final cubit = ReportsCubit();
      addTearDown(cubit.close);
      cubit.selectPeriod(ReportsPeriod.custom);
      cubit.selectDateRange(
        fromDate: DateTime(2026, 9, 1),
        toDate: DateTime(2026, 9, 1),
      );
      cubit.selectTrip('TRIP-0021');
      expect(cubit.state.data.summary.totalOrders, 0);
      expect(cubit.state.data.summary.collectedAmount, 0);
      expect(cubit.state.data.tripPerformance, isEmpty);
    },
  );
}
