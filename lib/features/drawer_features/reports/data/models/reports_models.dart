enum ReportsPeriod { today, week, month, custom }

const allReportTrips = 'all';

num _asNumber(Object? value) =>
    value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;

int _asInt(Object? value) => _asNumber(value).toInt();

Map<String, dynamic> _asMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<Map<String, dynamic>> _asObjects(Object? value) => value is List
    ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const [];

class ReportsSummary {
  const ReportsSummary({
    required this.totalOrders,
    required this.deliveredOrders,
    required this.partialOrders,
    required this.deliveryPercentage,
    required this.collectedAmount,
    this.undeliveredOrders,
    this.invoicedAmount,
    this.outstandingAmount,
    this.receivedByWarehouse,
    this.custodyBalance,
  });

  final int totalOrders;
  final int deliveredOrders;
  final int partialOrders;
  final int? undeliveredOrders;
  final num deliveryPercentage;
  final num collectedAmount;
  final num? invoicedAmount;
  final num? outstandingAmount;
  final num? receivedByWarehouse;
  final num? custodyBalance;

  factory ReportsSummary.fromOverview(Map<String, dynamic> json) {
    final orders = _asMap(json['orders']);
    final sales = _asMap(json['sales']);
    final collections = _asMap(json['collections']);
    return ReportsSummary(
      totalOrders: _asInt(orders['total']),
      deliveredOrders: _asInt(orders['delivered']),
      partialOrders: _asInt(orders['partial']),
      undeliveredOrders: orders['not_delivered'] == null
          ? null
          : _asInt(orders['not_delivered']),
      deliveryPercentage: _asNumber(json['delivery_rate']),
      collectedAmount: _asNumber(collections['amount']),
      invoicedAmount: sales['invoiced_amount'] == null
          ? null
          : _asNumber(sales['invoiced_amount']),
      outstandingAmount: sales['outstanding_amount'] == null
          ? null
          : _asNumber(sales['outstanding_amount']),
      receivedByWarehouse: collections['received_by_warehouse'] == null
          ? null
          : _asNumber(collections['received_by_warehouse']),
      custodyBalance: collections['custody_balance'] == null
          ? null
          : _asNumber(collections['custody_balance']),
    );
  }

  factory ReportsSummary.fromTrip(ReportTripPerformance trip) => ReportsSummary(
        totalOrders: trip.ordersTotal,
        deliveredOrders: trip.delivered,
        partialOrders: trip.partial,
        // The trip API has no not_delivered, pending or cancelled breakdown.
        undeliveredOrders: null,
        deliveryPercentage: trip.deliveryPercentage,
        collectedAmount: trip.collectedAmount,
        invoicedAmount: trip.invoicedAmount,
        // Outstanding cannot be reliably inferred from invoiced - collected.
        outstandingAmount: null,
        receivedByWarehouse: trip.receivedByWarehouse,
        custodyBalance: trip.custodyBalance,
      );
}

class ReportOrderDistribution {
  const ReportOrderDistribution({
    required this.status,
    required this.count,
    required this.percentage,
  });

  final String status;
  final int count;
  final num percentage;

  factory ReportOrderDistribution.fromJson(Map<String, dynamic> json) =>
      ReportOrderDistribution(
        status: json['status']?.toString() ?? '',
        count: _asInt(json['count']),
        percentage: _asNumber(json['percentage']),
      );
}

class ReportTripPerformance {
  const ReportTripPerformance({
    required this.id,
    required this.tripNumber,
    required this.status,
    required this.ordersTotal,
    required this.delivered,
    required this.partial,
    required this.deliveryPercentage,
    required this.invoicedAmount,
    required this.collectedAmount,
    required this.receivedByWarehouse,
    required this.custodyBalance,
    this.date,
  });

  final int id;
  final String tripNumber;
  final String status;
  final DateTime? date;
  final int ordersTotal;
  final int delivered;
  final int partial;
  final num deliveryPercentage;
  final num invoicedAmount;
  final num collectedAmount;
  final num receivedByWarehouse;
  final num custodyBalance;

  factory ReportTripPerformance.fromJson(Map<String, dynamic> json) =>
      ReportTripPerformance(
        id: _asInt(json['id']),
        tripNumber: json['trip_number']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        date: DateTime.tryParse(json['trip_date']?.toString() ?? ''),
        ordersTotal: _asInt(json['orders_total']),
        delivered: _asInt(json['delivered']),
        partial: _asInt(json['partial']),
        deliveryPercentage: _asNumber(json['delivery_rate']),
        invoicedAmount: _asNumber(json['invoiced_amount']),
        collectedAmount: _asNumber(json['collected_amount']),
        receivedByWarehouse: _asNumber(json['received_by_warehouse']),
        custodyBalance: _asNumber(json['custody_balance']),
      );
}

class ReportsData {
  const ReportsData({
    required this.summary,
    required this.tripPerformance,
    required this.distribution,
    required this.fromDate,
    required this.toDate,
    this.currency = 'EGP',
    this.warnings = const [],
  });

  final ReportsSummary summary;
  final List<ReportTripPerformance> tripPerformance;
  final List<ReportOrderDistribution> distribution;
  final DateTime fromDate;
  final DateTime toDate;
  final String currency;
  final List<String> warnings;

  bool get isEmpty => summary.totalOrders == 0 && tripPerformance.isEmpty;

  factory ReportsData.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    if (json['success'] != true || data.isEmpty) {
      throw FormatException(json['message']?.toString() ?? 'Invalid report');
    }
    final period = _asMap(data['period']);
    final from = DateTime.tryParse(period['from']?.toString() ?? '');
    final to = DateTime.tryParse(period['to']?.toString() ?? '');
    if (from == null || to == null) {
      throw const FormatException('Missing report period');
    }
    return ReportsData(
      summary: ReportsSummary.fromOverview(data),
      tripPerformance: _asObjects(data['trip_performance'])
          .map(ReportTripPerformance.fromJson)
          .toList(growable: false),
      distribution: _asObjects(data['order_distribution'])
          .map(ReportOrderDistribution.fromJson)
          .toList(growable: false),
      fromDate: from,
      toDate: to,
      currency: data['currency']?.toString() ?? 'EGP',
      warnings: data['warnings'] is List
          ? (data['warnings'] as List).map((value) => value.toString()).toList()
          : const [],
    );
  }
}
