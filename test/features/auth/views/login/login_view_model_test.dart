import 'package:anotagasto_app/core/storage/storage_service.dart';
import 'package:anotagasto_app/core/view_state.dart';
import 'package:anotagasto_app/features/auth/models/login_response_model.dart';
import 'package:anotagasto_app/features/auth/repositories/auth_repository.dart';
import 'package:anotagasto_app/features/auth/views/login/login_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockAuthRepository authRepository;
  late MockStorageService storage;
  late LoginViewModel vm;

  setUp(() {
    authRepository = MockAuthRepository();
    storage = MockStorageService();
    vm = LoginViewModel(authRepository: authRepository, storage: storage);
  });

  tearDown(() => vm.dispose());

  group('initial state', () {
    test('starts with InitialStateView', () {
      expect(vm.viewState, isA<InitialStateView>());
    });
  });

  group('onSubmit — success', () {
    setUp(() {
      when(() => authRepository.login(any(), any()))
          .thenAnswer((_) async => LoginResponseModel(token: 'abc123'));
      when(() => storage.setToken(any())).thenAnswer((_) async {});
    });

    test('emits loading then success', () async {
      final states = <ViewState>[];
      vm.addListener(() => states.add(vm.viewState));

      await vm.onSubmit('11999999999', 'password123');

      expect(states, [isA<LoadingStateView>(), isA<SuccessStateView>()]);
    });

    test('success state contains the response token', () async {
      await vm.onSubmit('11999999999', 'password123');

      final state = vm.viewState as SuccessStateView;
      expect((state.data as LoginResponseModel).token, 'abc123');
    });

    test('saves token to storage on success', () async {
      await vm.onSubmit('11999999999', 'password123');

      verify(() => storage.setToken('abc123')).called(1);
    });
  });

  group('onSubmit — DioException', () {
    setUp(() {
      when(() => authRepository.login(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 401,
            data: {'error': 'Invalid credentials'},
          ),
        ),
      );
    });

    test('emits loading then error', () async {
      final states = <ViewState>[];
      vm.addListener(() => states.add(vm.viewState));

      await vm.onSubmit('11999999999', 'wrongpassword');

      expect(states, [isA<LoadingStateView>(), isA<ErrorStateView>()]);
    });

    test('error state contains backend message', () async {
      await vm.onSubmit('11999999999', 'wrongpassword');

      expect((vm.viewState as ErrorStateView).message, 'Invalid credentials');
    });

    test('does not save token on error', () async {
      await vm.onSubmit('11999999999', 'wrongpassword');

      verifyNever(() => storage.setToken(any()));
    });
  });

  group('onSubmit — unexpected exception', () {
    setUp(() {
      when(() => authRepository.login(any(), any()))
          .thenThrow(Exception('Unexpected error'));
    });

    test('emits loading then error with generic message', () async {
      final states = <ViewState>[];
      vm.addListener(() => states.add(vm.viewState));

      await vm.onSubmit('11999999999', 'password123');

      expect(states, [isA<LoadingStateView>(), isA<ErrorStateView>()]);
      expect(
        (vm.viewState as ErrorStateView).message,
        'Ocorreu um erro inesperado. Tente novamente.',
      );
    });
  });

  group('resetViewState', () {
    test('resets state back to InitialStateView', () async {
      when(() => authRepository.login(any(), any()))
          .thenThrow(Exception('error'));

      await vm.onSubmit('11999999999', 'password');
      expect(vm.viewState, isA<ErrorStateView>());

      vm.resetViewState();
      expect(vm.viewState, isA<InitialStateView>());
    });
  });
}
