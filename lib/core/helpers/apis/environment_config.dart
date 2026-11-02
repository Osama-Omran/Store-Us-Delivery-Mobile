class EnvironmentConfig {
  static AppEnvironment environment = AppEnvironment.development;
  static String? _remoteConfigBaseUrl;

  static String get baseUrl => _remoteConfigBaseUrl ?? environment.baseUrl;

  static void setRemoteConfigBaseUrl(String? baseUrl) {
    final value = baseUrl?.trim();
    final uri = value == null ? null : Uri.tryParse(value);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        !uri.hasAuthority ||
        uri.host.isEmpty) {
      _remoteConfigBaseUrl = null;
      return;
    }

    _remoteConfigBaseUrl = value;
  }
}

enum AppEnvironment {
  development('https://delivery.tailorserp.com/api/mobile/v1'),
  production('https://delivery.storeus.com/api/mobile/v1');

  const AppEnvironment(this.baseUrl);
  final String baseUrl;
}
