/// Single place to configure the backend.
///
/// TODO: Replace the placeholder [baseUrl] and endpoints with the real API values.
abstract final class ApiConfig {
  static const String baseUrl = 'https://api.example.com/api/';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

abstract final class ApiEndpoints {
  static const String login = 'Login';
}
