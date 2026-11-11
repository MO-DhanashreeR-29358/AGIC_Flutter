import '../error/failures.dart';

/// Outcome of a repository call: either [ResultSuccess] or [ResultFailure].
sealed class Result<T> {
  const Result();
}

final class ResultSuccess<T> extends Result<T> {
  const ResultSuccess(this.data);

  final T data;
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);

  final Failure failure;
}
