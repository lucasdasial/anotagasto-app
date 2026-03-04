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

### State management
The app uses **Riverpod** (`flutter_riverpod`) for all state management. Providers live close to the feature that owns them. Key providers:
- `storageServiceProvider` — wraps `SharedPreferences`
- `httpClientProvider` — `Dio` instance with Bearer token interceptor
- `authRepositoryProvider` — auth API calls
- Feature-level `AsyncNotifierProvider` / `NotifierProvider` for screen state

### HTTP client
`lib/core/http/http_client.dart` wraps **Dio** (not the `http` package). It is initialized as a Riverpod provider so it can read the token from `StorageService` and inject `Authorization: Bearer <token>` on every request. `HttpErrorHandler` (an interceptor) maps status codes to Portuguese error messages.

Base URL comes from `Envs.apiBaseUrl` → `.env` file (`API_BASE_URL`), defaulting to `http://localhost:4000`.

### Auth
- `StorageService` (`lib/core/storage/storage_service.dart`) persists the JWT token and user ID in `SharedPreferences` under `auth_token` / `user_id`.
- `AuthRepository` (`lib/features/login/data/`) posts to `/api/auth` and `/api/register`.
- After login the token must be saved via `StorageService` before the HTTP client can make authenticated requests.

### Routing
Simple `MaterialApp.routes` map in `lib/app/app.dart`. No GoRouter — named routes only.

### Models
All JSON models live in `lib/core/models/`. `ExpenseModel.value` is stored in **cents** (integer). `ExpenseCategory` is a Dart enum with `toApi()` / `fromApi()` converters to match backend snake_case strings, plus `.label` (Portuguese) and `.icon` fields.

### Theme
`AppTheme.light` in `lib/core/theme/app_theme.dart` — Material3 light theme. Use `AppColors` and `AppTextStyles` constants rather than hardcoding styles. `AppColors.chartPalette` provides one color per category (ordered to match `ExpenseCategory.values`).

### Responsive layout
Wrap content with `MaxWidthContainer` (max 1080 px) for web compatibility.

### Utilities
- `CurrencyFormatter.format(num)` — BRL (`R$ 1.234,56`)
- `CurrencyFormatter.parse(String)` — returns int cents
- `DateFormatter.toApiMonth(year, month)` → `"2024-03"` for API params
- `Debouncer` — 400 ms default, call `.dispose()` in widget dispose

### Localization
UI text and error messages are in **Portuguese (pt_BR)**. Confirm dialogs default to "Confirmar" / "Cancelar".

## Key conventions

- Expense amounts are always **integers (cents)** in the model layer; format for display with `CurrencyFormatter`.
- The `features/` directory follows a per-feature structure: `feature_name/` → `data/` (repositories, response models), widget files at the feature root.
- Reusable widgets go in `lib/core/widgets/`.
- Add/edit expenses via a bottom sheet opened with `showGeneralDialog` + `BackdropFilter` blur.
- Pull-down-to-add gesture uses `BouncingScrollPhysics` + `NotificationListener` (mobile only — does not work on Flutter web; use a FAB on web).
