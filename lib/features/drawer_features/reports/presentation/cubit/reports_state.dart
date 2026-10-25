import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';

class ReportsState {
  const ReportsState({
    required this.fromDate,
    required this.toDate,
    this.period = ReportsPeriod.today,
    this.tripNumber = allReportTrips,
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  final ReportsPeriod period;
  final DateTime fromDate;
  final DateTime toDate;
  final String tripNumber;
  final ReportsData? data;
  final bool isLoading;
  final String? errorMessage;

  ReportTripPerformance? get selectedTrip {
    if (tripNumber == allReportTrips || data == null) return null;
    for (final trip in data!.tripPerformance) {
      if (trip.tripNumber == tripNumber) return trip;
    }
    return null;
  }

  ReportsSummary? get summary {
    final report = data;
    if (report == null) return null;
    if (tripNumber == allReportTrips) return report.summary;
    final trip = selectedTrip;
    return trip == null ? null : ReportsSummary.fromTrip(trip);
  }

  // Per-trip status distribution is not part of the API contract.
  List<ReportOrderDistribution>? get distribution =>
      tripNumber == allReportTrips ? data?.distribution : null;

  List<ReportTripPerformance> get displayedTrips {
    final trips = data?.tripPerformance ?? const <ReportTripPerformance>[];
    if (tripNumber == allReportTrips) return trips;
    return trips.where((trip) => trip.tripNumber == tripNumber).toList();
  }
}
