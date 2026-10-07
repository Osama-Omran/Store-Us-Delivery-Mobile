class EnvironmentConfig {
  static AppEnvironment environment = AppEnvironment.staging;

  static String get baseUrl => environment.baseUrl;
}

enum AppEnvironment {
  development('/api/v1'), // Staging till now
  saidEndpoint('https://d236-156-216-56-67.ngrok-free.app/api/v1'),
  staging('/api/v1'), // Production till now
  production('/api/v1'); // Development till now

  const AppEnvironment(this.baseUrl);
  final String baseUrl;
}
