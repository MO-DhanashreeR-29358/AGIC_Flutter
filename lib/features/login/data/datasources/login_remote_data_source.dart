import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_config.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

abstract interface class LoginRemoteDataSource {
  /// Calls the login API. Throws an [AppException] on failure.
  Future<LoginResponseModel> login(LoginRequestModel request);
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  const LoginRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.login,
        data: request.toJson(),
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const ServerException('Invalid response from server.');
      }
      return LoginResponseModel.fromJson(body);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }
}
