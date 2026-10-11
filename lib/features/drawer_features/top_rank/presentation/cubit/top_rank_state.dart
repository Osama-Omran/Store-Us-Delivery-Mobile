
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_response.dart';

class TopRankState {
  const TopRankState({
    this.period = TopRankPeriod.month,
    this.role = TopRankRole.representatives,
    this.category,
    this.periodData,
    this.warnings = const [],
    this.isLoading = false,
    this.error,
  });

  final TopRankPeriod period;
  final TopRankRole role;
  final TopRankCategory? category;
  final TopRankPeriodData? periodData;
  final List<String> warnings;
  final bool isLoading;
  final String? error;

  TopRankEntry? get winner => category?.winner;

  List<TopRankEntry> get entries =>
      category?.ranked ?? const [];

  bool get isEmpty =>
      !isLoading && error == null && entries.isEmpty;
}
