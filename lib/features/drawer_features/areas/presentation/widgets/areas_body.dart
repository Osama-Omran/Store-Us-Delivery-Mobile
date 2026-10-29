import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/widgets/areas_route_sections_sheet.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/models/areas_route_data.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/widgets/areas_header.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/widgets/areas_route_list.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/widgets/areas_shimmer.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/widgets/areas_state_message.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/trip_map/presentation/screens/trip_map_screen.dart';
import 'package:storeus_delivery/features/trip/trip_map/services/route_navigation_launcher.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';

class AreasBody extends StatefulWidget {
  const AreasBody({
    super.key,
    required this.onBack,
    required this.navigationLauncher,
  });

  final VoidCallback onBack;
  final RouteNavigationLauncher navigationLauncher;

  @override
  State<AreasBody> createState() => _AreasBodyState();
}

class _AreasBodyState extends State<AreasBody> {
  bool _showMap = false;
  bool _openingRoute = false;
  String? _selectedStopId;
  int? _displayedTripId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh();
    });
  }

  Future<void> _refresh() => context.read<TripTabCubit>().getCurrentTrip();

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _selectStop(TripOrderModel order) {
    if (!order.hasCoordinates) {
      _showMessage(context.strings.areas_stop_location_unavailable);
      return;
    }
    setState(() {
      _selectedStopId = order.apiId?.toString() ?? order.id;
      _showMap = true;
    });
  }

  Future<void> _showOrder(int tripId, TripOrderModel order) async {
    if (order.apiId == null) {
      _showMessage(context.strings.trip_order_details_unavailable);
      return;
    }
    await context.push(
      RoutesNames.orderDetails,
      extra: {'trip_id': tripId, 'order_id': order.apiId!},
    );
    if (mounted) await _refresh();
  }

  Future<void> _openRoute(AreasRouteData route) async {
    if (_openingRoute) return;
    setState(() => _openingRoute = true);
    try {
      final sections = RouteNavigationLauncher.buildRouteSections(
        orders: route.orders,
        warehouse: route.warehouseLocation,
      );
      if (sections.isEmpty) return;

      TripRouteSection? section = sections.first;
      if (sections.length > 1) {
        section = await showModalBottomSheet<TripRouteSection>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => AreasRouteSectionsSheet(sections: sections),
        );
      }

      if (!mounted || section == null) return;
      final currentState = context.read<TripTabCubit>().state;
      if (currentState is! TripTabSuccessState ||
          currentState.trip.id != route.trip.id) {
        return;
      }

      final opened = await widget.navigationLauncher.openRouteSection(section);
      if (!opened && mounted) {
        _showMessage(context.strings.trip_map_navigation_failed);
      }
    } on RouteLocationUnavailableException {
      if (mounted) {
        _showMessage(context.strings.areas_route_location_unavailable);
      }
    } catch (_) {
      if (mounted) _showMessage(context.strings.trip_map_navigation_failed);
    } finally {
      if (mounted) setState(() => _openingRoute = false);
    }
  }

  AreasRouteData? _route(TripTabState state) {
    if (state is! TripTabSuccessState ||
        state.trip.acceptance?.isOperationallyAccepted != true ||
        state.ordersStatus != TripOrdersStatus.success) {
      return null;
    }
    return AreasRouteData(trip: state.trip, orders: state.orders);
  }

  bool _loading(TripTabState state) =>
      state is TripTabInitial ||
      state is TripTabLoadingState ||
      (state is TripTabSuccessState &&
          state.trip.acceptance?.isOperationallyAccepted == true &&
          (state.ordersStatus == TripOrdersStatus.initial ||
              state.ordersStatus == TripOrdersStatus.loading));

  @override
  Widget build(BuildContext context) {
    final header = AreasHeader(onBack: widget.onBack);
    return BlocBuilder<TripTabCubit, TripTabState>(
      builder: (context, state) {
        final route = _route(state);
        if (route != null && _displayedTripId != route.trip.id) {
          _displayedTripId = route.trip.id;
          _selectedStopId = null;
        }

        if (_showMap && route != null && route.orders.isNotEmpty) {
          return TripMapView(
            key: ValueKey(route.trip.id),
            tripId: route.trip.number,
            tripApiId: route.trip.id,
            stops: route.mapStops,
            totalStops: route.total,
            nextStopId: route.nextStop == null
                ? null
                : (route.nextStop!.apiId?.toString() ?? route.nextStop!.id),
            initialStopId: _selectedStopId,
            onStopSelected: (order) =>
                _selectedStopId = order.apiId?.toString() ?? order.id,
            onBack: () => setState(() => _showMap = false),
            onShowOrder: (order) => _showOrder(route.trip.id, order),
            navigationLauncher: widget.navigationLauncher,
          );
        }

        return Column(
          children: [
            header,
            Expanded(
              child: _loading(state)
                  ? const AreasShimmer()
                  : route == null
                  ? const AreasStateMessage()
                  : AreasRouteList(
                      route: route,
                      onMap: () => setState(() {
                        _selectedStopId = null;
                        _showMap = true;
                      }),
                      onSelect: _selectStop,
                      onShowOrder: (order) => _showOrder(route.trip.id, order),
                      onOpenRoute: () => _openRoute(route),
                      isOpeningRoute: _openingRoute,
                    ),
            ),
          ],
        );
      },
    );
  }
}
