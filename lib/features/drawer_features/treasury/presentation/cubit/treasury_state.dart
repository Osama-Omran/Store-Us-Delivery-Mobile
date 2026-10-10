import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_models.dart';

class TreasuryState {
  const TreasuryState({
    required this.data,
    this.tab = TreasuryTab.wallet,
    this.preview = TreasuryPreview.activeTrip,
    this.searchQuery = '',
  });

  final TreasuryData data;
  final TreasuryTab tab;
  final TreasuryPreview preview;
  final String searchQuery;

  bool get hasTrip => preview != TreasuryPreview.noTrip;

  int get custodyBalance =>
      preview == TreasuryPreview.activeTrip ? data.cashTotal : 0;

  List<TreasuryCollection> get collections =>
      hasTrip ? data.collections : const [];

  List<TreasuryInventoryItem> get inventory =>
      preview == TreasuryPreview.activeTrip ? data.inventory : const [];

  int get remainingUnits =>
      inventory.fold(0, (total, item) => total + item.remainingQuantity);

  List<TreasuryInventoryItem> get filteredInventory {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return inventory;
    return List.unmodifiable(
      inventory.where(
        (item) =>
            item.name.toLowerCase().contains(query) ||
            item.code.toLowerCase().contains(query),
      ),
    );
  }

  TreasuryState copyWith({
    TreasuryTab? tab,
    TreasuryPreview? preview,
    String? searchQuery,
  }) {
    return TreasuryState(
      data: data,
      tab: tab ?? this.tab,
      preview: preview ?? this.preview,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
