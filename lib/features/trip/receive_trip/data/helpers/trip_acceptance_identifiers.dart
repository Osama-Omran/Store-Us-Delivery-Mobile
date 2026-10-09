
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class TripAcceptanceIdentifiers {
  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  static const Uuid _uuid = Uuid();

  static const String _deviceIdKey =
      'storeus_delivery_device_id';

  static String _operationKey(int tripId) =>
      'accept_trip_operation_$tripId';

  static Future<String> getDeviceId() async {
    final existing = await _storage.read(
      key: _deviceIdKey,
    );

    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final newId = _uuid.v4();

    await _storage.write(
      key: _deviceIdKey,
      value: newId,
    );

    return newId;
  }

  static Future<String> getOperationId(
      int tripId,
      ) async {
    final key = _operationKey(tripId);

    final existing = await _storage.read(key: key);

    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final newId = _uuid.v4();

    await _storage.write(
      key: key,
      value: newId,
    );

    return newId;
  }

  static Future<void> clearOperationId(
      int tripId,
      ) async {
    await _storage.delete(
      key: _operationKey(tripId),
    );
  }
}
