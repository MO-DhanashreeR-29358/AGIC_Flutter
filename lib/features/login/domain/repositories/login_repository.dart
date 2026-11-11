import '../../../../core/network/result.dart';
import '../entities/login_user.dart';

abstract interface class LoginRepository {
  Future<Result<LoginUser>> login({required String clientId});
}
