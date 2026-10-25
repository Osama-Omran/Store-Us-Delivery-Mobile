import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storeus_delivery/core/helpers/offline_sync/offline_sync_worker.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' show token;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String? previousToken;

  setUp(() {
    previousToken = token;
    token = 'memory-token';
  });

  tearDown(() {
    token = previousToken;
    FlutterSecureStorage.setMockInitialValues({});
  });

  test(
    'skips replay without a persisted session despite a global token',
    () async {
      FlutterSecureStorage.setMockInitialValues({});

      // No preferences, SQLite, notification or network plugins are configured.
      expect(await OfflineSyncWorker.drain(), isTrue);
    },
  );

  test(
    'does not revive a stored session without its persisted token',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'StoreUs Offline Session ID': 'previous-session',
      });

      expect(await OfflineSyncWorker.drain(), isTrue);
    },
  );
}
