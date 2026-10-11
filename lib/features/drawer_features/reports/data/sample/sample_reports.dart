import 'dart:math' as math;

import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';

final sampleReportsFromDate = DateTime(2026, 9, 1);
final sampleReportsToDate = DateTime(2026, 10, 4);

// ======= Local UI Preview Data ======= //
ReportsData buildSampleReports({
  required ReportsPeriod period,
  String tripNumber = allReportTrips,
  DateTime? fromDate,
  DateTime? toDate,
}) {
  final base = switch (period) {
    ReportsPeriod.today => const ReportsSummary(
      deliveredOrders: 18,
      partialOrders: 2,
      undeliveredOrders: 2,
      collectedAmount: 14650,
    ),
    ReportsPeriod.week => const ReportsSummary(
      deliveredOrders: 38,
      partialOrders: 4,
      undeliveredOrders: 2,
      collectedAmount: 28600,
    ),
    ReportsPeriod.month => const ReportsSummary(
      deliveredOrders: 76,
      partialOrders: 6,
      undeliveredOrders: 4,
      collectedAmount: 56750,
    ),
    ReportsPeriod.custom => const ReportsSummary(
      deliveredOrders: 58,
      partialOrders: 4,
      undeliveredOrders: 2,
      collectedAmount: 42100,
    ),
  };

  var summary = base;
  if (period == ReportsPeriod.custom) {
    final from = fromDate ?? sampleReportsFromDate;
    final to = toDate ?? sampleReportsToDate;
    final overlapStart = from.isAfter(sampleReportsFromDate)
        ? from
        : sampleReportsFromDate;
    final overlapEnd = to.isBefore(sampleReportsToDate)
        ? to
        : sampleReportsToDate;
    final days = _calendarDays(overlapStart, overlapEnd);
    final availableDays = _calendarDays(
      sampleReportsFromDate,
      sampleReportsToDate,
    );
    summary = _scaleSummary(base, days <= 0 ? 0 : days / availableDays);
  }

  // Reference trip percentages are separate preview metrics from the summary.
  const percentages = [88, 95, 90, 100, 92];
  if (tripNumber != allReportTrips) {
    final index = reportTripNumbers.indexOf(tripNumber);
    if (index < 0) {
      summary = _scaleSummary(summary, 0);
    } else {
      const shares = [0.18, 0.22, 0.20, 0.16, 0.24];
      final total = (summary.totalOrders * shares[index]).round();
      final delivered = (total * percentages[index] / 100).round();
      final remaining = total - delivered;
      summary = ReportsSummary(
        deliveredOrders: delivered,
        partialOrders: index.isEven ? remaining : 0,
        undeliveredOrders: index.isEven ? 0 : remaining,
        collectedAmount: total == 0
            ? 0
            : (summary.collectedAmount * shares[index]).round(),
      );
    }
  }

  return ReportsData(
    summary: summary,
    tripPerformance: List.unmodifiable([
      if (summary.totalOrders > 0)
        for (var index = 0; index < reportTripNumbers.length; index++)
          if (tripNumber == allReportTrips ||
              tripNumber == reportTripNumbers[index])
            ReportTripPerformance(
              tripNumber: reportTripNumbers[index],
              deliveryPercentage: percentages[index],
            ),
    ]),
  );
}

int _calendarDays(DateTime from, DateTime to) =>
    DateTime.utc(
      to.year,
      to.month,
      to.day,
    ).difference(DateTime.utc(from.year, from.month, from.day)).inDays +
    1;

ReportsSummary _scaleSummary(ReportsSummary summary, double factor) {
  final total = (summary.totalOrders * factor).round();
  final delivered = math.min(total, (summary.deliveredOrders * factor).round());
  final partial = math.min(
    total - delivered,
    (summary.partialOrders * factor).round(),
  );
  return ReportsSummary(
    deliveredOrders: delivered,
    partialOrders: partial,
    undeliveredOrders: total - delivered - partial,
    collectedAmount: total == 0
        ? 0
        : (summary.collectedAmount * factor).round(),
  );
}
