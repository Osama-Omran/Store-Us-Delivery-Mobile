import 'stock_transfer_model.dart';

class StockTransfersResponse {
  const StockTransfersResponse({
    required this.success,
    required this.transfers,
    required this.meta,
    this.message,
  });

  final bool success;
  final List<StockTransferModel> transfers;
  final StockTransferPageMeta? meta;
  final String? message;

  factory StockTransfersResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    if (raw is! List) {
      throw const FormatException('Invalid warehouse transfers data');
    }

    return StockTransfersResponse(
      success: json['success'] == true,
      transfers: List.unmodifiable([
        for (final value in raw)
          if (value is Map)
            StockTransferModel.fromJson(Map<String, dynamic>.from(value)),
      ]),
      meta: json['meta'] is Map
          ? StockTransferPageMeta.fromJson(
              Map<String, dynamic>.from(json['meta'] as Map),
            )
          : null,
      message: json['message']?.toString(),
    );
  }
}

class StockTransferPageMeta {
  const StockTransferPageMeta({
    required this.page,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  final int page;
  final int perPage;
  final int total;
  final int lastPage;

  factory StockTransferPageMeta.fromJson(Map<String, dynamic> json) {
    int parse(String key, int fallback) =>
        int.tryParse(json[key]?.toString() ?? '') ?? fallback;

    return StockTransferPageMeta(
      page: parse('page', 1),
      perPage: parse('per_page', 20),
      total: parse('total', 0),
      lastPage: parse('last_page', 1),
    );
  }

  bool coversAll(List<StockTransferModel> loaded) =>
      page == 1 && lastPage == 1 && total == loaded.length;
}
