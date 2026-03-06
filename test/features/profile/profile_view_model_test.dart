import 'package:anotagasto_app/core/models/user_model.dart';
import 'package:anotagasto_app/core/storage/storage_service.dart';
import 'package:anotagasto_app/core/view_state.dart';
import 'package:anotagasto_app/features/profile/profile_repository.dart';
import 'package:anotagasto_app/features/profile/profile_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockStorageService extends Mock implements StorageService {}

const _mockUser = UserModel(id: '1', name: 'João', phone: '11999999999');

void main() {
  late MockProfileRepository repository;
  late MockStorageService storage;
  late ProfileViewModel vm;

  setUp(() {
    repository = MockProfileRepository();
    storage = MockStorageService();
    vm = ProfileViewModel(repository: repository, storage: storage);
  });

  tearDown(() => vm.dispose());

  group('loadUser', () {
    test('starts with InitialStateView', () {
      expect(vm.viewState, isA<InitialStateView>());
    });

    test('emits loading then success', () async {
      when(() => repository.getMe()).thenAnswer((_) async => _mockUser);

      final states = <ViewState>[];
      vm.addListener(() => states.add(vm.viewState));

      await vm.loadUser();

      expect(states, [isA<LoadingStateView>(), isA<SuccessStateView>()]);
    });

    test('sets user data on success', () async {
      when(() => repository.getMe()).thenAnswer((_) async => _mockUser);

      await vm.loadUser();

      final state = vm.viewState as SuccessStateView<UserModel>;
      expect(state.data.id, '1');
      expect(state.data.name, 'João');
    });

    test('sets error message from DioException response body', () async {
      when(() => repository.getMe()).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 401,
            data: {'error': 'Não autorizado'},
          ),
        ),
      );

      await vm.loadUser();

      expect(vm.viewState, isA<ErrorStateView>());
      expect((vm.viewState as ErrorStateView).message, 'Não autorizado');
    });

    test('sets generic message on unexpected error', () async {
      when(() => repository.getMe()).thenThrow(Exception('unexpected'));

      await vm.loadUser();

      expect(vm.viewState, isA<ErrorStateView>());
      expect(
        (vm.viewState as ErrorStateView).message,
        'Ocorreu um erro inesperado. Tente novamente.',
      );
    });
  });

  group('logout', () {
    test('calls storage.clearAll', () async {
      when(() => storage.clearAll()).thenAnswer((_) async {});

      await vm.logout();

      verify(() => storage.clearAll()).called(1);
    });

    test('sets loggedOut to true', () async {
      when(() => storage.clearAll()).thenAnswer((_) async {});

      await vm.logout();

      expect(vm.loggedOut, isTrue);
    });

    test('notifies listeners', () async {
      when(() => storage.clearAll()).thenAnswer((_) async {});

      var notified = false;
      vm.addListener(() => notified = true);

      await vm.logout();

      expect(notified, isTrue);
    });
  });
}
