import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/models/areas_route_data.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/widgets/areas_open_route_button.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/widgets/areas_route_overview.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/widgets/areas_state_message.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/widgets/areas_stop_card.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';

class AreasRouteList extends StatelessWidget {
  const AreasRouteList({
    super.key,
    required this.route,
    required this.onMap,
    required this.onSelect,
    required this.onShowOrder,
    required this.onOpenRoute,
    required this.isOpeningRoute,
  });

  final AreasRouteData route;
  final VoidCallback onMap;
  final ValueChanged<TripOrderModel> onSelect;
  final ValueChanged<TripOrderModel> onShowOrder;
  final VoidCallback onOpenRoute;
  final bool isOpeningRoute;

  @override
  Widget build(BuildContext context) {
    if (route.orders.isEmpty) {
      return AreasStateMessage(message: context.strings.areas_no_stops);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TripTabCubit>().getCurrentTrip(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: route.total + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return AreasRouteOverview(route: route, onMap: onMap);
          }
          if (index == route.total + 1) {
            return AreasOpenRouteButton(
              route: route,
              isOpening: isOpeningRoute,
              onPressed: onOpenRoute,
            );
          }

          final order = route.orders[index - 1];
          return AreasStopCard(
            order: order,
            isNext: identical(order, route.nextStop),
            isFirst: index == 1,
            isLast: index == route.total,
            onSelect: () => onSelect(order),
            onShowOrder: () => onShowOrder(order),
          );
        },
      ),
    );
  }
}
