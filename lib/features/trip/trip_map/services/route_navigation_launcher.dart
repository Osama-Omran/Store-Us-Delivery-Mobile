import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';

class RouteLocationUnavailableException implements Exception {
  const RouteLocationUnavailableException();
}

class TripRouteSection {
  const TripRouteSection({
    required this.uri,
    required this.firstStop,
    required this.lastStop,
  });

  final Uri uri;
  final int firstStop;
  final int lastStop;
}

/// Launches Google Maps navigation (or a preview if location is unavailable).
class RouteNavigationLauncher {
  const RouteNavigationLauncher();

  Future<bool> navigateTo(LatLng destination) {
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${destination.latitude},${destination.longitude}',
      'travelmode': 'driving',
      'dir_action': 'navigate',
    });
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> openRouteSection(TripRouteSection section) =>
      launchUrl(section.uri, mode: LaunchMode.externalApplication);

  /// Three intermediate waypoints also work with the mobile browser fallback.
  /// Sections share their boundary point and never optimize or omit stops.
  static List<TripRouteSection> buildRouteSections({
    required List<TripOrderModel> orders,
    LatLng? warehouse,
  }) {
    final ordered = orders.indexed.toList()
      ..sort((a, b) {
        final order = a.$2.stopNumber.compareTo(b.$2.stopNumber);
        return order == 0 ? a.$1.compareTo(b.$1) : order;
      });
    final sections = <TripRouteSection>[];
    String? origin = warehouse == null
        ? null
        : '${warehouse.latitude},${warehouse.longitude}';
    var points = <String>[];
    var stops = <TripOrderModel>[];

    Uri routeUri(List<String> destinations) =>
        Uri.https('www.google.com', '/maps/dir/', {
          'api': '1',
          'travelmode': 'driving',
          if (origin != null) 'origin': origin!,
          'destination': destinations.last,
          if (destinations.length > 1)
            'waypoints': destinations.take(destinations.length - 1).join('|'),
        });

    void finishSection() {
      sections.add(
        TripRouteSection(
          uri: routeUri(points),
          firstStop: stops.first.stopNumber,
          lastStop: stops.last.stopNumber,
        ),
      );
      origin = points.last;
      points = [];
      stops = [];
    }

    for (final entry in ordered) {
      final stop = entry.$2;
      final point = stop.hasCoordinates
          ? '${stop.latitude},${stop.longitude}'
          : stop.address.trim();
      if (point.isEmpty) throw const RouteLocationUnavailableException();
      if (points.isNotEmpty &&
          (points.length == 4 ||
              routeUri([...points, point]).toString().length > 2048)) {
        finishSection();
      }
      if (routeUri([...points, point]).toString().length > 2048) {
        throw const RouteLocationUnavailableException();
      }
      points.add(point);
      stops.add(stop);
    }
    if (points.isNotEmpty) finishSection();
    return List.unmodifiable(sections);
  }
}
