import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Google encoded polyline (5-digit precision) decoder.
class TripPolylineDecoder {
  const TripPolylineDecoder._();

  static List<LatLng> decode(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    var latitude = 0;
    var longitude = 0;

    int decodeChunk() {
      var result = 0;
      var shift = 0;
      int part;
      do {
        if (index >= encoded.length) {
          throw const FormatException('Incomplete encoded polyline');
        }
        part = encoded.codeUnitAt(index++) - 63;
        if (part < 0 || part > 0x5f) {
          throw const FormatException('Invalid encoded polyline');
        }
        result |= (part & 0x1f) << shift;
        shift += 5;
        if (shift > 35) {
          throw const FormatException('Encoded polyline overflow');
        }
      } while (part >= 0x20);
      return (result & 1) != 0 ? ~(result >> 1) : result >> 1;
    }

    while (index < encoded.length) {
      latitude += decodeChunk();
      longitude += decodeChunk();
      points.add(LatLng(latitude / 1e5, longitude / 1e5));
    }
    return points;
  }
}
