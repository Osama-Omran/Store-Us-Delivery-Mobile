import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/models/areas_route_data.dart';

class AreasRouteOverview extends StatelessWidget {
  const AreasRouteOverview({
    super.key,
    required this.route,
    required this.onMap,
  });

  final AreasRouteData route;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    final warehouse = route.trip.warehouse?.name?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _Metric(
                value: route.total,
                label: context.strings.areas_stops,
                color: AppColors.black1,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Metric(
                value: route.finished,
                label: context.strings.areas_finished,
                color: AppColors.green0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Metric(
                value: route.remaining,
                label: context.strings.remaining_orders,
                color: AppColors.orange0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.format_list_bulleted_rounded, size: 20),
                label: Text(context.strings.areas_list),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white0,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onMap,
                icon: const Icon(Icons.map_outlined, size: 20),
                label: Text(context.strings.areas_map),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.grey4,
                  backgroundColor: AppColors.white0,
                  side: const BorderSide(color: AppColors.grey3),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (route.missingCoordinates > 0) ...[
          const SizedBox(height: 12),
          Text(
            context.strings.areas_missing_coordinates(route.missingCoordinates),
            style: Styles.textStyle12.copyWith(color: AppColors.grey4),
          ),
        ],
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          decoration: BoxDecoration(
            color: AppColors.rankNavy,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white0.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warehouse_outlined,
                  color: AppColors.white0,
                  size: 26,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.strings.areas_starting_point,
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.grey3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      warehouse?.isNotEmpty == true
                          ? warehouse!
                          : context.strings.areas_warehouse_unavailable,
                      style: Styles.textStyle16.copyWith(
                        color: AppColors.white0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    required this.color,
  });
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 15),
    decoration: BoxDecoration(
      color: AppColors.white0,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.grey3),
    ),
    child: Column(
      children: [
        Text(
          '$value',
          style: Styles.textStyle25.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Styles.textStyle11.copyWith(color: AppColors.grey4),
        ),
      ],
    ),
  );
}
