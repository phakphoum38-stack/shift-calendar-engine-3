/// Typed outcome used across application and repository boundaries.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
}

/// Successful operation carrying [value].
final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

/// Controlled operation failure.
sealed class Failure<T> extends Result<T> {
  const Failure(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
}

/// Invalid input or domain state.
final class ValidationFailure<T> extends Failure<T> {
  const ValidationFailure(
    super.message, {
    this.fieldErrors = const {},
    super.cause,
    super.stackTrace,
  });

  final Map<String, String> fieldErrors;
}

/// Local persistence operation failure.
final class PersistenceFailure<T> extends Failure<T> {
  const PersistenceFailure(super.message, {super.cause, super.stackTrace});
}

/// Remote provider or network operation failure.
final class NetworkFailure<T> extends Failure<T> {
  const NetworkFailure(
    super.message, {
    this.statusCode,
    super.cause,
    super.stackTrace,
  });

  final int? statusCode;
}
