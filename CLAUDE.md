# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get       # Install/update dependencies
flutter analyze       # Lint
flutter test          # Run all tests
flutter test test/path/to/test.dart  # Run a single test file
flutter run           # Run app (requires device/emulator)
flutter build apk     # Android build
flutter build web     # Web build
```

## Architecture

### Dependency injection
`get_it` is the service locator. The global instance is `di` (defined in `lib/core/di/service_locator.dart`).
`setupServiceLocator()` is called in `main()` before `runApp` and registers all singletons:

```dart
di.registerSingleton<StorageService>(...);
di.registerSingleton<HttpClient>(...);
di.registerSingleton<AuthRepository>(...);
```

Use `di<T>()` only at the composition layer (route definitions in `app.dart`). Never call `di<T>()` inside ViewModels or widgets.

### State management
`provider` (`ChangeNotifier` + `ChangeNotifierProvider`) manages reactive UI state.

- Each screen has a `ViewModel extends ChangeNotifier` with a sealed `ViewState`
- `ChangeNotifierProvider` is scoped to the route in `app.dart`, not at the app root
- Dependencies are injected into the ViewModel constructor (not read from `di` inside the ViewModel)

```dart
// app.dart — provider scoped to route
'/login': (context) => ChangeNotifierProvider(
  create: (_) => LoginViewModel(
    authRepository: di<AuthRepository>(),
    storage: di<StorageService>(),
  ),
  child: const AuthShell(child: LoginView()),
),
```

### Reading state in widgets
- `context.select<VM, T>((vm) => ...)` — rebuild only when the selected value changes (prefer this for buttons, loading indicators)
- `context.read<VM>()` — one-time read inside callbacks (`onPressed`, listeners); never in `build`
- `context.watch<VM>()` — rebuilds the full widget on any change; avoid unless the entire widget depends on state
- `Consumer(builder:, child:)` — use `child` param to cache subtrees that don't depend on state

### Side effects (navigation, snackbars)
Handle in `addListener` registered in `initState`, not via `addPostFrameCallback` in `build`:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<LoginViewModel>().addListener(_onStateChange);
  });
}

@override
void dispose() {
  context.read<LoginViewModel>().removeListener(_onStateChange);
  super.dispose();
}
```

### ViewState pattern
All screens share the generic sealed class `ViewState` defined in `lib/core/view_state.dart`:

```dart
sealed class ViewState {}
class InitialStateView extends ViewState {}
class LoadingStateView extends ViewState {}
class ErrorStateView extends ViewState { final String message; ... }
class SuccessStateView<T> extends ViewState { final T data; ... }
```

Each ViewModel declares `ViewState viewState = InitialStateView()` and uses pattern matching in the view:

```dart
// select para rebuilds mínimos
final isLoading = context.select<MyViewModel, bool>((vm) => vm.viewState is LoadingStateView);

// listener para side effects
final state = context.read<MyViewModel>().viewState;
if (state is SuccessStateView) { ... }
if (state is ErrorStateView) { AppSnackBar.error(context, state.message); }
```

ViewModels must catch both `DioException` (for HTTP errors) and generic `Exception` (for unexpected errors):

```dart
try {
  ...
} on DioException catch (e) {
  viewState = ErrorStateLogin(e.response?.data?["error"] ?? e.message);
} catch (e, stack) {
  debugPrint('ViewModel.method: $e\n$stack');
  viewState = ErrorStateLogin('Ocorreu um erro inesperado. Tente novamente.');
}
```

### HTTP client
`lib/core/http/http_client.dart` wraps **Dio**. Receives `StorageService` in the constructor.
Two interceptors (in order):
1. `AuthInterceptor` — injects `Authorization: Bearer <token>` from `StorageService`
2. `HttpErrorHandler` — maps network/server errors to Portuguese messages; **passes 4xx through with body intact** so the ViewModel can read `e.response?.data["error"]`

Base URL: `Envs.apiBaseUrl` → `.env` file (`API_BASE_URL`), defaulting to `http://localhost:4000`.

### Auth
`StorageService` (`lib/core/storage/storage_service.dart`) persists JWT token and user ID in `SharedPreferences` under `auth_token` / `user_id`.

### Routing
`MaterialApp.routes` in `lib/app/app.dart`. No GoRouter — named routes only.

### Models
All shared JSON models live in `lib/core/models/`. `ExpenseModel.value` is stored in **cents** (integer). `ExpenseCategory` is a Dart enum with `toApi()` / `fromApi()` converters to match backend snake_case strings, plus `.label` (Portuguese) and `.icon` fields.

### Theme
`AppTheme.light` in `lib/core/theme/app_theme.dart` — Material3 light theme. Use `AppColors` and `AppTextStyles` constants rather than hardcoding styles. `AppColors.chartPalette` provides one color per category (ordered to match `ExpenseCategory.values`).

### Responsive layout
The app runs on **both mobile and web browser** — every screen must be responsive.

- Authenticated screens are wrapped with `AppShell` (`lib/core/widgets/app_shell.dart`), which constrains content to **max 1280 px** and handles the auth guard
- Use `MediaQuery.of(context).size.width` or `LayoutBuilder` to adapt layouts between mobile and wide viewports
- Avoid fixed pixel widths on interactive elements — prefer `double.infinity` with a max constraint from the parent
- `BouncingScrollPhysics` pull-to-add does **not** work on Flutter web; use a FAB as the add action on web (`kIsWeb`)
- Breakpoints are defined in `Constants` (`lib/core/utils/constants.dart`): `breakpointMobile = 390`, `breakpointDesktop = 1280`
- Test layouts at both breakpoints

### Utilities
- `CurrencyFormatter.format(num cents)` — recebe **centavos** e retorna BRL (`1000 → R$ 10,00`)
- `CurrencyFormatter.parse(String)` — retorna **centavos** (`"R$ 10,00" → 1000`)
- `DateFormatter.toApiMonth(year, month)` → `"2024-03"` for API params
- `Debouncer` — 400 ms default, call `.dispose()` in widget dispose
- `AppSnackBar.error(context, msg)` / `.success(...)` / `.info(...)` — use instead of `ScaffoldMessenger` directly

### Localization
UI text and error messages are in **Portuguese (pt_BR)**. Confirm dialogs default to "Confirmar" / "Cancelar".

## Testing conventions

- **Test names are always in English** — clear, semantic, describing behavior not implementation.
- Use the pattern `does X when Y` or a plain descriptive phrase: `returns null for non-numeric string`, `emits loading then success`, `saves token to storage on success`.
- Never use Portuguese in test names.

## Key conventions

- **Prefer `StatelessWidget` for views.** Use `StatefulWidget` only when strictly necessary (e.g. `TextEditingController` disposal or `addListener`/`removeListener` lifecycle). Justify the choice in a comment when `StatefulWidget` is unavoidable.
- **Never call `di<T>()` inside ViewModels or widgets** — only in the `create` callback of `ChangeNotifierProvider` in `app.dart`.
- Expense amounts are always **integers (cents)** in the model layer; format for display with `CurrencyFormatter`. `1000 = R$ 10,00` — sempre divida por 100 ao exibir, multiplique por 100 ao salvar.
- The `features/` directory follows a per-feature structure: `feature_name/` → `data/` (repositories, response models), widget files at the feature root. Sub-widgets go in `feature_name/widgets/`.
- Reusable widgets go in `lib/core/widgets/`.
- Add/edit expenses via a bottom sheet opened with `showGeneralDialog` + `BackdropFilter` blur.
- Pull-down-to-add gesture uses `BouncingScrollPhysics` + `NotificationListener` (mobile only — does not work on Flutter web; use a FAB on web).
