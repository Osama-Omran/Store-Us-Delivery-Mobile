import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/widgets/custom_loading_indicator.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/models/areas_route_data.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/widgets/areas_route_overview.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/widgets/areas_stop_card.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/trip_map/presentation/screens/trip_map_screen.dart';
import 'package:storeus_delivery/features/trip/trip_map/services/route_navigation_launcher.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';

class AreasScreen extends StatefulWidget {
  const AreasScreen({
    super.key,
    required this.onBack,
    this.navigationLauncher = const RouteNavigationLauncher(),
  });

  final VoidCallback onBack;
  final RouteNavigationLauncher navigationLauncher;

  @override
  State<AreasScreen> createState() => _AreasScreenState();
}

class _AreasScreenState extends State<AreasScreen> {
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
    if (!mounted) return;
    await _refresh();
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
          builder: (sheetContext) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.strings.areas_route_sections,
                    style: Styles.textStyle19.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.strings.areas_route_sections_description,
                    style: Styles.textStyle13.copyWith(color: AppColors.grey4),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(sheetContext).height * .5,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sections.length,
                      itemBuilder: (_, index) => ListTile(
                        leading: const Icon(
                          Icons.route_outlined,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          context.strings.areas_route_section(
                            index + 1,
                            sections.length,
                          ),
                        ),
                        subtitle: Text(
                          context.strings.areas_route_section_stops(
                            sections[index].firstStop,
                            sections[index].lastStop,
                          ),
                        ),
                        onTap: () =>
                            Navigator.of(sheetContext).pop(sections[index]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: ColoredBox(
      color: AppColors.grey0,
      child: Padding(
        // Layout owns the persistent navigation bar.
        padding: const EdgeInsets.only(bottom: 100),
        child: BlocBuilder<TripTabCubit, TripTabState>(
          builder: (context, state) {
            final loading =
                state is TripTabInitial ||
                state is TripTabLoadingState ||
                (state is TripTabSuccessState &&
                    state.trip.acceptance?.isOperationallyAccepted == true &&
                    (state.ordersStatus == TripOrdersStatus.initial ||
                        state.ordersStatus == TripOrdersStatus.loading));
            AreasRouteData? route;
            if (state is TripTabSuccessState &&
                state.trip.acceptance?.isOperationallyAccepted == true &&
                state.ordersStatus == TripOrdersStatus.success) {
              route = AreasRouteData(trip: state.trip, orders: state.orders);
              if (_displayedTripId != route.trip.id) {
                _displayedTripId = route.trip.id;
                _selectedStopId = null;
              }
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
                onShowOrder: (order) => _showOrder(route!.trip.id, order),
                navigationLauncher: widget.navigationLauncher,
              );
            }
            return Column(
              children: [
                _header(loading),
                Expanded(
                  child: loading
                      ? const Center(
                          child: CustomLoadingIndicator(primaryColor: true),
                        )
                      : route != null
                      ? _routeList(route)
                      : _stateMessage(state),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );

  Widget _header(bool loading) => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                tooltip: context.strings.back,
                icon: const BackButtonIcon(),
              ),
              Expanded(
                child: Text(
                  context.strings.areas_title,
                  textAlign: TextAlign.center,
                  style: Styles.textStyle21.copyWith(
                    color: AppColors.black1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: loading ? null : _refresh,
                tooltip: context.strings.areas_refresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          Text(
            context.strings.areas_distribution_order,
            textAlign: TextAlign.center,
            style: Styles.textStyle12.copyWith(color: AppColors.grey4),
          ),
        ],
      ),
    ),
  );

  Widget _routeList(AreasRouteData route) {
    if (route.orders.isEmpty) {
      return _message(context.strings.areas_no_stops, retry: true);
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: route.total + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return AreasRouteOverview(
              route: route,
              onMap: () => setState(() {
                _selectedStopId = null;
                _showMap = true;
              }),
            );
          }
          if (index == route.total + 1) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (route.warehouseLocation == null) ...[
                    Text(
                      context.strings.areas_route_origin_unavailable,
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.grey4,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  OutlinedButton.icon(
                    onPressed: _openingRoute ? null : () => _openRoute(route),
                    icon: const Icon(Icons.map_outlined),
                    label: Text(context.strings.areas_open_google_maps),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      backgroundColor: AppColors.blue2,
                      minimumSize: const Size.fromHeight(56),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          final order = route.orders[index - 1];
          return AreasStopCard(
            order: order,
            isNext: identical(order, route.nextStop),
            isFirst: index == 1,
            isLast: index == route.total,
            onSelect: () => _selectStop(order),
            onShowOrder: () => _showOrder(route.trip.id, order),
          );
        },
      ),
    );
  }

  Widget _stateMessage(TripTabState state) {
    if (state is TripTabEmptyState) {
      return _message(context.strings.trip_tab_no_trip, retry: true);
    }
    if (state is TripTabFailureState) {
      return _message(
        context.localizedErrorMessage(
          state.errorMessage,
          fallback: context.strings.areas_load_failed,
        ),
        retry: true,
      );
    }
    if (state is TripTabSuccessState) {
      if (state.trip.acceptance?.isOperationallyAccepted != true) {
        return _message(
          context.strings.you_must_confirm_receiving_van_and_goods_first,
          retry: true,
        );
      }
      return _message(
        context.localizedErrorMessage(
          state.ordersError,
          fallback: context.strings.areas_load_failed,
        ),
        retry: true,
      );
    }
    return _message(context.strings.areas_load_failed, retry: true);
  }

  Widget _message(String message, {required bool retry}) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.route_outlined, size: 48, color: AppColors.grey4),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Styles.textStyle15.copyWith(color: AppColors.black1),
          ),
          if (retry) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _refresh,
              child: Text(context.strings.current_trip_retry),
            ),
          ],
        ],
      ),
    ),
  );
}
