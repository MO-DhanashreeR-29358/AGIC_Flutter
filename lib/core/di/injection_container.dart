import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/login/data/datasources/login_remote_data_source.dart';
import '../../features/login/data/repositories/login_repository_impl.dart';
import '../../features/login/domain/repositories/login_repository.dart';
import '../../features/login/domain/usecases/login_usecase.dart';
import '../../features/login/presentation/cubit/login_cubit.dart';
import '../network/dio_client.dart';

final GetIt sl = GetIt.instance;

void initDependencies() {
  // Core
  sl.registerLazySingleton<Dio>(DioClient.create);

  // Login feature
  sl
    ..registerLazySingleton<LoginRemoteDataSource>(
      () => LoginRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<LoginRepository>(() => LoginRepositoryImpl(sl()))
    ..registerLazySingleton(() => LoginUseCase(sl()))
    ..registerFactory(() => LoginCubit(sl()));
}
