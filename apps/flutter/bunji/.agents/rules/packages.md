# Packages & Dependencies Guide for bunji

This guide documents every core package used in the bunji application, its intended role in the architecture, and strict usage patterns.

---

## 1. Package Inventory & Versioning

| Package | Version | Purpose in bunji |
| :--- | :--- | :--- |
| `flutter_bloc` | `^9.1.1` | State management via `Cubit` controllers |
| `equatable` | `^2.1.0` | Value equality for states, events, and models |
| `get_it` | `^9.2.1` | Dependency injection & service locator (`sl`) |
| `go_router` | `^17.5.0` | Declarative URL-based routing & navigation |
| `supabase_flutter` | `^2.17.2` | Backend BaaS: Auth, Database (PostgreSQL), Storage |
| `liquid_glass_widgets`| `^0.30.1` | Liquid glassmorphism UI components & shaders |
| `shared_preferences` | `^2.5.4` | Local device key-value persistence |
| `image_picker` | `^1.2.3` | Camera & gallery image picking for pet avatars |
| `image` | `^4.9.2` | In-memory image processing, downscaling, compression |
| `sensors_plus` | `^7.1.0` | Accelerometer & gyro streams for 3D card parallax |
| `cupertino_icons` | `^1.0.8` | iOS style icons |
| `flutter_lints` | `^6.0.0` | Recommended static analysis lints |
| `flutter_launcher_icons`| `^0.14.3` | App icon generation across platforms |

---

## 2. Package Usage Guidelines

### 2.1 `flutter_bloc` & `equatable`
- **Pattern**: bunji uses `Cubit` rather than event-driven `Bloc` for cleaner, direct controller methods.
- **Rules**:
  - Controllers must extend `Cubit<TState>`.
  - State classes must extend `Equatable` and declare all fields in `props`.
  - Never mutate state directly; always emit a new instance via `state.copyWith(...)`.
  - Avoid calling `emit()` if `isClosed` is true (especially in async/callback listeners).
  - Use `BlocConsumer` when the view needs to both rebuild UI based on state (`builder`) and respond to one-off actions like navigation or toasts (`listener`).

### 2.2 `get_it`
- **Pattern**: Centralized service locator `sl` defined in `lib/app/di.dart`.
- **Rules**:
  - Services, repositories, and singleton sessions are registered as `lazySingleton`:
    ```dart
    sl.registerLazySingleton<PetRepository>(() => PetRepositoryImpl(...));
    sl.registerLazySingleton<CurrentPetSession>(() => CurrentPetSession());
    ```
  - ViewControllers are registered as `factory` in `registerControllers(sl)` within `lib/app/di.dart`:
    ```dart
    sl.registerFactory<HomeController>(() => HomeController(...));
    ```
  - In views, always instantiate controllers via `sl<TController>()` in `BlocProvider(create: (_) => sl<...>()..init())`.
  - In controllers, provide optional constructor injection with fallback:
    ```dart
    PetRepository get _repo => petRepository ?? sl<PetRepository>();
    ```

### 2.3 `go_router`
- **Pattern**: Centralized in `lib/app/routes.dart`.
- **Rules**:
  - All routes must be enumerated in `enum Routes`.
  - Pass arguments via `extra`. Avoid query parameter string manipulation unless deep linking requires it.
  - In the view listener:
    - Use `context.go(route.path, extra: args)` when replacing the current stack (e.g. login -> shell).
    - Use `context.push(route.path, extra: args)` when pushing a new route that can be popped back.
  - Never trigger navigation inside controller business logic directly using `BuildContext`. Always emit `NavigateTo` through `state.ui`.

### 2.4 `supabase_flutter`
- **Pattern**: Encapsulated inside `SupabaseService` and `PetRepository`.
- **Rules**:
  - Initialized in `main.dart` before `runApp`.
  - Views must NEVER call `Supabase.instance.client` directly. All calls flow through `PetRepository` or `SupabaseService`.
  - Auth queries:
    - User session checks: `supabaseService.isAuthenticated`.
    - Sign in via OTP / Email: `signInWithOtp()`, `verifyOTP()`.
  - Database queries:
    - Use parameterized filters (`.eq('user_id', userId)`).
    - Use `.maybeSingle()` when records might not exist to prevent unhandled exceptions.
    - Keep Supabase RPC or raw table names consistent with database migrations (`supabase/migrations/`).
  - Deprecations:
    - Avoid deprecated fields (e.g. use `emailConfirmedAt` instead of `confirmedAt`).

### 2.5 `liquid_glass_widgets`
- **Pattern**: Initialized in `main.dart` (`await LiquidGlassWidgets.initialize()`) and wrapped around `runApp(LiquidGlassWidgets.wrap(child: ...))`.
- **Rules**:
  - Use `GlassTabBar` or `LiquidGlass` styling with `LiquidGlassSettings`:
    ```dart
    LiquidGlassSettings(
      glassColor: cs.surfaceContainer.withValues(alpha: 0.75),
      backerColor: cs.surfaceContainer,
      blur: 10,
      thickness: 25,
    )
    ```
  - Be mindful of GPU rendering performance when stacking multiple heavily blurred glass containers.

### 2.6 `shared_preferences`
- **Pattern**: Encapsulated strictly inside `LocalStorageService` (`lib/services/local_storage_service.dart`).
- **Rules**:
  - Used for fast local key-value checks:
    - Current local user ID (`userId`).
    - Onboarding completion flag (`hasCompletedOnboarding`).
  - Do not scatter `SharedPreferences.getInstance()` calls across controllers or views.

### 2.7 `image_picker` & `image`
- **Pattern**:
  - `ImagePickerService` selects image from gallery or camera.
  - `ImageCompressService` resizes and compresses image data using the `image` package:
    - Decodes image bytes.
    - Scales down to max dimensions (e.g., 1024px).
    - Re-encodes to high quality JPEG with reduced payload size.
- **Rules**:
  - Always compress images before uploading to Supabase Storage or caching to preserve bandwidth and database performance.

### 2.8 `sensors_plus`
- **Pattern**: Realtime accelerometer stream in `pet_card.dart` for realistic 3D tilt.
- **Rules**:
  - Always manage `StreamSubscription<AccelerometerEvent>?`.
  - Cancel and dispose of the sensor stream subscription in `dispose()` to prevent memory leaks and unnecessary battery drain.
  - Clamp tilt angles (`math.pi / 18` or similar) to ensure the UI card remains legible and comfortable to view.
