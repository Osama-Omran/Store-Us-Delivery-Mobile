import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

class TripMapScreen extends StatefulWidget {
  const TripMapScreen({
    super.key,
    required this.tripId,
    required this.stops,
    required this.onShowOrder,
    this.routeRepository,
    this.locationService = const DriverLocationService(),
    this.navigationLauncher = const RouteNavigationLauncher(),
  });

  final String tripId;
  final List<TripMapStop> stops;
  final ValueChanged<TripMapStop> onShowOrder;

  /// Null allows map markers and navigation, but hides route/ETA metrics.
  final TripRouteRepository? routeRepository;
  final DriverLocationService locationService;
  final RouteNavigationLauncher navigationLauncher;

  @override
  State<TripMapScreen> createState() => _TripMapScreenState();
}

class _TripMapScreenState extends State<TripMapScreen> {
  GoogleMapController? _mapController;
  late TripMapStop? _selectedStop;
  TripMapStop? _nextStop;
  Set<Marker> _markers = {};
  LatLng? _driverLocation;
  TripRouteResult? _route;
  bool _isLocating = false;
  bool _isLoadingRoute = false;
  bool _routeError = false;
  int _routeVersion = 0;
  int _markerVersion = 0;

  Future<Position?> getCurrentLocation() async {
    final serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return null;
    }

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
      }
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    final ordered = [...widget.stops]
      ..sort((a, b) => a.number.compareTo(b.number));
    for (final stop in ordered) {
      if (stop.status == TripOrderStatus.pending) {
        _nextStop = stop;
        break;
      }
    }
    _selectedStop = _nextStop ?? (ordered.isEmpty ? null : ordered.last);
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
      result.add(Marker(
        markerId: MarkerId(stop.id),
        position: stop.location,
        icon: icon,
        anchor: const Offset(.5, .5),
        zIndexInt: isSelected ? 10 : 1,
        onTap: () => _selectStop(stop),
      ));
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

  Set<Polyline> _buildPolylines() {
    final lines = <Polyline>{};
    final ordered = [...widget.stops]..sort((a, b) => a.number.compareTo(b.number));
    if (ordered.length > 1) {
      // Visual stop sequence, not a road-accurate driving route.
      lines.add(Polyline(
        polylineId: const PolylineId('stops_sequence'),
        points: ordered.map((stop) => stop.location).toList(),
        width: 4,
        color: AppColors.primary.withValues(alpha: .85),
        patterns: [PatternItem.dash(11), PatternItem.gap(9)],
      ));
    }
    if (_route != null) {
      lines.add(Polyline(
        polylineId: const PolylineId('driving_route'),
        points: _route!.points,
        width: 6,
        zIndex: 3,
        color: AppColors.primary,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ));
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final stop = _selectedStop;
    if (stop == null) {
      return Scaffold(
        backgroundColor: AppColors.grey0,
        appBar: AppBar(title: Text(context.strings.trip_map_title)),
        body: Center(child: Text(context.strings.trip_map_no_stops)),
      );
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.grey0,
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: stop.location, zoom: 13.5),
              mapType: MapType.normal,
              style: tripMapStyle,
              markers: _markers,
              polylines: _buildPolylines(),
              compassEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              myLocationEnabled: _driverLocation != null,
              myLocationButtonEnabled: false,
              onMapCreated: (controller) => _mapController = controller,
            ),
            TripMapToolbar(
              tripId: widget.tripId,
              onBack: () => Navigator.of(context).pop(),
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
                totalStops: widget.stops.length,
                isNextStop: stop.id == _nextStop?.id,
                locationAvailable: _driverLocation != null,
                isLoadingRoute: _isLoadingRoute,
                routeError: _routeError,
                route: _route,
                onNavigate: _launchNavigation,
                onShowOrder: () => widget.onShowOrder(stop),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
