import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_models.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_wallet_response.dart';

/// Vehicle goods retain their original sample data and preview behavior.
/// The wallet is intentionally independent and is never fed by sample data.
class TreasuryState {
  const TreasuryState({
    required this.data,
    this.tab = TreasuryTab.wallet,
    this.preview = TreasuryPreview.activeTrip,
    this.searchQuery = '',
    this.wallet,
    this.walletLoading = false,
    this.walletLoadStarted = false,
    this.walletHasNoTrip = false,
    this.walletError,
  });

  final TreasuryData data;
  final TreasuryTab tab;
  final TreasuryPreview preview;
  final String searchQuery;

  final TreasuryWalletData? wallet;
  final bool walletLoading;
  final bool walletLoadStarted;
  final bool walletHasNoTrip;
  final String? walletError;

  // Legacy inventory calculations — deliberately unchanged.
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

  static const Object _unchanged = Object();

  TreasuryState copyWith({
    TreasuryTab? tab,
    TreasuryPreview? preview,
    String? searchQuery,
    Object? wallet = _unchanged,
    bool? walletLoading,
    bool? walletLoadStarted,
    bool? walletHasNoTrip,
    Object? walletError = _unchanged,
  }) {
    return TreasuryState(
      data: data,
      tab: tab ?? this.tab,
      preview: preview ?? this.preview,
      searchQuery: searchQuery ?? this.searchQuery,
      wallet: identical(wallet, _unchanged)
          ? this.wallet
          : wallet as TreasuryWalletData?,
      walletLoading: walletLoading ?? this.walletLoading,
      walletLoadStarted: walletLoadStarted ?? this.walletLoadStarted,
      walletHasNoTrip: walletHasNoTrip ?? this.walletHasNoTrip,
      walletError: identical(walletError, _unchanged)
          ? this.walletError
          : walletError as String?,
    );
  }
}
