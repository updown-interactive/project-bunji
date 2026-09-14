# bunji MVC Architecture Guide

This document defines the architectural patterns, layer responsibilities, and data flow used across the bunji Flutter application.

---

## 1. Architectural Overview

bunji follows a strict **Model-View-Controller (MVC)** design pattern adapted to Flutter's reactive widget tree using **Bloc/Cubit** and **GetIt**:

```
 ┌────────────────────────────────────────────────────────┐
 │                      VIEW LAYER                        │
 │  (lib/features/<feature>/view/, lib/widgets/)          │
 │  - Flutter Widgets (Stateless / Stateful)              │
 │  - Listens to Cubit states via BlocConsumer / Builder  │
 │  - Reacts to UI actions (NavigateTo, ShowError, etc.)  │
 │  - Dispatches user intents to Controller methods       │
 └───────────────────────┬─────────────────▲──────────────┘
                         │                 │
         User Interaction│                 │ State & UI
         (Calls methods) │                 │ Changes
                         ▼                 │
 ┌─────────────────────────────────────────┴──────────────┐
 │                   CONTROLLER LAYER                     │
 │  (lib/features/<feature>/viewcontroller/)              │
 │  - Extends Cubit<TState>                               │
 │  - Manages mutable business flow & emits immutable State│
 │  - Owns `state.ui` (isLoading, action)                 │
 │  - Injected via GetIt factory (lib/app/di.dart)        │
 └───────────────────────┬─────────────────▲──────────────┘
                         │                 │
        Invokes Services │                 │ Returns Data /
        & Repositories   │                 │ Domain Entities
                         ▼                 │
 ┌─────────────────────────────────────────┴──────────────┐
 │              SERVICE & REPOSITORY LAYER                │
 │  (lib/services/)                                       │
 │  - Abstract Interface + Concrete Implementation        │
 │  - PetRepository: Supabase CRUD & queries              │
 │  - SupabaseService: Client lifecycle & Auth            │
 │  - LocalStorageService: SharedPreferences wrapper       │
 │  - CurrentPetSession: In-memory reactive active pet    │
 │  - ImagePickerService & ImageCompressService           │
 └───────────────────────┬────────────────────────────────┘
                         │
                         ▼
 ┌────────────────────────────────────────────────────────┐
 │                  MODEL & CORE DOMAIN                   │
 │  (lib/features/<feature>/model/, lib/core/)            │
 │  - Pure domain models (PetOnboardingDraft, etc.)       │
 │  - PetLevelSystem: pure algorithms (XP, streak, levels)│
 │  - UI & UiAction contracts (lib/core/ui.dart)          │
 │  - Constant definitions (lib/core/constants.dart)      │
 └────────────────────────────────────────────────────────┘
```

---

## 2. Layer Responsibilities & Constraints

### 2.1 Model & Domain Layer (`lib/features/<feature>/model/`, `lib/core/`)
- **Immutability**: All model entities must be immutable and extend `Equatable`.
- **Serialization**: Provide `toMap()` and `fromMap(Map<String, dynamic> map)` for Supabase JSON/Row serialization.
- **Pure Domain Logic**: Algorithmic rules (such as XP gains, daily streak calculations, and level progressions) live in pure Dart classes in `lib/core/` (e.g. `PetLevelSystem`) without Flutter widget dependencies.
- **Zero Widget Dependencies**: Core models must never import Flutter UI widgets.

### 2.2 Controller Layer (`lib/features/<feature>/viewcontroller/`)
- **Base Class**: Every controller extends `Cubit<TState>`.
- **State Structure**:
  ```dart
  class MyFeatureState extends Equatable {
    final UI ui;
    final bool isLoading;
    final String? errorMessage;
    // ... feature specific fields ...

    const MyFeatureState({
      required this.ui,
      this.isLoading = false,
      this.errorMessage,
    });

    const MyFeatureState.initial()
        : ui = const UI(),
          isLoading = false,
          errorMessage = null;

    MyFeatureState copyWith({
      UI? ui,
      bool? isLoading,
      String? errorMessage,
      bool clearError = false,
    }) {
      return MyFeatureState(
        ui: ui ?? this.ui,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
    }

    @override
    List<Object?> get props => [ui, isLoading, errorMessage];
  }
  ```
- **Constructor Injection with Fallbacks**:
  ```dart
  class MyFeatureController extends Cubit<MyFeatureState> {
    final PetRepository? petRepository;
    final LocalStorageService? localStorageService;

    MyFeatureController({
      this.petRepository,
      this.localStorageService,
    }) : super(const MyFeatureState.initial());

    PetRepository get _repo => petRepository ?? sl<PetRepository>();
    LocalStorageService get _storage => localStorageService ?? sl<LocalStorageService>();
  }
  ```
  *Why*: This pattern allows the app runtime to use GetIt effortlessly while unit tests can pass `FakePetRepository` or `FakeLocalStorageService` directly in the constructor without mocking frameworks.
- **UI State & Action Control**:
  - Always update `state.ui` using `UIHelpers` (`startLoading()`, `stopLoading()`, `showError()`, `navigateTo()`, `pop()`).
  - Provide a `clearAction()` method:
    ```dart
    void clearAction() {
      emit(state.copyWith(ui: state.ui.clearAction()));
    }
    ```
- **Registration**: All controllers must be registered in `lib/app/di.dart` as factory:
  ```dart
  sl.registerFactory<MyFeatureController>(
    () => MyFeatureController(
      petRepository: sl<PetRepository>(),
      localStorageService: sl<LocalStorageService>(),
    ),
  );
  ```

### 2.3 View Layer (`lib/features/<feature>/view/`, `lib/widgets/`)
- **Structure**:
  - Top-level screen widget is typically a `StatelessWidget` creating the `BlocProvider`:
    ```dart
    class MyFeatureView extends StatelessWidget {
      const MyFeatureView({super.key});

      @override
      Widget build(BuildContext context) {
        return BlocProvider(
          create: (_) => sl<MyFeatureController>()..init(),
          child: const _MyFeatureContent(),
        );
      }
    }
    ```
  - Internal content widget uses `BlocConsumer<MyFeatureController, MyFeatureState>`:
    ```dart
    return BlocConsumer<MyFeatureController, MyFeatureState>(
      listenWhen: (previous, current) => current.ui.action != null,
      listener: (context, state) {
        final action = state.ui.action;
        if (action is NavigateTo) {
          if (action.replace) {
            context.go(action.route.path, extra: action.args);
          } else {
            context.push(action.route.path, extra: action.args);
          }
          context.read<MyFeatureController>().clearAction();
        } else if (action is ShowError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(action.message), backgroundColor: AppColors.error),
          );
          context.read<MyFeatureController>().clearAction();
        }
      },
      builder: (context, state) {
        final controller = context.read<MyFeatureController>();
        // render UI based on state
      },
    );
    ```
- **View Discipline**:
  - Views do **not** contain business logic or call repositories/Supabase directly.
  - Views delegate user interactions directly to controller methods (e.g. `onTap: controller.doSomething`).
  - Animation and gesture logic (e.g. `AnimationController`, pan gestures) belong in the View or custom widgets.

### 2.4 Service & Repository Layer (`lib/services/`)
- Every service follows the interface-implementation pattern:
  - `PetRepository` (abstract class) and `PetRepositoryImpl` (concrete implementation).
  - `LocalStorageService` and `LocalStorageServiceImpl`.
- Registered as `lazySingleton` in `lib/app/di.dart`.
- Services encapsulate all external network, database, filesystem, or device hardware calls.
- In-memory shared sessions (like `CurrentPetSession`) provide reactive `ChangeNotifier` / `ValueNotifier` hooks that controllers can subscribe to.

---

## 3. Navigation & Routing Architecture

Navigation is centralized in `lib/app/routes.dart`:
- Defined using `Routes` enum:
  ```dart
  enum Routes {
    splash("/", "splash"),
    onboarding("/onboarding", "onboarding"),
    pets("/pets", "pets"),
    auth("/auth", "auth"),
    shell("/shell", "shell"),
    store("/store", "store");

    final String path, name;
    const Routes(this.path, this.name);
  }
  ```
- Configured with `go_router`:
  - Route arguments are extracted via `state.extra`.
  - Controllers emit navigation via `state.ui.navigateTo(Routes.shell, args: pet, replace: true)`.
  - Views execute navigation using `context.go(action.route.path, extra: action.args)` for replacements or `context.push(...)` for push transitions.
