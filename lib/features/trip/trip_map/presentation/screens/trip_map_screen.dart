import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/trip_map/data/models/trip_map_stop.dart';
import 'package:storeus_delivery/features/trip/trip_map/data/models/trip_route_result.dart';
import 'package:storeus_delivery/features/trip/trip_map/data/repositories/trip_route_repository.dart';
import 'package:storeus_delivery/features/trip/trip_map/presentation/utils/trip_map_style.dart';
import 'package:storeus_delivery/features/trip/trip_map/presentation/widgets/trip_map_stop_sheet.dart';
import 'package:storeus_delivery/features/trip/trip_map/presentation/widgets/trip_map_toolbar.dart';
import 'package:storeus_delivery/features/trip/trip_map/presentation/widgets/trip_stop_marker_factory.dart';
import 'package:storeus_delivery/features/trip/trip_map/services/driver_location_service.dart';
import 'package:storeus_delivery/features/trip/trip_map/services/route_navigation_launcher.dart';

class TripMapScreen extends StatelessWidget {
  const TripMapScreen({
    super.key,
    required this.tripId,
    required this.tripApiId,
    required this.stops,
    this.routeRepository,
    this.locationService = const DriverLocationService(),
    this.navigationLauncher = const RouteNavigationLauncher(),
  });

  final String tripId;
  final int tripApiId;
  final List<TripMapStop> stops;

  final TripRouteRepository? routeRepository;
  final DriverLocationService locationService;
  final RouteNavigationLauncher navigationLauncher;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.grey0,
    body: TripMapView(
      tripId: tripId,
      tripApiId: tripApiId,
      stops: stops,
      totalStops: stops.length,
      nextStopId: ([...stops]..sort((a, b) => a.number.compareTo(b.number)))
          .where((stop) => stop.isPending)
          .firstOrNull
          ?.id,
      onBack: () => Navigator.of(context).pop(),
      routeRepository: routeRepository,
      locationService: locationService,
      navigationLauncher: navigationLauncher,
    ),
  );
}

/// Shared map content for the drawer and the standalone trip-map route.
class TripMapView extends StatefulWidget {
  const TripMapView({
    super.key,
    required this.tripId,
    required this.tripApiId,
    required this.stops,
    required this.totalStops,
    required this.nextStopId,
    required this.onBack,
    this.initialStopId,
    this.onShowOrder,
    this.onStopSelected,
    this.routeRepository,
    this.locationService = const DriverLocationService(),
    this.navigationLauncher = const RouteNavigationLauncher(),
  });

  final String tripId;
  final int tripApiId;
  final List<TripMapStop> stops;
  final int totalStops;
  final String? nextStopId;
  final String? initialStopId;
  final VoidCallback onBack;
  final ValueChanged<TripOrderModel>? onShowOrder;
  final ValueChanged<TripOrderModel>? onStopSelected;
  final TripRouteRepository? routeRepository;
  final DriverLocationService locationService;
  final RouteNavigationLauncher navigationLauncher;

  @override
  State<TripMapView> createState() => _TripMapViewState();
}

class _TripMapViewState extends State<TripMapView> {
  GoogleMapController? _mapController;
  late TripMapStop? _selectedStop;
  Set<Marker> _markers = {};
  LatLng? _driverLocation;
  TripRouteResult? _route;
  bool _isLocating = false;
  bool _isLoadingRoute = false;
  bool _routeError = false;
  int _routeVersion = 0;
  int _markerVersion = 0;

  TripMapStop? _findStop(String? id) =>
      widget.stops.where((stop) => stop.id == id).firstOrNull;

  TripMapStop? _defaultStop() =>
      _findStop(widget.initialStopId) ??
      _findStop(widget.nextStopId) ??
      widget.stops.firstOrNull;

  @override
  void didUpdateWidget(covariant TripMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final tripChanged = oldWidget.tripApiId != widget.tripApiId;
    final oldStop = _selectedStop;
    _selectedStop =
        tripChanged || oldWidget.initialStopId != widget.initialStopId
        ? _defaultStop()
        : _findStop(oldStop?.id) ?? _defaultStop();
    _buildMarkers();
    final stop = _selectedStop;
    if (tripChanged ||
        oldStop?.id != stop?.id ||
        oldStop?.location != stop?.location) {
      _routeVersion++;
      _route = null;
      _routeError = false;
      if (stop != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(stop.location, 14.2),
        );
      }
      _refreshRoute();
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedStop = _defaultStop();
    _buildMarkers();
    if (widget.stops.isNotEmpty) _refreshDriverLocation();
  }

  @override
  void dispose() {
    _routeVersion++;
    _markerVersion++;
    super.dispose();
  }

  Future<void> _buildMarkers() async {
    final version = ++_markerVersion;
    final result = <Marker>{};
    for (final stop in widget.stops) {
      final isSelected = stop.id == _selectedStop?.id;
      final icon = await TripStopMarkerFactory.create(
        stop,
        selected: isSelected,
      );
      if (!mounted || version != _markerVersion) return;
      result.add(
        Marker(
          markerId: MarkerId(stop.id),
          position: stop.location,
          icon: icon,
          anchor: const Offset(.5, .5),
          zIndexInt: isSelected ? 10 : 1,
          onTap: () => _selectStop(stop),
        ),
      );
    }
    if (mounted && version == _markerVersion) {
      setState(() => _markers = result);
    }
  }

  void _selectStop(TripMapStop stop) {
    if (stop.id == _selectedStop?.id) return;
    setState(() {
      _selectedStop = stop;
      _route = null;
      _routeError = false;
    });
    widget.onStopSelected?.call(stop.order);
    _buildMarkers();
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(stop.location, 14.2),
    );
    _refreshRoute();
  }

  Future<void> _refreshDriverLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);
    try {
      final location = await widget.locationService.getCurrentLocation();
      if (!mounted) return;
      setState(() => _driverLocation = location);
      await _refreshRoute();
    } catch (_) {
      if (!mounted) return;
      _routeVersion++;
      setState(() {
        _driverLocation = null;
        _route = null;
        _isLoadingRoute = false;
      });
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _refreshRoute() async {
    final repository = widget.routeRepository;
    final stop = _selectedStop;
    final origin = _driverLocation;
    final version = ++_routeVersion;
    if (repository == null || stop == null || origin == null) {
      if (mounted) {
        setState(() {
          _route = null;
          _isLoadingRoute = false;
          _routeError = false;
        });
      }
      return;
    }
    setState(() {
      _isLoadingRoute = true;
      _routeError = false;
      _route = null;
    });
    try {
      final route = await repository.getRoute(
        tripId: widget.tripId,
        orderId: stop.id,
        origin: origin,
      );
      if (!mounted || version != _routeVersion) return;
      setState(() => _route = route);
    } catch (_) {
      if (!mounted || version != _routeVersion) return;
      setState(() => _routeError = true);
    } finally {
      if (mounted && version == _routeVersion) {
        setState(() => _isLoadingRoute = false);
      }
    }
  }

  Future<void> _launchNavigation() async {
    final stop = _selectedStop;
    if (stop == null) return;
    try {
      final opened = await widget.navigationLauncher.navigateTo(stop.location);
      if (!opened && mounted) _showNavigationError();
    } catch (_) {
      if (mounted) _showNavigationError();
    }
  }

  void _showNavigationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.strings.trip_map_navigation_failed)),
    );
  }

  void _onMapCreated(GoogleMapController controller, double padding) {
    _mapController = controller;
    if (widget.stops.length < 2) return;
    final latitudes =
        widget.stops.map((stop) => stop.location.latitude).toList()..sort();
    final longitudes =
        widget.stops.map((stop) => stop.location.longitude).toList()..sort();
    if (latitudes.first == latitudes.last &&
        longitudes.first == longitudes.last) {
      return;
    }
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(latitudes.first, longitudes.first),
          northeast: LatLng(latitudes.last, longitudes.last),
        ),
        padding,
      ),
    );
  }

  Set<Polyline> _buildPolylines() {
    final lines = <Polyline>{};
    final ordered = [...widget.stops]
      ..sort((a, b) => a.number.compareTo(b.number));
    if (ordered.length > 1) {
      // Visual stop sequence, not a road-accurate driving route.
      lines.add(
        Polyline(
          polylineId: const PolylineId('stops_sequence'),
          points: ordered.map((stop) => stop.location).toList(),
          width: 4,
          color: AppColors.primary.withValues(alpha: .85),
          patterns: [PatternItem.dash(11), PatternItem.gap(9)],
        ),
      );
    }
    if (_route != null) {
      lines.add(
        Polyline(
          polylineId: const PolylineId('driving_route'),
          points: _route!.points,
          width: 6,
          zIndex: 3,
          color: AppColors.primary,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final stop = _selectedStop;
    if (stop == null) {
      return SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                onPressed: widget.onBack,
                tooltip: context.strings.back,
                icon: const BackButtonIcon(),
              ),
            ),
            Expanded(
              child: Center(child: Text(context.strings.trip_map_no_stops)),
            ),
          ],
        ),
      );
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: stop.location,
                zoom: 13.5,
              ),
              mapType: MapType.normal,
              padding: EdgeInsets.only(
                bottom: constraints.maxHeight * .43,
                top: (constraints.maxHeight * .15).clamp(0.0, 85.0),
              ),
              style: tripMapStyle,
              markers: _markers,
              polylines: _buildPolylines(),
              compassEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              myLocationEnabled: _driverLocation != null,
              myLocationButtonEnabled: false,
              onMapCreated: (controller) => _onMapCreated(
                controller,
                (constraints.maxHeight * .04).clamp(0.0, 40.0),
              ),
            ),
            TripMapToolbar(
              tripId: widget.tripId,
              onBack: widget.onBack,
              onRefreshLocation: _refreshDriverLocation,
              isRefreshing: _isLocating,
            ),
            DraggableScrollableSheet(
              initialChildSize: .43,
              minChildSize: .33,
              maxChildSize: .76,
              snap: true,
              snapSizes: const [.43, .76],
              builder: (context, scrollController) => TripMapStopSheet(
                scrollController: scrollController,
                stop: stop,
                totalStops: widget.totalStops,
                isNextStop: stop.id == widget.nextStopId,
                locationAvailable: _driverLocation != null,
                isLoadingRoute: _isLoadingRoute,
                routeError: _routeError,
                route: _route,
                onNavigate: _launchNavigation,
                tripApiId: widget.tripApiId,
                routeServiceAvailable: widget.routeRepository != null,
                onShowOrder: widget.onShowOrder == null
                    ? null
                    : () => widget.onShowOrder!(stop.order),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
