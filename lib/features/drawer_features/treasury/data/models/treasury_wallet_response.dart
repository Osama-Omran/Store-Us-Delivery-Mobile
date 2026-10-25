
class TripWalletResponse {
  const TripWalletResponse({
    required this.success,
    this.data,
    this.message,
  });

  final bool success;
  final TripWalletData? data;
  final String? message;

  factory TripWalletResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return TripWalletResponse(
      success: json['success'] == true,
      data: rawData is Map
          ? TripWalletData.fromJson(
        Map<String, dynamic>.from(rawData),
      )
          : null,
      message: json['message']?.toString(),
    );
  }
}

class TripWalletData {
  const TripWalletData({
    required this.trip,
    required this.custodyBalance,
    required this.balanceSource,
    required this.settlementStatus,
    required this.totalCollected,
    required this.totalReceivedByWarehouse,
    required this.transactions,
    required this.cashReceipts,
  });

  final String trip;
  final num custodyBalance;
  final String balanceSource;
  final String settlementStatus;
  final num totalCollected;
  final num totalReceivedByWarehouse;
  final List<TripWalletTransaction> transactions;

  // API currently returns an empty list.
  // Preserve future receipt data without assuming a schema.
  final List<Map<String, dynamic>> cashReceipts;

  factory TripWalletData.fromJson(Map<String, dynamic> json) {
    final rawTransactions = json['transactions'];
    final rawReceipts = json['cash_receipts'];

    return TripWalletData(
      trip: json['trip']?.toString() ?? '',
      custodyBalance: _parseAmount(json['custody_balance']),
      balanceSource: json['balance_source']?.toString() ?? '',
      settlementStatus:
      json['settlement_status']?.toString() ?? '',
      totalCollected: _parseAmount(json['total_collected']),
      totalReceivedByWarehouse:
      _parseAmount(json['total_received_by_warehouse']),
      transactions: List.unmodifiable(
        rawTransactions is List
            ? rawTransactions.whereType<Map>().map(
              (item) => TripWalletTransaction.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            : <TripWalletTransaction>[],
      ),
      cashReceipts: List.unmodifiable(
        rawReceipts is List
            ? rawReceipts.whereType<Map>().map(
              (item) => Map<String, dynamic>.from(item),
        )
            : <Map<String, dynamic>>[],
      ),
    );
  }
}

class TripWalletTransaction {
  const TripWalletTransaction({
    required this.salesOrder,
    required this.customer,
    required this.collectedAmount,
    required this.paymentMethod,
    required this.walletEffect,
    required this.paymentEntryId,
    required this.collectedAt,
  });

  final String salesOrder;
  final String customer;
  final num collectedAmount;
  final String paymentMethod;
  final num walletEffect;
  final String? paymentEntryId;
  final DateTime? collectedAt;

  factory TripWalletTransaction.fromJson(
      Map<String, dynamic> json,
      ) {
    return TripWalletTransaction(
      salesOrder: json['sales_order']?.toString() ?? '',
      customer: json['customer']?.toString() ?? '',
      collectedAmount: _parseAmount(json['collected_amount']),
      paymentMethod: json['payment_method']?.toString() ?? '',
      walletEffect: _parseAmount(json['wallet_effect']),
      paymentEntryId: json['payment_entry_id']?.toString(),
      collectedAt: DateTime.tryParse(
        json['collected_at']?.toString() ?? '',
      ),
    );
  }
}

num _parseAmount(dynamic value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '') ?? 0;
}

// Compatibility with the existing Treasury files.
typedef TreasuryWalletResponse = TripWalletResponse;
typedef TreasuryWalletData = TripWalletData;
typedef TreasuryWalletTransaction = TripWalletTransaction;
