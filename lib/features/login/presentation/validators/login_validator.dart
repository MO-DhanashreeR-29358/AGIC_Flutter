abstract final class LoginValidator {
  static const int clientIdLength = 5;
  static final RegExp _alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');

  /// Returns an error message, or `null` when the client ID is valid.
  static String? clientId(String? value) {
    final id = value?.trim() ?? '';
    if (id.isEmpty) return 'Please enter your $clientIdLength digit ID';
    if (id.length != clientIdLength) {
      return 'ID must be exactly $clientIdLength characters';
    }
    if (!_alphanumeric.hasMatch(id)) {
      return 'ID can contain only letters and numbers';
    }
    return null;
  }
}
