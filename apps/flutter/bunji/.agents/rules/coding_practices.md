# Coding Practices & Standards for bunji

This guide establishes the coding conventions, patterns, and quality standards for developing in the bunji codebase.

---

## 1. Naming Conventions

| Component | Convention | Example |
| :--- | :--- | :--- |
| **Feature Directories** | `features/<feature>/` | `lib/features/home/`, `lib/features/onboarding/` |
| **Feature Subfolders** | `view/`, `viewcontroller/`, `model/` | `lib/features/home/view/`, `.../viewcontroller/`, `.../model/` |
| **File names** | `snake_case.dart` | `home_controller.dart`, `home_view.dart`, `home_model.dart` |
| **Classes** | `PascalCase` | `HomeController`, `HomeView`, `HomeModel` |
| **Controllers** | `<Feature>Controller` | `HomeController`, `ShellController`, `OnboardingController` |
| **States** | `<Feature>State` | `HomeState`, `ShellState`, `OnboardingState` |
| **Views** | `<Feature>View` | `HomeView`, `SplashView`, `StoreView` |
| **Service Interfaces** | `<Feature>Service` or `<Entity>Repository` | `PetRepository`, `LocalStorageService` |
| **Service Implementations** | `<Name>Impl` | `PetRepositoryImpl`, `LocalStorageServiceImpl` |
| **Constants** | `Images`, `Strings`, `AppColors` | `Images.bunjiSplash`, `AppColors.primary` |

---

## 2. State & UI Pattern (`lib/core/ui.dart`)

All controllers manage a `UI` object within their state:

```dart
class UI extends Equatable {
  final bool isLoading;
  final UiAction? action;
  // ...
}
```

### 2.1 Emitting UI Actions from Controllers
Use the `UIHelpers` extension on `state.ui`:

```dart
// Start / Stop Loading
emit(state.copyWith(ui: state.ui.startLoading()));
emit(state.copyWith(ui: state.ui.stopLoading()));

// Show Error or Success
emit(state.copyWith(ui: state.ui.showError('Could not sync pet data.')));
emit(state.copyWith(ui: state.ui.showSuccess('Level up!')));

// Navigation
emit(state.copyWith(ui: state.ui.navigateTo(Routes.shell, args: pet, replace: true)));
emit(state.copyWith(ui: state.ui.pop()));
```

### 2.2 Handling Actions in Views
The view must listen for `action != null`, execute the action, and then immediately call `controller.clearAction()`:

```dart
BlocConsumer<MyController, MyState>(
  listenWhen: (previous, current) => current.ui.action != null,
  listener: (context, state) {
    final action = state.ui.action;
    final controller = context.read<MyController>();

    if (action is NavigateTo) {
      if (action.replace) {
        context.go(action.route.path, extra: action.args);
      } else {
        context.push(action.route.path, extra: action.args);
      }
      controller.clearAction();
    } else if (action is ShowError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(action.message),
          backgroundColor: AppColors.error,
        ),
      );
      controller.clearAction();
    } else if (action is ShowSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(action.message),
          backgroundColor: AppColors.success,
        ),
      );
      controller.clearAction();
    } else if (action is PopPage) {
      Navigator.of(context).pop(action.value);
      controller.clearAction();
    }
  },
  builder: (context, state) {
    // Return widget tree
  },
)
```

---

## 3. Dependency Injection & Testability

### 3.1 Controller Constructor Pattern
Controllers must never instantiate concrete service dependencies directly. Accept optional constructor parameters with GetIt fallback:

```dart
class PetTabController extends Cubit<PetTabState> {
  final CurrentPetSession? currentPetSession;
  final PetRepository? petRepository;

  PetTabController({
    this.currentPetSession,
    this.petRepository,
  }) : super(const PetTabState.initial());

  CurrentPetSession get _session => currentPetSession ?? sl<CurrentPetSession>();
  PetRepository get _repo => petRepository ?? sl<PetRepository>();
}
```

### 3.2 Unit Testing with Fakes
Do not rely on complex mock generators. Implement concise `Fake` classes directly in test files:

```dart
class FakePetRepository implements PetRepository {
  List<Map<String, dynamic>> pets = [];

  @override
  Future<List<Map<String, dynamic>>> getPets(String userId) async => pets;

  // Implement remaining required methods with mock state
}

void main() {
  test('loads pets on init', () async {
    final repo = FakePetRepository()..pets = [{'name': 'bunji'}];
    final controller = PetsController(petRepository: repo);

    await controller.init();
    expect(controller.state.pets.length, 1);
  });
}
```

---

## 4. UI, Styling & Asset Standards

1. **Colors**:
   - Always reference colors from `AppColors` (`lib/app/themes.dart`) or `Theme.of(context).colorScheme`.
   - Never hardcode arbitrary hex values directly inside widgets.
2. **Typography**:
   - Primary display font: `BrittanySignature` (configured in `lib/app/themes.dart`).
   - Use `Theme.of(context).textTheme` for body, title, and label styling.
3. **Assets**:
   - All image asset paths must be defined in `Images` (`lib/core/constants.dart`).
   - Never write `'assets/images/my_icon.png'` directly in widgets.
4. **Optimistic Updates**:
   - When updating user stats (XP, streaks, completion counts), update state immediately in the controller so UI is instantaneous, and sync to Supabase asynchronously in the background. If Supabase fails, catch error and log or restore state gracefully.

---

## 5. Clean Code & Linter Enforcement

Before completing any task or pull request:
1. Ensure all imports are used; remove unused imports.
2. Ensure no unused local variables or fields exist.
3. Avoid deprecated Flutter methods (e.g. use `Matrix4.translateByVector3` or `Matrix4.scaleByVector3` instead of deprecated `Matrix4.translate` / `scale`).
4. Validate with:
   ```bash
   flutter analyze
   flutter test
   ```
