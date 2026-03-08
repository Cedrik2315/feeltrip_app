sealed class Result<T> {
  const Result();

  R fold<R>({
    required R Function(Object error, StackTrace? stackTrace) onFailure,
    required R Function(T value) onSuccess,
  });

  T getOrElse(T defaultValue);
  T? getOrNull();
  Result<R> map<R>(R Function(T value) transform);
  Result<T> onSuccess(void Function(T value) action);
  Result<T> onFailure(
      void Function(Object error, StackTrace? stackTrace) action);
  bool get isSuccess;
  bool get isFailure;
}

class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);

  @override
  R fold<R>({
    required R Function(Object error, StackTrace? stackTrace) onFailure,
    required R Function(T value) onSuccess,
  }) {
    return onSuccess(value);
  }

  @override
  T getOrElse(T defaultValue) => value;

  @override
  T? getOrNull() => value;

  @override
  Result<R> map<R>(R Function(T value) transform) {
    try {
      return Success(transform(value));
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  @override
  Result<T> onSuccess(void Function(T value) action) {
    action(value);
    return this;
  }

  @override
  Result<T> onFailure(
      void Function(Object error, StackTrace? stackTrace) action) {
    return this;
  }

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;
}

class Failure<T> extends Result<T> {
  final Object error;
  final StackTrace? stackTrace;

  const Failure(this.error, [this.stackTrace]);

  @override
  R fold<R>({
    required R Function(Object error, StackTrace? stackTrace) onFailure,
    required R Function(T value) onSuccess,
  }) {
    return onFailure(error, stackTrace);
  }

  @override
  T getOrElse(T defaultValue) => defaultValue;

  @override
  T? getOrNull() => null;

  @override
  Result<R> map<R>(R Function(T value) transform) {
    return Failure(error, stackTrace) as Result<R>;
  }

  @override
  Result<T> onSuccess(void Function(T value) action) {
    return this;
  }

  @override
  Result<T> onFailure(
      void Function(Object error, StackTrace? stackTrace) action) {
    action(error, stackTrace);
    return this;
  }

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;
}

Result<T> runCatching<T>(T Function() block) {
  try {
    return Success(block());
  } catch (e, st) {
    return Failure(e, st);
  }
}

Future<Result<T>> runCatchingAsync<T>(Future<T> Function() block) async {
  try {
    return Success(await block());
  } catch (e, st) {
    return Failure(e, st);
  }
}
