import 'package:dio/dio.dart';
import 'package:storeus_delivery/core/helpers/apis/api_constants.dart';
import 'package:storeus_delivery/core/helpers/offline_cache/offline_cache_connectivity.dart';
import 'package:storeus_delivery/core/helpers/offline_cache/offline_cache_store.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';

class OfflineCacheOptions {
  static const bypass = 'storeus_read_cache_bypass';
  static const fromCache = 'storeus_read_cache_hit';
  static const cachedAt = 'storeus_read_cache_at';
  static const _id = 'storeus_read_cache_identity';
  static const _session = 'storeus_read_cache_session';
}

/// Preserves Retrofit's response JSON shape while allowing offline fallback.
/// Only intentionally selected authenticated GET endpoints are eligible.
class OfflineCacheInterceptor extends Interceptor {
  static final _tripDetails = RegExp(r'^/trips/[^/]+/(loaded-items|orders)(/[^/]+)?$');
  static final _warehouseDetails = RegExp(r'^/warehouse-transfers(/[^/]+)?$');

  bool _allowedEndpoint(String endpoint) =>
      endpoint == '/me' ||
      endpoint == '/notifications' ||
      endpoint == '/trips/current' ||
      endpoint == '/trips/history' ||
      endpoint == '/top-rank' ||
      endpoint == '/reports/overview' ||
      endpoint == '/support/contact' ||
      _tripDetails.hasMatch(endpoint) ||
      _warehouseDetails.hasMatch(endpoint);

  String? _header(RequestOptions options, String name) {
    for (final entry in options.headers.entries) {
      if (entry.key.toLowerCase() == name.toLowerCase()) {
        return entry.value?.toString();
      }
    }
    return null;
  }

  bool _eligible(RequestOptions options) {
    if (options.method.toUpperCase() != 'GET' ||
        options.extra[OfflineCacheOptions.bypass] == true) {
      return false;
    }
    final token = _header(options, 'Authorization');
    if (token == null || !token.startsWith('Bearer ')) return false;
    final baseUri = Uri.parse(ApiConstants.baseUrl);
    final target = options.uri;
    if (baseUri.hasAuthority &&
        (target.host != baseUri.host || target.scheme != baseUri.scheme)) {
      return false;
    }
    final prefix = baseUri.path.replaceFirst(RegExp(r'/$'), '');
    if (!target.path.startsWith('$prefix/')) return false;
    final endpoint = target.path.substring(prefix.length);
    return _allowedEndpoint(endpoint);
  }

  Future<void> _prepare(RequestOptions options) async {
    final session = await PreferencesHelper.getOfflineSessionId();
    if (session == null) return;
    // URI includes query parameters; language and session scope ensure that
    // reports/filters/other accounts don't collide. No token is serialized.
    final locale = _header(options, 'Accept-Language') ?? 'ar';
    final uri = options.uri;
    final query = uri.queryParametersAll.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final canonicalQuery = query
        .map((entry) => '${Uri.encodeComponent(entry.key)}='
            '${(entry.value.toList()..sort()).map(Uri.encodeComponent).join(',')}')
        .join('&');
    final identity = await OfflineCacheStore.instance.fingerprint(
      '$session|GET|${uri.scheme}://${uri.authority}${uri.path}?$canonicalQuery|$locale',
    );
    options.extra[OfflineCacheOptions._id] = identity;
    options.extra[OfflineCacheOptions._session] = session;
  }

  Future<Response<dynamic>?> _savedResponse(RequestOptions options) async {
    final key = options.extra[OfflineCacheOptions._id] as String?;
    final session = options.extra[OfflineCacheOptions._session] as String?;
    if (key == null || session == null) return null;
    final saved = await OfflineCacheStore.instance.read(
      sessionId: session,
      cacheKey: key,
    );
    if (saved == null) return null;
    OfflineCacheStatus.instance.cached(key, saved.savedAt);
    return Response<dynamic>(
      requestOptions: options,
      statusCode: saved.statusCode,
      data: saved.body,
      headers: Headers.fromMap({Headers.contentTypeHeader: ['application/json']}),
      extra: {
        OfflineCacheOptions.fromCache: true,
        OfflineCacheOptions.cachedAt: saved.savedAt.toIso8601String(),
      },
    );
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_eligible(options)) return handler.next(options);
    try {
      await _prepare(options);
      if (await OfflineCacheConnectivity.instance.noNetworkAvailable()) {
        final cached = await _savedResponse(options);
        if (cached != null) return handler.resolve(cached);
      }
    } catch (_) {
      // Cache failure must never prevent a real HTTP request.
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.extra[OfflineCacheOptions.fromCache] == true) {
      return handler.next(response);
    }
    final options = response.requestOptions;
    final key = options.extra[OfflineCacheOptions._id] as String?;
    final session = options.extra[OfflineCacheOptions._session] as String?;
    final code = response.statusCode ?? 0;
    if (key != null && session != null && code >= 200 && code < 300 &&
        (response.data is Map || response.data is List) &&
        !(response.data is Map && (response.data as Map)['success'] == false)) {
      try {
        await OfflineCacheStore.instance.save(
          sessionId: session,
          cacheKey: key,
          body: response.data,
          statusCode: code,
        );
      } catch (_) {
        // Do not change normal online success if storage is unavailable.
      }
      OfflineCacheStatus.instance.live(key);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final code = err.response?.statusCode;
    final isNetworkFailure = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        code == 502 || code == 503 || code == 504;
    if (isNetworkFailure &&
        err.requestOptions.extra[OfflineCacheOptions._id] != null) {
      try {
        final cached = await _savedResponse(err.requestOptions);
        if (cached != null) return handler.resolve(cached);
      } catch (_) {
        // Preserve original error if encrypted cache cannot be read.
      }
    }
    handler.next(err);
  }
}
