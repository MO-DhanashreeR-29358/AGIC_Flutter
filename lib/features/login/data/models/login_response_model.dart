import '../../domain/entities/login_user.dart';

/// Response of the login API.
///
/// Placeholder shape: `{ "response": true, "message": "...", "data": {...} }`.
/// TODO: Update the fields/keys to match the real API contract.
class LoginResponseModel {
  const LoginResponseModel({
    required this.isSuccess,
    required this.message,
    this.data,
  });

  final bool isSuccess;
  final String message;
  final Map<String, dynamic>? data;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return LoginResponseModel(
      isSuccess: json['response'] == true,
      message: (json['message'] as String?)?.trim() ?? '',
      data: data is Map<String, dynamic> ? data : null,
    );
  }

  LoginUser toEntity({required String clientId}) =>
      LoginUser(clientId: clientId, message: message);
}
