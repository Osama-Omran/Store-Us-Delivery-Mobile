import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Results returned by your backend after calling Google Routes API.
class TripRouteResult {
  const TripRouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<LatLng> points;
  final int distanceMeters;
  final int durationSeconds;
}
