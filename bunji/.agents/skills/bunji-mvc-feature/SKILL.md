---
name: bunji-mvc-feature
description: >-
  Use this skill whenever creating, refactoring, or extending features in the bunji codebase. It provides the end-to-end procedural checklist for building new models, services, controllers, routes, views, and unit tests following bunji's modular Feature-First MVC + Cubit + GetIt architecture (features/<feature>/view, viewcontroller, model).
---

# bunji Feature Implementation Runbook (Modular Feature-First)

Follow this step-by-step checklist whenever building a new screen, tab, or feature in bunji.

Features in bunji follow a **Modular Feature-First** directory structure:
```
lib/features/<feature_name>/
├── model/
│   └── <feature>_model.dart        # Feature-specific models & data entities
├── viewcontroller/
│   ├── <feature>_controller.dart   # Cubit controller managing business flow
│   └── <feature>_state.dart        # Immutable state & UI action state
└── view/
    ├── <feature>_view.dart         # Screen entry widget (BlocProvider & BlocConsumer)
    └── widgets/                    # Sub-widgets private to this feature
```

---

## Directory & Architecture Layout

```
lib/
├── app/                              # Global application configuration
│   ├── di.dart                       # Dependency Injection with GetIt (sl)
│   ├── routes.dart                   # Central GoRouter routing definitions
│   └── themes.dart                   # Color schemes, typography, AppColors
├── core/                             # Cross-cutting domain logic, shared contracts
│   ├── constants.dart                # App constants (Images, strings, etc.)
│   ├── pet_level_system.dart         # Pure domain math/algorithms
│   └── ui.dart                       # Base UI & UiAction contracts
├── services/                         # Shared infrastructure & data repositories
│   ├── local_storage_service.dart
│   ├── pet_repository.dart
│   └── supabase_service.dart
├── widgets/                          # Common reusable UI components (shared across features)
└── features/                         # Modular feature packages
    ├── home/                         # Example feature: home
    │   ├── model/                    # Domain models for home
    │   ├── viewcontroller/           # Cubit controller & state for home
    │   └── view/                     # Views & subwidgets for home
    ├── onboarding/
    │   ├── model/
    │   ├── viewcontroller/
    │   └── view/
    └── <feature_name>/
        ├── model/
        ├── viewcontroller/
        └── view/
```

---

## Step 1: Define Feature Models (`features/<feature_name>/model/`)

1. Create model classes in `lib/features/<feature_name>/model/<feature_name>_model.dart` (or `lib/core/` only if universally shared across multiple distinct features).
2. Ensure models:
   - Extend `Equatable`.
   - Implement `toMap()` and `fromMap(Map<String, dynamic> map)`.
   - Provide a complete `copyWith(...)` method.
3. Pure algorithms (calculations, scoring, level progression) belong in `lib/core/` (e.g. `lib/core/pet_level_system.dart`).

---

## Step 2: Define or Extend Service / Repository

1. If accessing Supabase or local storage:
   - Add method signature to the abstract class in `lib/services/pet_repository.dart` (or a dedicated service in `lib/services/`).
   - Implement the method in the concrete `Impl` class.
2. If creating a brand new service:
   - Register as `lazySingleton` in `lib/app/di.dart`:
     ```dart
     sl.registerLazySingleton<MyNewService>(() => MyNewServiceImpl(...));
     ```

---

## Step 3: Implement Controller & State (`features/<feature_name>/viewcontroller/`)

Create `lib/features/<feature_name>/viewcontroller/<feature_name>_controller.dart` (and optionally `<feature_name>_state.dart`):

1. **Define State**:
   - Must extend `Equatable`.
   - Must include `final UI ui;`.
   - Include `copyWith(...)` and `props`.
   - Provide a `.initial()` constructor initializing `ui = const UI()`.

2. **Define Controller**:
   - Extends `Cubit<<Feature>State>`.
   - Provide optional constructor parameters for repositories/services with fallback to `sl<T>()`.
   - Expose an `init()` method if initial asynchronous loading is required.
   - Use `state.ui.startLoading()`, `state.ui.stopLoading()`, `state.ui.showError()`, `state.ui.navigateTo()`.
   - Expose `void clearAction() => emit(state.copyWith(ui: state.ui.clearAction()));`.

Example:
```dart
// lib/features/home/viewcontroller/home_controller.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/ui.dart';
import '../../../app/di.dart';
import '../../../services/pet_repository.dart';
import '../model/home_model.dart';

class HomeState extends Equatable {
  final UI ui;
  final bool isLoading;
  final HomeData? data;

  const HomeState({
    required this.ui,
    this.isLoading = false,
    this.data,
  });

  const HomeState.initial()
      : ui = const UI(),
        isLoading = false,
        data = null;

  HomeState copyWith({
    UI? ui,
    bool? isLoading,
    HomeData? data,
  }) {
    return HomeState(
      ui: ui ?? this.ui,
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [ui, isLoading, data];
}

class HomeController extends Cubit<HomeState> {
  final PetRepository? petRepository;

  HomeController({this.petRepository}) : super(const HomeState.initial());

  PetRepository get _repo => petRepository ?? sl<PetRepository>();

  Future<void> init() async {
    emit(state.copyWith(ui: state.ui.startLoading(), isLoading: true));
    try {
      // Load data...
      emit(state.copyWith(ui: state.ui.stopLoading(), isLoading: false));
    } catch (e) {
      emit(state.copyWith(ui: state.ui.showError(e.toString()), isLoading: false));
    }
  }

  void clearAction() => emit(state.copyWith(ui: state.ui.clearAction()));
}
```

---

## Step 4: Register Controller in DI

In `lib/app/di.dart`, register the controller factory:

```dart
import '../features/<feature_name>/viewcontroller/<feature_name>_controller.dart';

// Inside registerControllers(GetIt sl):
sl.registerFactory<<Feature>Controller>(
  () => <Feature>Controller(
    petRepository: sl<PetRepository>(),
    localStorageService: sl<LocalStorageService>(),
    currentPetSession: sl<CurrentPetSession>(),
  ),
);
```

---

## Step 5: Configure Routing

In `lib/app/routes.dart`:

1. Add entry to `enum Routes`:
   ```dart
   enum Routes {
     // ...
     myFeature("/my-feature", "my-feature");
   }
   ```
2. Define the `GoRoute`:
   ```dart
   import '../features/<feature_name>/view/<feature_name>_view.dart';

   final _myFeatureRoute = GoRoute(
     path: Routes.myFeature.path,
     name: Routes.myFeature.name,
     builder: (context, state) {
       final args = state.extra; // handle any typed parameters
       return MyFeatureView(args: args);
     },
   );
   ```
3. Add `_myFeatureRoute` to `router`'s `routes` array.

---

## Step 6: Implement Presentation View (`features/<feature_name>/view/`)

In `lib/features/<feature_name>/view/<feature_name>_view.dart`:

1. Outer widget (`StatelessWidget`) sets up `BlocProvider`:
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
2. Inner widget consumes state and listens for UI actions:
   ```dart
   class _MyFeatureContent extends StatelessWidget {
     const _MyFeatureContent();

     @override
     Widget build(BuildContext context) {
       return BlocConsumer<MyFeatureController, MyFeatureState>(
         listenWhen: (previous, current) => current.ui.action != null,
         listener: (context, state) {
           final action = state.ui.action;
           final controller = context.read<MyFeatureController>();

           if (action is NavigateTo) {
             if (action.replace) {
               context.go(action.route.path, extra: action.args);
             } else {
               context.push(action.route.path, extra: action.args);
             }
             controller.clearAction();
           } else if (action is ShowError) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(action.message), backgroundColor: AppColors.error),
             );
             controller.clearAction();
           }
         },
         builder: (context, state) {
           final controller = context.read<MyFeatureController>();
           if (state.isLoading) {
             return const Scaffold(body: Center(child: CircularProgressIndicator()));
           }
           return Scaffold(
             // Use AppColors and theme text styles
             body: ...,
           );
         },
       );
     }
   }
   ```
3. Private or specific subwidgets reside in `lib/features/<feature_name>/view/widgets/`.

---

## Step 7: Write Modular Tests

Place tests matching the feature structure under `test/features/<feature_name>/`:
- `test/features/<feature_name>/viewcontroller/<feature_name>_controller_test.dart`
- `test/features/<feature_name>/view/<feature_name>_view_test.dart`

1. Implement fake service classes inline (e.g. `FakePetRepository implements PetRepository`).
2. Test initial state, success path, error paths, and UI action emissions.
3. In view tests, test widget rendering and interaction with pumped `BlocProvider`.

---

## Step 8: Quality Verification

Run standard checks from workspace root:

```bash
flutter analyze
flutter test
```
Ensure 0 analyzer errors and all unit/widget tests pass.
