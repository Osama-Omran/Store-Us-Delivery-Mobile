enum StockTransferFilter {
  awaitingReceipt,
  onVehicle,
  awaitingWarehouse,
  completed,
  other,
}

enum StockTransferStatus {
  awaitingReceipt,
  onVehicle,
  awaitingWarehouse,
  completed,
  receiptDiscrepancy,
  other;

  StockTransferFilter get filter => switch (this) {
    awaitingReceipt => StockTransferFilter.awaitingReceipt,
    onVehicle => StockTransferFilter.onVehicle,
    awaitingWarehouse => StockTransferFilter.awaitingWarehouse,
    completed => StockTransferFilter.completed,
    receiptDiscrepancy || other => StockTransferFilter.other,
  };
}

class StockTransferActions {
  const StockTransferActions({
    this.canAccept = false,
    this.canArrive = false,
    this.canReceive = false,
    this.canResolveDiscrepancy = false,
  });

  final bool canAccept;
  final bool canArrive;
  final bool canReceive;
  final bool canResolveDiscrepancy;

  bool get needsAction =>
      canAccept || canArrive || canReceive || canResolveDiscrepancy;

  factory StockTransferActions.fromJson(Map<String, dynamic> json) {
    return StockTransferActions(
      canAccept: json['can_accept'] == true,
      canArrive: json['can_arrive'] == true,
      canReceive: json['can_receive'] == true,
      canResolveDiscrepancy: json['can_resolve_discrepancy'] == true,
    );
  }
}

class StockTransferItem {
  const StockTransferItem({
    required this.id,
    required this.itemCode,
    required this.itemName,
    required this.uom,
    required this.requestedQty,
    required this.sentQty,
    required this.receivedQty,
    required this.damagedQty,
  });

  final int id;
  final String itemCode;
  final String itemName;
  final String uom;
  final num requestedQty;
  final num sentQty;
  final num receivedQty;
  final num damagedQty;

  factory StockTransferItem.fromJson(Map<String, dynamic> json) {
    return StockTransferItem(
      id: _asInt(json['id']) ?? 0,
      itemCode: json['item_code']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      uom: json['uom']?.toString() ?? '',
      requestedQty: _asNum(json['requested_qty']) ?? 0,
      sentQty: _asNum(json['sent_qty']) ?? 0,
      receivedQty: _asNum(json['received_qty']) ?? 0,
      damagedQty: _asNum(json['damaged_qty']) ?? 0,
    );
  }
}

class StockTransferDocument {
  const StockTransferDocument({
    required this.id,
    required this.name,
    required this.url,
    this.mime,
    this.uploadedAt,
  });

  final String id;
  final String name;
  final String url;
  final String? mime;
  final DateTime? uploadedAt;

  factory StockTransferDocument.fromJson(Map<String, dynamic> json) {
    return StockTransferDocument(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      mime: json['mime']?.toString(),
      uploadedAt: _asDate(json['uploaded_at']),
    );
  }
}

class StockTransferModel {
  const StockTransferModel({
    required this.number,
    required this.sourceWarehouse,
    required this.destinationWarehouse,
    required this.vehicle,
    required this.representative,
    required this.itemCount,
    required this.totalQuantity,
    required this.createdAt,
    required this.status,
    this.id = 0,
    this.version = 0,
    this.statusCode = '',
    this.statusLabel = '',
    this.vehicleWarehouse,
    this.driver,
    this.representativeId,
    this.expectedArrival,
    this.sentAt,
    this.arrivedAt,
    this.acceptanceStatus,
    this.actions = const StockTransferActions(),
    this.items = const [],
    this.documents = const [],
  });

  final int id;
  final int version;
  final String number;
  final String sourceWarehouse;
  final String destinationWarehouse;
  final String vehicle;
  final String representative;
  final int? representativeId;
  final String? driver;
  final String? vehicleWarehouse;
  final int itemCount;
  final num totalQuantity;
  final DateTime? createdAt;
  final DateTime? expectedArrival;
  final DateTime? sentAt;
  final DateTime? arrivedAt;
  final String? acceptanceStatus;
  final String statusCode;
  final String statusLabel;
  final StockTransferStatus status;
  final StockTransferActions actions;
  final List<StockTransferItem> items;
  final List<StockTransferDocument> documents;

  bool get needsAction => actions.needsAction;

  factory StockTransferModel.fromJson(Map<String, dynamic> json) {
    final actions = StockTransferActions.fromJson(_asMap(json['actions']));
    final statusCode = (json['status']?.toString() ?? '').toUpperCase();
    final items = [
      for (final raw in (json['items'] as List?) ?? const [])
        if (raw is Map) StockTransferItem.fromJson(_asMap(raw)),
    ];
    final documents = [
      for (final raw in (json['documents'] as List?) ?? const [])
        if (raw is Map) StockTransferDocument.fromJson(_asMap(raw)),
    ];

    return StockTransferModel(
      id: _asInt(json['id']) ?? 0,
      version: _asInt(json['version']) ?? 0,
      number: json['number']?.toString() ?? '',
      statusCode: statusCode,
      statusLabel: json['status_label']?.toString() ?? '',
      status: _mapStatus(statusCode, actions),
      sourceWarehouse: json['source_warehouse']?.toString() ?? '',
      destinationWarehouse: json['destination_warehouse']?.toString() ?? '',
      vehicle: json['vehicle']?.toString() ?? '',
      vehicleWarehouse: json['vehicle_warehouse']?.toString(),
      driver: json['driver']?.toString(),
      representative: '', // API provides an ID, not a representative name.
      representativeId: _asInt(json['representative_id']),
      itemCount: items.length,
      totalQuantity: items.fold<num>(0, (total, item) => total + item.requestedQty),
      createdAt: _asDate(json['date']),
      // The GET response has no estimated arrival date.
      expectedArrival: null,
      sentAt: _asDate(json['sent_at']),
      arrivedAt: _asDate(json['arrived_at']),
      acceptanceStatus: _asMap(json['acceptance'])['status']?.toString(),
      actions: actions,
      items: List.unmodifiable(items),
      documents: List.unmodifiable(documents),
    );
  }
}

StockTransferStatus _mapStatus(
  String status,
  StockTransferActions actions,
) {
  if (actions.canAccept || status == 'READY_TO_SEND') {
    return StockTransferStatus.awaitingReceipt;
  }
  if (actions.canResolveDiscrepancy) {
    return StockTransferStatus.receiptDiscrepancy;
  }
  if (actions.canReceive) return StockTransferStatus.awaitingWarehouse;
  if (actions.canArrive) return StockTransferStatus.onVehicle;
  if (status == 'COMPLETED') return StockTransferStatus.completed;

  // Keep future backend statuses visible rather than silently misclassifying them.
  return StockTransferStatus.other;
}

num? _asNum(dynamic value) =>
    value is num ? value : num.tryParse(value?.toString() ?? '');

int? _asInt(dynamic value) => _asNum(value)?.toInt();

DateTime? _asDate(dynamic value) =>
    DateTime.tryParse(value?.toString() ?? '');

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : {};
