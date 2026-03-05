import 'package:anotagasto_app/core/http/http_client.dart';
import 'package:anotagasto_app/core/storage/storage_service.dart';
import 'package:anotagasto_app/features/auth/repositories/auth_repository.dart';
import 'package:anotagasto_app/features/expenses/expense_repository.dart';
import 'package:anotagasto_app/features/profile/profile_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final di = GetIt.instance;

Future<void> setupServiceLocator() async {
  final prefs = await SharedPreferences.getInstance();

  di.registerSingleton<StorageService>(StorageService(prefs));
  di.registerSingleton<HttpClient>(HttpClient(di<StorageService>()));
  di.registerSingleton<AuthRepository>(AuthRepository(di<HttpClient>()));
  di.registerSingleton<ExpenseRepository>(ExpenseRepository(di<HttpClient>()));
  di.registerSingleton<ProfileRepository>(ProfileRepository(di<HttpClient>()));
}
