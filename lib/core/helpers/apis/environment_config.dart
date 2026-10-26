class EnvironmentConfig {
  static AppEnvironment environment = AppEnvironment.development;

  static String get baseUrl => environment.baseUrl;
}

enum AppEnvironment {
  development('https://delivery.tailorserp.com/api/mobile/v1'),
  production('https://delivery.storeus.com/api/mobile/v1');

  const AppEnvironment(this.baseUrl);
  final String baseUrl;
}
