class EnvironmentConfig {
  static AppEnvironment environment = AppEnvironment.development;

  static String get baseUrl => environment.baseUrl;
}

enum AppEnvironment {
  development('https://delivery.tailorserp.com/api/mobile/v1'),
  saidEndpoint('https://d236-156-216-56-67.ngrok-free.app/api/v1'),
  staging('/api/v1'),
  production('/api/v1');

  const AppEnvironment(this.baseUrl);
  final String baseUrl;
}
