import 'package:equatable/equatable.dart';

import '../../domain/entities/login_user.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginSuccess extends LoginState {
  const LoginSuccess(this.user);

  final LoginUser user;

  @override
  List<Object?> get props => [user];
}

final class LoginError extends LoginState {
  const LoginError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
