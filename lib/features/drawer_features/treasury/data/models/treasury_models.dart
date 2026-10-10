enum TreasuryTab { wallet, vehicleGoods }

enum TreasuryPreview { activeTrip, settled, noTrip }

enum TreasuryPaymentMethod { cash, instaPay, electronicWallet }

enum TreasuryItemSource { tripOrders, extra }

class TreasuryCollection {
  const TreasuryCollection({
    required this.orderNumber,
    required this.customerName,
    required this.collectedAt,
    required this.deliveredAmount,
    required this.receivedAmount,
    required this.paymentMethod,
    required this.cashBalanceAfter,
  });

  final String orderNumber;
  final String customerName;
  final DateTime collectedAt;
  final int deliveredAmount;
  final int receivedAmount;
  final TreasuryPaymentMethod paymentMethod;
  final int cashBalanceAfter;

  int get custodyImpact =>
      paymentMethod == TreasuryPaymentMethod.cash ? receivedAmount : 0;
}

class TreasuryInventoryItem {
  const TreasuryInventoryItem({
    required this.code,
    required this.name,
    required this.unit,
    required this.loadedQuantity,
    required this.deliveredQuantity,
    required this.source,
  });

  final String code;
  final String name;
  final String unit;
  final int loadedQuantity;
  final int deliveredQuantity;
  final TreasuryItemSource source;

  int get remainingQuantity => loadedQuantity - deliveredQuantity;
}

class TreasuryData {
  TreasuryData({
    required this.tripNumber,
    required this.vehicleName,
    required List<TreasuryCollection> collections,
    required List<TreasuryInventoryItem> inventory,
  }) : collections = List.unmodifiable(collections),
       inventory = List.unmodifiable(inventory);

  final String tripNumber;
  final String vehicleName;
  final List<TreasuryCollection> collections;
  final List<TreasuryInventoryItem> inventory;

  int get deliveredTotal =>
      collections.fold(0, (total, entry) => total + entry.deliveredAmount);

  int get collectedTotal =>
      collections.fold(0, (total, entry) => total + entry.receivedAmount);

  int get cashTotal =>
      collections.fold(0, (total, entry) => total + entry.custodyImpact);
}
