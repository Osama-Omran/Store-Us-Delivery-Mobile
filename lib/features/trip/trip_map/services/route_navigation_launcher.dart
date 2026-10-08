import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Launches Google Maps navigation (or a preview if location is unavailable).
class RouteNavigationLauncher {
  const RouteNavigationLauncher();

  Future<bool> navigateTo(LatLng destination) {
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination':
          '${destination.latitude},${destination.longitude}',
      'travelmode': 'driving',
      'dir_action': 'navigate',
    });
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
