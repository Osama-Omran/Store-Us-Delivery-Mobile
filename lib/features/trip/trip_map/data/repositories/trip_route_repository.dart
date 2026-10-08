import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:storeus_delivery/features/trip/trip_map/data/models/trip_route_result.dart';
import 'package:storeus_delivery/features/trip/trip_map/presentation/utils/polyline_decoder.dart';

abstract class TripRouteRepository {
  Future<TripRouteResult> getRoute({
    required String tripId,
    required String orderId,
    required LatLng origin,
  });
}

/// Calls YOUR authenticated backend, never Routes API directly from Flutter.
/// The backend should derive the destination from [orderId] and verify that
/// the signed-in driver is assigned to [tripId].
class HttpTripRouteRepository implements TripRouteRepository {
  const HttpTripRouteRepository({
    required this.baseUrl,
    this.headers = const {},
    this.timeout = const Duration(seconds: 15),
  });

  final String baseUrl;
  final Map<String, String> headers;
  final Duration timeout;

  @override
  Future<TripRouteResult> getRoute({
    required String tripId,
    required String orderId,
    required LatLng origin,
  }) async {
    final path =
        '${baseUrl.replaceAll(RegExp(r"/$"), "")}/api/mobile/trips/${Uri.encodeComponent(tripId)}/route';
    final uri = Uri.parse(path).replace(queryParameters: {
      'order_id': orderId,
      'origin_lat': origin.latitude.toString(),
      'origin_lng': origin.longitude.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        ...headers,
      },
    ).timeout(timeout);

    if (response.statusCode != 200) {
      throw StateError('Route API returned HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Route API must return a JSON object');
    }

    final encoded = data['encoded_polyline'];
    final distance = data['distance_meters'];
    final duration = data['duration_seconds'];
    if (encoded is! String ||
        distance is! num ||
        duration is! num ||
        distance < 0 ||
        duration < 0) {
      throw const FormatException('Missing route values');
    }

    final points = TripPolylineDecoder.decode(encoded);
    if (points.length < 2) {
      throw const FormatException('Route must contain multiple points');
    }
    return TripRouteResult(
      points: points,
      distanceMeters: distance.round(),
      durationSeconds: duration.round(),
    );
  }
}
