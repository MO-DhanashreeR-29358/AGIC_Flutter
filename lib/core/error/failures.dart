import 'package:equatable/equatable.dart';

/// Domain-level error returned to the presentation layer.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}
