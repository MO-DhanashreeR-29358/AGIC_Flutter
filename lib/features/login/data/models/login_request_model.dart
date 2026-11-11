/// Request body for the login API.
///
/// TODO: Update the JSON keys to match the real API contract.
class LoginRequestModel {
  const LoginRequestModel({required this.clientId});

  final String clientId;

  Map<String, dynamic> toJson() => {'ClientId': clientId};
}
