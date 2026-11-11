import '../../../../core/network/result.dart';
import '../entities/login_user.dart';
import '../repositories/login_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final LoginRepository _repository;

  Future<Result<LoginUser>> call(String clientId) {
    return _repository.login(clientId: clientId.trim());
  }
}
