import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/apis/api_constants.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';

/// Expires the foreground session when the backend rejects its credentials.
class AuthErrorInterceptor extends Interceptor {
  AuthErrorInterceptor({Future<void> Function()? clearSession, this.router})
    : _clearSession = clearSession ?? PreferencesHelper.removeToken;

  final Future<void> Function() _clearSession;
  final GoRouter? router;
  Future<void>? _expiration;

  String? _rejectedToken(DioException error) {
    if (error.response?.statusCode != 401 &&
        error.response?.statusCode != 403) {
      return null;
    }

    final base = Uri.parse(ApiConstants.baseUrl);
    final target = error.requestOptions.uri;
    final prefix = base.path.replaceFirst(RegExp(r'/$'), '');
    if (!base.hasAuthority ||
        target.origin != base.origin ||
        !target.path.startsWith('$prefix/') ||
        target.path == '$prefix${ApiConstants.login}') {
      return null;
    }

    for (final header in error.requestOptions.headers.entries) {
      if (header.key.toLowerCase() == 'authorization') {
        final value = header.value?.toString().trim() ?? '';
        if (value.toLowerCase().startsWith('bearer ')) {
          final credential = value.substring(7).trim();
          if (credential.isNotEmpty) return credential;
        }
      }
    }
    return null;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    try {
      final rejectedToken = _rejectedToken(err);
      if (rejectedToken != null) {
        final pending = _expiration;
        if (pending != null) {
          await pending;
        } else {
          final persisted = await PreferencesHelper.getToken();
          final active = persisted?.trim().isNotEmpty == true
              ? persisted
              : token;
          // A late response from an old login must not expire a newer one.
          if (active == rejectedToken) {
            final expiration = _expiration ??= _expireSession();
            try {
              await expiration;
            } finally {
              if (identical(_expiration, expiration)) _expiration = null;
            }
          }
        }
      }
    } catch (_) {
      // Session handling must never replace or swallow the original API error.
      debugPrint('Unable to complete authorization error handling.');
    } finally {
      handler.next(err);
    }
  }

  Future<void> _expireSession() async {
    token = null;
    try {
      await _clearSession();
    } finally {
      PreferencesHelper.saveUserName('');
      final activeRouter = router ?? AppRouter.routes;
      if (activeRouter.routeInformationProvider.value.uri.path !=
          RoutesNames.login) {
        // Let the failed request finish before disposing its screen/Cubits.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (token?.trim().isNotEmpty == true) return;
          if (activeRouter.routeInformationProvider.value.uri.path !=
              RoutesNames.login) {
            activeRouter.goNamed(RoutesNames.login);
          }
        });
        WidgetsBinding.instance.ensureVisualUpdate();
      }
    }
  }
}
