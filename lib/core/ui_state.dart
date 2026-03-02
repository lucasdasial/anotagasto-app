sealed class UiState<T> {
  const UiState();
}

class Initial<T> extends UiState<T> {
  const Initial();
}

class Loading<T> extends UiState<T> {
  const Loading();
}

class Refreshing<T> extends UiState<T> {
  final T data;
  const Refreshing(this.data);
}

class Success<T> extends UiState<T> {
  final T data;
  const Success(this.data);
}

class Empty<T> extends UiState<T> {
  const Empty();
}

class Error<T> extends UiState<T> {
  final String message;
  const Error(this.message);
}
