import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';

class TopRankState {
  TopRankState({
    this.period = TopRankPeriod.thisMonth,
    this.role = TopRankRole.representatives,
    this.warehouse = TopRankWarehouse.all,
    required List<TopRankEntry> entries,
  }) : entries = _rankEntries(entries);

  final TopRankPeriod period;
  final TopRankRole role;
  final TopRankWarehouse warehouse;
  final List<TopRankEntry> entries;

  TopRankEntry? get winner {
    return entries.isNotEmpty && entries.first.isQualified
        ? entries.first
        : null;
  }

  static List<TopRankEntry> _rankEntries(List<TopRankEntry> entries) {
    final sorted = List<TopRankEntry>.of(entries)
      ..sort((a, b) {
        if (a.isQualified != b.isQualified) return a.isQualified ? -1 : 1;
        final scoreOrder = (b.score ?? 0).compareTo(a.score ?? 0);
        return scoreOrder != 0 ? scoreOrder : a.id.compareTo(b.id);
      });

    return List.unmodifiable([
      for (var index = 0; index < sorted.length; index++)
        sorted[index].withRank(sorted[index].isQualified ? index + 1 : null),
    ]);
  }
}
