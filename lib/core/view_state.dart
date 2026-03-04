sealed class ViewState {}

class InitialStateView extends ViewState {}

class LoadingStateView extends ViewState {}

class ErrorStateView extends ViewState {
  final String message;
  ErrorStateView(this.message);
}

class SuccessStateView<T> extends ViewState {
  final T data;
  SuccessStateView(this.data);
}
