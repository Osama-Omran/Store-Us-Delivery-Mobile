
class LoadedItemsResponse {
  final bool success;
  final LoadedItemsData? data;
  final String? message;

  const LoadedItemsResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory LoadedItemsResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return LoadedItemsResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] is Map
          ? LoadedItemsData.fromJson(
        Map<String, dynamic>.from(json['data'] as Map),
      )
          : null,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data?.toJson(),
    if (message != null) 'message': message,
  };
}

class LoadedItemsData {
  final String trip;
  final List<LoadedTripItem> items;
  final LoadedItemsTotals? totals;

  const LoadedItemsData({
    required this.trip,
    required this.items,
    this.totals,
  });

  factory LoadedItemsData.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawItems = json['items'] as List<dynamic>? ?? [];

    return LoadedItemsData(
      trip: json['trip']?.toString() ?? '',
      items: rawItems
          .map(
            (item) => LoadedTripItem.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
      totals: json['totals'] is Map
          ? LoadedItemsTotals.fromJson(
        Map<String, dynamic>.from(json['totals'] as Map),
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'trip': trip,
    'items': items.map((item) => item.toJson()).toList(),
    'totals': totals?.toJson(),
  };
}

class LoadedTripItem {
  final String itemCode;
  final String itemName;
  final String? uom;
  final num loadedQty;
  final String source;

  const LoadedTripItem({
    required this.itemCode,
    required this.itemName,
    this.uom,
    required this.loadedQty,
    required this.source,
  });

  factory LoadedTripItem.fromJson(
      Map<String, dynamic> json,
      ) {
    return LoadedTripItem(
      itemCode: json['item_code']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      uom: json['uom']?.toString(),
      loadedQty: _parseQuantity(json['loaded_qty']),
      source: json['source']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'item_code': itemCode,
    'item_name': itemName,
    'uom': uom,
    'loaded_qty': loadedQty,
    'source': source,
  };
}

class LoadedItemsTotals {
  final int items;
  final num qty;

  const LoadedItemsTotals({
    required this.items,
    required this.qty,
  });

  factory LoadedItemsTotals.fromJson(
      Map<String, dynamic> json,
      ) {
    return LoadedItemsTotals(
      items: _parseQuantity(json['items']).toInt(),
      qty: _parseQuantity(json['qty']),
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items,
    'qty': qty,
  };
}

num _parseQuantity(dynamic value) {
  if (value is num) return value;

  if (value is String) {
    final parsed = num.tryParse(value);
    if (parsed != null) return parsed;
  }

  throw const FormatException('Invalid quantity');
}
