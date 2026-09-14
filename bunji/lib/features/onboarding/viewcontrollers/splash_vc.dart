import 'package:bunji/app/di.dart';
import 'package:bunji/app/routes.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashState extends Equatable {
  final UI ui;
  final bool isLoading;

  const SplashState({required this.ui, this.isLoading = false});

  const SplashState.initial() : ui = const UI(), isLoading = false;

  SplashState copyWith({UI? ui, bool? isLoading}) {
    return SplashState(
      ui: ui ?? this.ui,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [ui, isLoading];
}

class SplashViewController extends Cubit<SplashState> {
  final DatabaseService? databaseService;
  final BunjiModelManager? modelManager;

  SplashViewController({this.databaseService, this.modelManager})
      : super(const SplashState.initial());

  DatabaseService get _dbService => databaseService ?? sl<DatabaseService>();
  BunjiModelManager get _modelManager => modelManager ?? sl<BunjiModelManager>();

  /// Checks if a user profile with a saved name exists AND a valid AI model is installed.
  /// If both are ready, navigates to [Routes.home]; otherwise navigates to [Routes.onboarding].
  Future<void> init() async {
    emit(state.copyWith(ui: state.ui.startLoading(), isLoading: true));

    try {
      // Brief splash display delay so the logo is comfortably visible
      await Future.delayed(const Duration(seconds: 1));

      final profile = await _dbService.getActiveUserProfile();
      final hasSavedName = profile != null && profile.name.trim().isNotEmpty;
      final isModelReady = await _modelManager.isOnboardingCompleted();

      if (hasSavedName && isModelReady) {
        emit(
          state.copyWith(
            ui: state.ui.navigateTo(Routes.home, replace: true),
            isLoading: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            ui: state.ui.navigateTo(Routes.onboarding, replace: true),
            isLoading: false,
          ),
        );
      }
    } catch (e) {
      // Fallback to onboarding if anything goes wrong
      emit(
        state.copyWith(
          ui: state.ui.navigateTo(Routes.onboarding, replace: true),
          isLoading: false,
        ),
      );
    }
  }

  void clearAction() {
    emit(state.copyWith(ui: state.ui.clearAction()));
  }
}
