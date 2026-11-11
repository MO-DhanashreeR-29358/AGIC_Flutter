import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/result.dart';
import '../../domain/entities/login_user.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasources/login_remote_data_source.dart';
import '../models/login_request_model.dart';

class LoginRepositoryImpl implements LoginRepository {
  const LoginRepositoryImpl(this._remoteDataSource);

  final LoginRemoteDataSource _remoteDataSource;

  @override
  Future<Result<LoginUser>> login({required String clientId}) async {
    try {
      final response = await _remoteDataSource.login(
        LoginRequestModel(clientId: clientId),
      );
      if (!response.isSuccess) {
        return ResultFailure(
          ServerFailure(
            response.message.isNotEmpty ? response.message : 'Login failed.',
          ),
        );
      }
      return ResultSuccess(response.toEntity(clientId: clientId));
    } on NetworkException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultFailure(ServerFailure(e.message));
    } catch (_) {
      return const ResultFailure(UnexpectedFailure());
    }
  }
}
