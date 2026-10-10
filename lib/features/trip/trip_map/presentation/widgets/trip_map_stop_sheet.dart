import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/trip_map/data/models/trip_map_stop.dart';
import 'package:storeus_delivery/features/trip/trip_map/data/models/trip_route_result.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';

class TripMapStopSheet extends StatelessWidget {
  const TripMapStopSheet({
    super.key,
    required this.scrollController,
    required this.stop,
    required this.totalStops,
    required this.isNextStop,
    required this.locationAvailable,
    required this.isLoadingRoute,
    required this.routeError,
    required this.route,
    required this.onNavigate,
    required this.tripApiId,
  });

  final ScrollController scrollController;
  final TripMapStop stop;
  final int totalStops;
  final bool isNextStop;
  final bool locationAvailable;
  final bool isLoadingRoute;
  final bool routeError;
  final TripRouteResult? route;
  final VoidCallback onNavigate;
  final int tripApiId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black0.withValues(alpha: .08),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          Center(
            child: Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.grey3,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${isNextStop ? context.strings.trip_map_next_stop : context.strings.trip_map_selected_stop}'
            ' · ${stop.number} ${context.strings.trip_map_out_of} $totalStops',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stop.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.black1,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.grey4,
                size: 21,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  stop.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.grey4, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (route != null)
            Row(
              children: [
                _InfoChip(
                  icon: Icons.route_outlined,
                  label: route!.distanceMeters < 1000
                      ? '${route!.distanceMeters} ${context.strings.trip_map_meters}'
                      : '${(route!.distanceMeters / 1000).toStringAsFixed(1)} ${context.strings.trip_map_km}',
                ),
                const SizedBox(width: 9),
                _InfoChip(
                  icon: Icons.access_time_rounded,
                  label:
                      '${context.strings.trip_map_arrival_in} '
                      '${(route!.durationSeconds / 60).ceil()} '
                      '${context.strings.trip_map_minutes}',
                ),
              ],
            )
          else if (isLoadingRoute)
            Row(
              children: [
                SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  context.strings.trip_map_calculating_route,
                  style: TextStyle(color: AppColors.grey4),
                ),
              ],
            )
          else
            Text(
              !locationAvailable
                  ? context.strings.trip_map_location_unavailable
                  : routeError
                  ? context.strings.trip_map_route_unavailable
                  : context.strings.trip_map_route_not_connected,
              style: TextStyle(color: AppColors.grey4, fontSize: 13),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 70,
                  child: ElevatedButton.icon(
                    onPressed: onNavigate,
                    icon: const Icon(Icons.navigation_outlined, size: 24),
                    label: Text(
                      context.strings.trip_map_start_navigation,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white0,
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: .25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 70,
                  child: OutlinedButton(

                    onPressed: () {
                      final int? orderID = stop.order.apiId;

                      if (orderID == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.strings.trip_order_details_unavailable,
                            ),
                          ),
                        );
                        return;
                      }

                      GoRouter.of(context).push(
                        RoutesNames.orderDetails,
                        extra: {
                          'trip_id': tripApiId,
                          'order_id': orderID,
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.lightPrimary,
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.blue3, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      context.strings.trip_map_show_order,
                      style: Styles.textStyle16.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey5,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.black1, size: 18),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: AppColors.black1,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
