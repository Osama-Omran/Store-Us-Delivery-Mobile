import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:storeus_delivery/core/helpers/offline_sync/offline_sync_notifications.dart';
import 'package:storeus_delivery/core/helpers/offline_sync/offline_sync_store.dart';
import 'package:storeus_delivery/core/helpers/offline_sync/offline_sync_worker.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';

/// Add this flag to a Dio request (Options.extra) to make it replayable.
/// DO NOT enable non-idempotent business operations until the server
/// deduplicates on Idempotency-Key (and/or client_operation_id).
class OfflineSyncOptions {
  static const enabled = 'storeus_offline_sync_enabled';
  static const title = 'storeus_offline_sync_title';
  static const internalId = 'storeus_offline_sync_internal_id';
}

class OfflineQueuedException implements Exception {
  const OfflineQueuedException(this.operationId);
  final String operationId;

  @override
  String toString() => 'offline_operation_queued';
}

class OfflineSyncInterceptor extends Interceptor {
  static const _allowedMethods = {'POST', 'PUT', 'PATCH', 'DELETE'};

  String _newId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    // UUID-like random stable ID for this logical operation.
    final encoded = bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${encoded.substring(0, 8)}-${encoded.substring(8, 12)}-'
        '${encoded.substring(12, 16)}-${encoded.substring(16, 20)}-'
        '${encoded.substring(20)}';
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[OfflineSyncOptions.enabled] != true) {
      return handler.next(options);
    }

    try {
      if (!_allowedMethods.contains(options.method.toUpperCase()) ||
          !options.path.startsWith('/') ||
          options.path.contains('..') ||
          options.path.startsWith('//') ||
          options.path.contains('?') ||
          options.path == '/login' ||
          options.path == '/logout') {
        throw UnsupportedError('Unsupported offline HTTP operation');
      }
      // Multipart/file bodies need a separate durable file-copy strategy.
      // NEVER store FormData's temp file paths as replayable uploads.
      final body = options.data;
      if (body != null &&
          body is! Map &&
          body is! List &&
          body is! String &&
          body is! num &&
          body is! bool) {
        throw UnsupportedError('Only JSON-serializable bodies are supported');
      }
      if (body is String) {
        // Ensure plain strings are JSON, not raw bytes or an opaque stream.
        jsonDecode(body);
      } else if (body != null) {
        jsonEncode(body);
      }

      final sessionId = await PreferencesHelper.getOfflineSessionId();
      final auth = options.headers['Authorization']?.toString();
      if (sessionId == null || auth == null || !auth.startsWith('Bearer ')) {
        throw StateError('An authenticated session is required');
      }

      final id = _newId();
      final title =
          options.extra[OfflineSyncOptions.title]?.toString() ??
          'offline_operation_title';
      final store = OfflineSyncStore.instance;
      await store.stage(
        id: id,
        sessionId: sessionId,
        method: options.method.toUpperCase(),
        endpoint: options.path,
        query: options.queryParameters,
        jsonBody: body,
        language: options.headers['Accept-Language']?.toString(),
        title: title,
      );
      options.headers['Idempotency-Key'] = id;
      options.extra[OfflineSyncOptions.internalId] = id;
      // Schedule BEFORE the HTTP attempt, so process termination cannot leave
      // an outbox record without any scheduled recovery work.
      await OfflineSyncScheduler.schedule();
      handler.next(options);
    } catch (e) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: e,
          message: 'offline_operation_save_failed',
        ),
      );
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final id =
        response.requestOptions.extra[OfflineSyncOptions.internalId] as String?;
    if (id != null) {
      try {
        final isFailure =
            response.data is Map && (response.data as Map)['success'] == false;
        if (isFailure) {
          await OfflineSyncStore.instance.failed(
            id,
            'Backend returned success=false',
          );
        } else {
          await OfflineSyncStore.instance.completed(id);
        }
      } catch (_) {
        // A stale stage may retry after process death. Server-side
        // Idempotency-Key support is mandatory for correctness.
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final id =
        err.requestOptions.extra[OfflineSyncOptions.internalId] as String?;
    if (id == null) return handler.next(err);

    final code = err.response?.statusCode;
    final recoverable =
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        code == 429 ||
        (code != null && code >= 500);

    try {
      if (recoverable) {
        await OfflineSyncStore.instance.releaseForRetry(
          id,
          '${err.type}: ${err.message}',
        );
        // The previous one-off could have run while the original request
        // still owned the lease. Arm recovery again after releasing it.
        try {
          await OfflineSyncScheduler.schedule();
        } catch (_) {}
        try {
          await OfflineSyncNotifications.instance.waiting();
        } catch (_) {}
        // Retry is already scheduled in onRequest. Keep existing Cubit
        // error behavior unless caller explicitly handles queued state.
        return handler.next(
          err.copyWith(
            error: OfflineQueuedException(id),
            message: 'offline_operation_queued',
          ),
        );
      }
      await OfflineSyncStore.instance.failed(
        id,
        'HTTP ${code ?? 'unexpected error'}',
      );
    } catch (_) {
      // Preserve original HTTP error if local DB/notification fails.
    }
    handler.next(err);
  }
}
