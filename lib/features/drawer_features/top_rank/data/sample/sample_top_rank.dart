import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';

// ======= Local UI Preview Data ======= //
List<TopRankEntry> buildSampleTopRank({
  required TopRankPeriod period,
  required TopRankRole role,
  required TopRankWarehouse warehouse,
}) {
  final names = switch (role) {
    TopRankRole.representatives => const [
      'أحمد محمد',
      'محمود علي',
      'كريم حسن',
      'عمرو سامي',
      'يوسف عادل',
      'حسام فتحي',
    ],
    TopRankRole.drivers => const [
      'محمد خالد',
      'علي إبراهيم',
      'خالد حسن',
      'سامي أحمد',
      'عادل محمود',
      'طارق فتحي',
    ],
    TopRankRole.dispatchers => const [
      'مصطفى أحمد',
      'إبراهيم محمد',
      'حسن خالد',
      'عمر علي',
      'محمود سامي',
      'أحمد فتحي',
    ],
  };

  const scores = [94, 91, 88, 84, 79];
  const delivery = [96, 94, 92, 90, 88];
  const collection = [99, 98, 97, 96, 95];
  const sales = [18450, 16200, 14750, 12600, 9800];
  const movements = [1, -1, 2, -1, -1];
  final periodOffset = switch (period) {
    TopRankPeriod.today => 2,
    TopRankPeriod.week => 1,
    TopRankPeriod.thisMonth => 0,
    TopRankPeriod.previousMonth => 3,
  };

  return [
    for (var index = 0; index < names.length; index++)
      if (warehouse == TopRankWarehouse.all ||
          warehouse ==
              (index.isEven
                  ? TopRankWarehouse.october
                  : TopRankWarehouse.nasrCity))
        TopRankEntry(
          id: '${role.name}-$index',
          name: names[index],
          warehouse: index.isEven
              ? TopRankWarehouse.october
              : TopRankWarehouse.nasrCity,
          score: index == 5 ? null : scores[(index + periodOffset) % 5],
          deliveryPercentage: index == 5
              ? null
              : delivery[(index + periodOffset) % 5],
          collectionPercentage: index == 5
              ? null
              : collection[(index + periodOffset) % 5],
          extraSales: index == 5 ? null : sales[(index + periodOffset) % 5],
          movement: index == 5 ? 0 : movements[(index + periodOffset) % 5],
        ),
  ];
}
