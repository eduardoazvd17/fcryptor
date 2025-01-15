sealed class Result<S, E> {
  const Result();

  bool get isSuccess => this is Success<S, E>;
  bool get isError => this is Error<S, E>;

  S? get value => switch (this) {
        Success(value: final v) => v,
        Error() => null,
      };

  E? get error => switch (this) {
        Error(error: final e) => e,
        Success() => null,
      };

  R fold<R>({
    required R Function(S value) onSuccess,
    required R Function(E error) onError,
  }) =>
      switch (this) {
        Success(value: final v) => onSuccess(v),
        Error(error: final e) => onError(e),
      };

  Result<T, E> map<T>(T Function(S value) mapper) => switch (this) {
        Success(value: final v) => Success(mapper(v)),
        Error(error: final e) => Error(e),
      };

  Result<S, F> mapError<F>(F Function(E error) mapper) => switch (this) {
        Success(value: final v) => Success(v),
        Error(error: final e) => Error(mapper(e)),
      };
}

class Success<S, E> extends Result<S, E> {
  @override
  final S value;
  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

class Error<S, E> extends Result<S, E> {
  @override
  final E error;
  const Error(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Error($error)';
}
