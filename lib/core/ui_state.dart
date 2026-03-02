sealed class UiState<T> {}

class Initial<T> extends UiState<T> {}

class Loading<T> extends UiState<T> {}

class Refreshing<T> extends UiState<T> {
  final T data;
  Refreshing(this.data);
}

class Success<T> extends UiState<T> {
  final T data;
  Success(this.data);
}

class Empty<T> extends UiState<T> {}

class Error<T> extends UiState<T> {
  final String message;
  Error(this.message);
}
