import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

class OfflineCacheViewState {
  const OfflineCacheViewState({
    this.noNetwork = false,
    this.showingSavedData = false,
    this.savedAt,
  });

  final bool noNetwork;
  final bool showingSavedData;
  final DateTime? savedAt;
}

/// Shared visual state, not an authority on whether a server is reachable.
class OfflineCacheStatus extends ValueNotifier<OfflineCacheViewState> {
  OfflineCacheStatus._() : super(const OfflineCacheViewState());
  static final OfflineCacheStatus instance = OfflineCacheStatus._();

  final Map<String, DateTime> _cachedKeys = {};
  bool _noNetwork = false;

  void _publish() {
    final times = _cachedKeys.values.toList()..sort();
    value = OfflineCacheViewState(
      noNetwork: _noNetwork,
      showingSavedData: times.isNotEmpty,
      savedAt: times.isEmpty ? null : times.first,
    );
  }

  void network(bool isOffline) {
    if (_noNetwork == isOffline) return;
    _noNetwork = isOffline;
    _publish();
  }

  void cached(String key, DateTime savedAt) {
    _cachedKeys[key] = savedAt;
    _publish();
  }

  void live(String key) {
    if (_cachedKeys.remove(key) != null) _publish();
  }

  void clear() {
    _cachedKeys.clear();
    _publish();
  }
}

/// A lack of network interface is definite offline; presence of Wi-Fi/data
/// DOES NOT prove internet access. Dio's onError handles captive portals.
class OfflineCacheConnectivity with WidgetsBindingObserver {
  OfflineCacheConnectivity._();
  static final OfflineCacheConnectivity instance = OfflineCacheConnectivity._();

  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _started = false;
  bool? _lastNoNetwork;

  /// A signal for screens to refetch their existing GET usecases after
  /// reconnect. Trigger this listener in the relevant screen/Cubit.
  final ValueNotifier<int> reconnectVersion = ValueNotifier<int>(0);

  static bool _offline(List<ConnectivityResult> statuses) =>
      statuses.isEmpty ||
      statuses.every((status) => status == ConnectivityResult.none);

  Future<bool> noNetworkAvailable() async {
    try {
      final result = _offline(await _connectivity.checkConnectivity());
      _update(result);
      return result;
    } catch (_) {
      // Do not turn a connectivity plugin issue into a failed HTTP request.
      return false;
    }
  }

  Future<void> start() async {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    await noNetworkAvailable();
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) => _update(_offline(results)),
      onError: (_) {},
    );
  }

  void _update(bool noNetwork) {
    final reconnected = _lastNoNetwork == true && !noNetwork;
    _lastNoNetwork = noNetwork;
    OfflineCacheStatus.instance.network(noNetwork);
    if (reconnected) reconnectVersion.value++;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(noNetworkAvailable());
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    WidgetsBinding.instance.removeObserver(this);
    _started = false;
  }
}
