import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';

class ReportsState {
  const ReportsState({
    required this.data,
    required this.fromDate,
    required this.toDate,
    this.period = ReportsPeriod.today,
    this.tripNumber = allReportTrips,
  });

  final ReportsData data;
  final ReportsPeriod period;
  final DateTime fromDate;
  final DateTime toDate;
  final String tripNumber;
}
