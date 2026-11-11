import 'package:equatable/equatable.dart';

/// Logged-in user as seen by the app (independent of the API format).
class LoginUser extends Equatable {
  const LoginUser({required this.clientId, this.message = ''});

  final String clientId;
  final String message;

  @override
  List<Object?> get props => [clientId, message];
}
