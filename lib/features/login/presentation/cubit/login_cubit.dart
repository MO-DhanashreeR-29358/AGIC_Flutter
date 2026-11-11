import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/result.dart';
import '../../domain/usecases/login_usecase.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._loginUseCase) : super(const LoginInitial());

  final LoginUseCase _loginUseCase;

  Future<void> login(String clientId) async {
    if (state is LoginLoading) return;

    emit(const LoginLoading());
    final result = await _loginUseCase(clientId);
    if (isClosed) return;

    switch (result) {
      case ResultSuccess(:final data):
        emit(LoginSuccess(data));
      case ResultFailure(:final failure):
        emit(LoginError(failure.message));
    }
  }
}
