import 'package:dio/dio.dart';

/// Exceptions thrown by the data layer. Repositories convert them to [Failure]s.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  /// Maps a [DioException] to a user-friendly [AppException].
  factory AppException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'Request timed out. Please try again.',
        );
      case DioExceptionType.badResponse:
        return ServerException(
          _messageFromResponse(e.response?.data) ??
              'Server error (${e.response?.statusCode ?? 'unknown'}). Please try again.',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const ServerException('Request was cancelled.');
      default:
        return const ServerException('Something went wrong. Please try again.');
    }
  }

  static String? _messageFromResponse(Object? data) {
    if (data is Map && data['message'] is String) {
      final message = (data['message'] as String).trim();
      return message.isEmpty ? null : message;
    }
    return null;
  }

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection. Please check your network.',
  ]);
}

final class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});

  final int? statusCode;
}
