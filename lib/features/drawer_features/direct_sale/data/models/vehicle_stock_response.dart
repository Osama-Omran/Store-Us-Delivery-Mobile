/// Compatibility model name: existing Direct Sale architecture still calls
/// this VehicleStock*. Its source is now GET /trips/{tripId}/pos/options.
/// POS options provide authoritative AVAILABLE quantities and RATE prices.
/// Do NOT read the old vehicle-stock fields (remaining_qty, has_stock, etc.).
class VehicleStockResponse {
  const VehicleStockResponse({required this.data});

  final VehicleStockData data;

  factory VehicleStockResponse.fromJson(Map<String, dynamic> json) {
    if (json['success'] != true || json['data'] is! Map) {
      throw const FormatException('Invalid POS options response');
    }
    return VehicleStockResponse(
      data: VehicleStockData.fromJson(
        Map<String, dynamic>.from(json['data'] as Map),
      ),
    );
  }
}

class VehicleStockData {
  const VehicleStockData({required this.items, required this.currency, required this.customers});

  final List<VehicleStockItem> items;
  final String currency;
  final List<PosCustomerOption> customers;

  /// The POS endpoint no longer supplies a trip status or warehouse, so
  /// availability must come from `available` on each item, not has_stock.
  List<VehicleStockItem> get sellableItems => List.unmodifiable(
    items.where((item) => item.available > 0),
  );

  factory VehicleStockData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final rawCurrency = json['currency'];
    if (rawItems is! List || rawCurrency is! String ||
        rawCurrency.trim().isEmpty) {
      throw const FormatException('Missing POS items or currency');
    }
    final items = rawItems.map((raw) {
      if (raw is! Map) {
        throw const FormatException('Invalid POS item');
      }
      return VehicleStockItem.fromJson(Map<String, dynamic>.from(raw));
    }).toList(growable: false);
    final codes = items.map((item) => item.itemCode).toSet();
    if (codes.length != items.length) {
      // Cart quantities are currently indexed by item_code.
      throw const FormatException('Duplicate POS item codes');
    }
    final rawCustomers = json['customers'];
    if (rawCustomers is! List) {
      throw const FormatException('Missing POS customers');
    }
    final customers = <PosCustomerOption>[];
    final ids = <String>{};
    for (final raw in rawCustomers) {
      if (raw is! Map) throw const FormatException('Invalid POS customer');
      final customer = PosCustomerOption.fromJson(
        Map<String, dynamic>.from(raw),
      );
      if (ids.add(customer.id)) customers.add(customer);
    }
    return VehicleStockData(
      currency: rawCurrency,
      items: List.unmodifiable(items),
      customers: List.unmodifiable(customers),
    );
  }
}

class VehicleStockItem {
  const VehicleStockItem({
    required this.itemCode,
    required this.itemName,
    required this.uom,
    required this.available,
    required this.rateMinor,
  });

  final String itemCode;
  final String itemName;
  final String uom;
  final num available;

  /// Price in the smallest currency unit (EGP piasters) to avoid float sums.
  final int rateMinor;

  factory VehicleStockItem.fromJson(Map<String, dynamic> json) {
    final code = json['item_code'];
    final quantity = json['available'];
    final rate = json['rate'];
    if (code is! String || code.trim().isEmpty ||
        quantity is! num || !quantity.isFinite || quantity < 0 ||
        rate is! num || !rate.isFinite || rate < 0) {
      throw const FormatException('Invalid POS item code, quantity or rate');
    }

    // POS rate is in full units (e.g. 647 EGP), while the cart uses cents.
    // Reject unsupported precision instead of quietly changing the price.
    final minor = (rate * 100).toDouble();
    if (!minor.isFinite || minor > 9007199254740991 ||
        (minor - minor.roundToDouble()).abs() > 1e-6) {
      throw const FormatException('Unsupported POS price precision');
    }
    return VehicleStockItem(
      itemCode: code,
      itemName: json['item_name']?.toString() ?? code,
      uom: json['uom']?.toString() ?? '',
      available: quantity,
      rateMinor: minor.round(),
    );
  }
}


/// The POS backend expects customer_id == the `name` field, not the label.
class PosCustomerOption {
  const PosCustomerOption({
    required this.id,
    required this.displayName,
    this.mobileNo,
  });

  final String id;
  final String displayName;
  final String? mobileNo;

  factory PosCustomerOption.fromJson(Map<String, dynamic> json) {
    final id = json['name'];
    if (id is! String || id.trim().isEmpty) {
      throw const FormatException('Invalid POS customer id');
    }
    final label = json['customer_name'];
    final mobile = json['mobile_no'];
    return PosCustomerOption(
      id: id, // preserve the backend customer key exactly
      displayName: label is String && label.trim().isNotEmpty ? label : id,
      mobileNo: mobile is String && mobile.trim().isNotEmpty ? mobile : null,
    );
  }
}
