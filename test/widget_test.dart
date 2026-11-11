import 'package:agic_flutter/features/login/presentation/validators/login_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginValidator.clientId', () {
    test('rejects empty input', () {
      expect(LoginValidator.clientId(''), isNotNull);
      expect(LoginValidator.clientId(null), isNotNull);
    });

    test('rejects wrong length', () {
      expect(LoginValidator.clientId('123'), isNotNull);
    });

    test('rejects special characters', () {
      expect(LoginValidator.clientId('12#45'), isNotNull);
    });

    test('accepts a valid 5 character ID', () {
      expect(LoginValidator.clientId('AB123'), isNull);
    });
  });
}
