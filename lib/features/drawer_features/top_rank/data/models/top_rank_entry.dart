enum TopRankPeriod { today, week, thisMonth, previousMonth }

enum TopRankRole { representatives, drivers, dispatchers }

enum TopRankWarehouse { all, october, nasrCity }

class TopRankEntry {
  const TopRankEntry({
    required this.id,
    required this.name,
    required this.warehouse,
    this.rank,
    this.score,
    this.deliveryPercentage,
    this.collectionPercentage,
    this.extraSales,
    this.movement = 0,
    this.portraitAsset,
  });

  final String id;
  final String name;
  final TopRankWarehouse warehouse;
  final int? rank;
  final int? score;
  final int? deliveryPercentage;
  final int? collectionPercentage;
  final num? extraSales;
  final int movement;
  final String? portraitAsset;

  bool get isQualified => score != null;

  TopRankEntry withRank(int? rank) {
    return TopRankEntry(
      id: id,
      name: name,
      warehouse: warehouse,
      rank: rank,
      score: score,
      deliveryPercentage: deliveryPercentage,
      collectionPercentage: collectionPercentage,
      extraSales: extraSales,
      movement: movement,
      portraitAsset: portraitAsset,
    );
  }
}
