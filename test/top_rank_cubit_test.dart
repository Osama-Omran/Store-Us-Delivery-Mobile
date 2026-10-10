import 'package:flutter_test/flutter_test.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/cubit/top_rank_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/cubit/top_rank_state.dart';

void main() {
  test(
    'default rankings match the reference and keep unqualified entries last',
    () async {
      final cubit = TopRankCubit();
      expect(cubit.state.period, TopRankPeriod.thisMonth);
      expect(cubit.state.role, TopRankRole.representatives);
      expect(cubit.state.warehouse, TopRankWarehouse.all);
      expect(cubit.state.entries.map((entry) => entry.score), [
        94,
        91,
        88,
        84,
        79,
        null,
      ]);
      expect(cubit.state.winner!.name, 'أحمد محمد');
      expect(cubit.state.winner!.deliveryPercentage, 96);
      expect(cubit.state.winner!.collectionPercentage, 99);
      expect(cubit.state.winner!.extraSales, 18450);
      expect(cubit.state.entries.last.name, 'حسام فتحي');
      expect(cubit.state.entries.last.rank, isNull);
      await cubit.close();
    },
  );

  test(
    'period, role and warehouse selections update rankings together',
    () async {
      final cubit = TopRankCubit();
      final original = cubit.state;
      cubit.selectPeriod(TopRankPeriod.week);
      expect(cubit.state.winner!.name, isNot(original.winner!.name));
      cubit.selectRole(TopRankRole.drivers);
      expect(cubit.state.winner!.id, startsWith('drivers-'));
      cubit.selectWarehouse(TopRankWarehouse.nasrCity);
      expect(cubit.state.period, TopRankPeriod.week);
      expect(cubit.state.role, TopRankRole.drivers);
      expect(cubit.state.entries, hasLength(3));
      expect(
        cubit.state.entries.every(
          (entry) => entry.warehouse == TopRankWarehouse.nasrCity,
        ),
        isTrue,
      );
      expect(cubit.state.entries.map((entry) => entry.rank), [1, 2, null]);
      expect(original.winner!.name, 'أحمد محمد');

      for (final period in TopRankPeriod.values) {
        cubit.selectPeriod(period);
        for (final role in TopRankRole.values) {
          cubit.selectRole(role);
          for (final warehouse in TopRankWarehouse.values) {
            cubit.selectWarehouse(warehouse);
            final qualified = cubit.state.entries
                .where((entry) => entry.isQualified)
                .toList();
            expect(
              qualified.map((entry) => entry.rank),
              List.generate(qualified.length, (index) => index + 1),
            );
            expect(cubit.state.winner, same(qualified.first));
            expect(
              qualified.map((entry) => entry.score),
              orderedEquals(
                qualified.map((entry) => entry.score).toList()
                  ..sort((a, b) => b!.compareTo(a!)),
              ),
            );
          }
        }
      }
      await cubit.close();
    },
  );

  test('empty and unqualified-only results have no winner', () {
    expect(TopRankState(entries: []).winner, isNull);
    final state = TopRankState(
      entries: const [
        TopRankEntry(
          id: 'unqualified',
          name: 'حسام فتحي',
          warehouse: TopRankWarehouse.october,
        ),
      ],
    );
    expect(state.winner, isNull);
    expect(state.entries.single.rank, isNull);
  });

  test(
    'rank sorting handles ties deterministically without mutating input',
    () {
      final entries = [
        const TopRankEntry(
          id: 'b',
          name: 'ب',
          score: 90,
          warehouse: TopRankWarehouse.october,
        ),
        const TopRankEntry(
          id: 'u',
          name: 'غير مؤهل',
          warehouse: TopRankWarehouse.october,
        ),
        const TopRankEntry(
          id: 'a',
          name: 'أ',
          score: 90,
          warehouse: TopRankWarehouse.october,
        ),
      ];
      final state = TopRankState(entries: entries);
      expect(state.entries.map((entry) => entry.id), ['a', 'b', 'u']);
      expect(entries.map((entry) => entry.id), ['b', 'u', 'a']);
    },
  );
}
