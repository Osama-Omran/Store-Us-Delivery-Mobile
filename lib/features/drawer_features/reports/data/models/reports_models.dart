enum ReportsPeriod { today, week, month, custom }

const allReportTrips = 'all';
const reportTripNumbers = [
  'TRIP-0021',
  'TRIP-0022',
  'TRIP-0023',
  'TRIP-0024',
  'TRIP-0025',
];

class ReportsSummary {
  const ReportsSummary({
    required this.deliveredOrders,
    required this.partialOrders,
    required this.undeliveredOrders,
    required this.collectedAmount,
  });

  final int deliveredOrders;
  final int partialOrders;
  final int undeliveredOrders;
  final int collectedAmount;

  int get totalOrders => deliveredOrders + partialOrders + undeliveredOrders;
  int get deliveryPercentage =>
      totalOrders == 0 ? 0 : (deliveredOrders / totalOrders * 100).round();
}

class ReportTripPerformance {
  const ReportTripPerformance({
    required this.tripNumber,
    required this.deliveryPercentage,
  });

  final String tripNumber;
  final int deliveryPercentage;
}

class ReportsData {
  const ReportsData({required this.summary, required this.tripPerformance});

  final ReportsSummary summary;
  final List<ReportTripPerformance> tripPerformance;

  bool get isEmpty => summary.totalOrders == 0;
}
