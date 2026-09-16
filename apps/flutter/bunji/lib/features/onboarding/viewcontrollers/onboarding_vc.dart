import 'dart:async';
import 'package:bunji/app/di.dart';
import 'package:bunji/app/routes.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:drift/drift.dart' show Value;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Semantic onboarding step numbers:
/// 0: Name (Welcome)
/// 1: Profile (Gender & DOB)
/// 2: Model Selection (Choose your AI)
/// 3: Model Download & Verification
/// 4: AI Ready (Completed)
enum BunjiOnboardingStep {
  welcome,
  profile,
  modelSelection,
  modelDownload,
  completed,
}

class OnboardingState extends Equatable {
  final UI ui;
  final bool isLoading;
  final int step; // 0..4

  // Profile data
  final String name;
  final String? gender;
  final DateTime? dob;

  // AI Model data
  final BunjiModel? selectedModel;
  final List<BunjiModel> onboardingModels;
  final String? recommendedModelId;
  final BunjiModelDownloadState downloadState;
  final double downloadProgress; // 0.0 to 1.0
  final int downloadedBytes;
  final int totalBytes;
  final String statusMessage;
  final String? errorMessage;
  final String? storageError;
  final bool isConfirmingDownload;
  final Map<String, DeviceModelSuitability> modelSuitability;

  const OnboardingState({
    required this.ui,
    this.isLoading = false,
    this.step = 0,
    this.name = '',
    this.gender,
    this.dob,
    this.selectedModel,
    this.onboardingModels = const [],
    this.recommendedModelId,
    this.downloadState = BunjiModelDownloadState.idle,
    this.downloadProgress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.statusMessage = '',
    this.errorMessage,
    this.storageError,
    this.isConfirmingDownload = false,
    this.modelSuitability = const {},
  });

  const OnboardingState.initial()
      : ui = const UI(),
        isLoading = false,
        step = 0,
        name = '',
        gender = null,
        dob = null,
        selectedModel = null,
        onboardingModels = const [],
        recommendedModelId = null,
        downloadState = BunjiModelDownloadState.idle,
        downloadProgress = 0.0,
        downloadedBytes = 0,
        totalBytes = 0,
        statusMessage = '',
        errorMessage = null,
        storageError = null,
        isConfirmingDownload = false,
        modelSuitability = const {};

  bool get isNameValid => name.trim().length >= 2;
  bool get canSubmitProfile => isNameValid && gender != null && dob != null;
  bool get isDownloading =>
      downloadState == BunjiModelDownloadState.downloading ||
      downloadState == BunjiModelDownloadState.preparing ||
      downloadState == BunjiModelDownloadState.verifying ||
      downloadState == BunjiModelDownloadState.installing;

  String get formattedDownloaded {
    final mb = downloadedBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} MB';
  }

  String get formattedTotal {
    final mb = totalBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} MB';
  }

  int get downloadPercentage => (downloadProgress * 100).clamp(0, 100).toInt();

  OnboardingState copyWith({
    UI? ui,
    bool? isLoading,
    int? step,
    String? name,
    String? gender,
    DateTime? dob,
    BunjiModel? selectedModel,
    List<BunjiModel>? onboardingModels,
    String? recommendedModelId,
    BunjiModelDownloadState? downloadState,
    double? downloadProgress,
    int? downloadedBytes,
    int? totalBytes,
    String? statusMessage,
    String? errorMessage,
    String? storageError,
    bool? isConfirmingDownload,
    Map<String, DeviceModelSuitability>? modelSuitability,
  }) {
    return OnboardingState(
      ui: ui ?? this.ui,
      isLoading: isLoading ?? this.isLoading,
      step: step ?? this.step,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      selectedModel: selectedModel ?? this.selectedModel,
      onboardingModels: onboardingModels ?? this.onboardingModels,
      recommendedModelId: recommendedModelId ?? this.recommendedModelId,
      downloadState: downloadState ?? this.downloadState,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage,
      storageError: storageError,
      isConfirmingDownload:
          isConfirmingDownload ?? this.isConfirmingDownload,
      modelSuitability: modelSuitability ?? this.modelSuitability,
    );
  }

  @override
  List<Object?> get props => [
        ui,
        isLoading,
        step,
        name,
        gender,
        dob,
        selectedModel,
        onboardingModels,
        recommendedModelId,
        downloadState,
        downloadProgress,
        downloadedBytes,
        totalBytes,
        statusMessage,
        errorMessage,
        storageError,
        isConfirmingDownload,
        modelSuitability,
      ];
}

class OnboardingViewController extends Cubit<OnboardingState> {
  final DatabaseService? databaseService;
  final BunjiModelManager? modelManager;
  final BunjiModelRepository? modelRepository;

  StreamSubscription<DownloadProgressInfo>? _downloadSub;

  OnboardingViewController({
    this.databaseService,
    this.modelManager,
    this.modelRepository,
  }) : super(const OnboardingState.initial());

  DatabaseService get _dbService => databaseService ?? sl<DatabaseService>();
  BunjiModelManager get _modelManager => modelManager ?? sl<BunjiModelManager>();
  BunjiModelRepository get _repository {
    if (modelRepository != null) return modelRepository!;
    if (_modelManager.repository != null) return _modelManager.repository!;
    if (sl.isRegistered<BunjiModelRepository>()) {
      return sl<BunjiModelRepository>();
    }
    return _FallbackOnboardingRepository(_modelManager);
  }

  /// Initial recovery & evaluation on controller load.
  Future<void> init() async {
    // 1. Resolve onboarding models from catalog repository
    final onboardingModels = await _repository.getOnboardingModels();
    final recModel = await _repository.getRecommendedModel() ??
        (onboardingModels.isNotEmpty ? onboardingModels.first : _modelManager.defaultModel);
    final recommendedId = _repository.currentCatalog?.defaults.recommendedModelId ?? recModel.id;

    // 2. Check existing profile in Drift
    final profile = await _dbService.getActiveUserProfile();
    if (profile != null && profile.name.trim().isNotEmpty) {
      emit(
        state.copyWith(
          name: profile.name,
          gender: profile.gender,
          dob: profile.dob,
          step: 2, // Resume directly at AI Model selection!
          onboardingModels: onboardingModels,
          recommendedModelId: recommendedId,
          selectedModel: recModel,
        ),
      );
    } else {
      emit(
        state.copyWith(
          onboardingModels: onboardingModels,
          recommendedModelId: recommendedId,
          selectedModel: recModel,
        ),
      );
    }

    // 3. Evaluate device suitability for each available model
    final suitabilityMap = <String, DeviceModelSuitability>{};
    for (final model in onboardingModels) {
      final suitability =
          await _modelManager.deviceCapabilities.evaluateSuitability(model);
      suitabilityMap[model.id] = suitability;
    }
    emit(state.copyWith(modelSuitability: suitabilityMap));

    // 3. Listen to downloader progress stream
    _downloadSub = _modelManager.downloader.progressStream.listen((info) {
      emit(
        state.copyWith(
          downloadState: info.state,
          downloadedBytes: info.downloadedBytes,
          totalBytes: info.totalBytes,
          downloadProgress: info.progress,
          statusMessage: info.statusMessage,
          errorMessage: info.errorMessage,
        ),
      );
    });
  }

  void updateName(String name) {
    emit(state.copyWith(name: name));
  }

  void updateGender(String gender) {
    emit(state.copyWith(gender: gender));
  }

  void updateDob(DateTime dob) {
    emit(state.copyWith(dob: dob));
  }

  void nextStep() {
    if (state.step == 0) {
      if (!state.isNameValid) {
        emit(
          state.copyWith(
            ui: state.ui.showError(
              'Please enter a valid name (at least 2 characters)',
            ),
          ),
        );
        return;
      }
      emit(state.copyWith(step: 1));
    } else if (state.step == 1) {
      submitProfile();
    } else if (state.step == 2) {
      showDownloadConfirmation();
    }
  }

  void previousStep() {
    if (state.step > 0 && !state.isDownloading) {
      emit(state.copyWith(step: state.step - 1, isConfirmingDownload: false));
    }
  }

  /// Saves the user profile into the Drift local database and advances to AI Model Selection.
  Future<void> submitProfile() async {
    final trimmedName = state.name.trim();
    if (trimmedName.isEmpty) {
      emit(state.copyWith(ui: state.ui.showError('Please enter your name.')));
      return;
    }
    if (state.gender == null || state.gender!.isEmpty) {
      emit(state.copyWith(ui: state.ui.showError('Please select your gender.')));
      return;
    }
    if (state.dob == null) {
      emit(state.copyWith(ui: state.ui.showError('Please choose your date of birth.')));
      return;
    }

    emit(state.copyWith(ui: state.ui.startLoading(), isLoading: true));

    try {
      final existingProfile = await _dbService.getActiveUserProfile();
      final profileId =
          existingProfile?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}';

      await _dbService.saveUserProfile(
        UserProfilesCompanion.insert(
          id: profileId,
          name: trimmedName,
          gender: Value(state.gender),
          dob: Value(state.dob),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // Successfully saved profile! Next step is Model Selection (Step 2)
      emit(
        state.copyWith(
          ui: state.ui.stopLoading(),
          isLoading: false,
          step: 2,
          selectedModel: state.selectedModel ?? _modelManager.defaultModel,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          ui: state.ui.showError('Failed to save profile: ${e.toString()}'),
          isLoading: false,
        ),
      );
    }
  }

  /// Explicitly selects an AI model card.
  void selectModel(BunjiModel model) {
    emit(
      state.copyWith(
        selectedModel: model,
        storageError: null,
        errorMessage: null,
      ),
    );
  }

  /// Opens the download confirmation dialog.
  void showDownloadConfirmation() {
    if (state.selectedModel == null) return;
    emit(state.copyWith(isConfirmingDownload: true));
  }

  /// Dismisses download confirmation dialog.
  void cancelConfirmation() {
    emit(state.copyWith(isConfirmingDownload: false));
  }

  /// Checks storage and starts the model download and installation flow.
  Future<void> startDownloadAndInstall() async {
    final model = state.selectedModel ?? _modelManager.defaultModel;

    // Check available storage first
    final hasStorage =
        await _modelManager.deviceCapabilities.hasEnoughStorage(model);
    if (!hasStorage) {
      emit(
        state.copyWith(
          isConfirmingDownload: false,
          storageError:
              'This model needs approximately ${model.formattedSize} of free space. Free up some storage and try again, or choose a smaller model.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isConfirmingDownload: false,
        storageError: null,
        errorMessage: null,
        step: 3, // Model Download & Verification screen
        downloadState: BunjiModelDownloadState.preparing,
        downloadProgress: 0.0,
        statusMessage: 'Preparing Bunji AI...',
      ),
    );

    try {
      final success = await _modelManager.installModel(
        model: model,
        onStepUpdate: (msg) {
          emit(state.copyWith(statusMessage: msg));
        },
        onProgress: (p) {
          emit(state.copyWith(downloadProgress: p));
        },
      );

      if (success) {
        // Transition to Step 4: AI Ready
        emit(
          state.copyWith(
            step: 4,
            downloadState: BunjiModelDownloadState.completed,
            statusMessage: 'Bunji is ready',
          ),
        );
      } else {
        emit(
          state.copyWith(
            downloadState: BunjiModelDownloadState.failed,
            errorMessage:
                'The AI model could not be verified or installed completely.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          downloadState: BunjiModelDownloadState.failed,
          errorMessage: 'Download failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Pauses the current download.
  Future<void> pauseDownload() async {
    await _modelManager.downloader.pause();
    emit(state.copyWith(downloadState: BunjiModelDownloadState.paused));
  }

  /// Resumes download.
  Future<void> resumeDownload() async {
    if (state.selectedModel != null) {
      startDownloadAndInstall();
    }
  }

  /// Cancels download and returns to Model Selection.
  Future<void> cancelDownload() async {
    await _modelManager.downloader.cancel();
    emit(
      state.copyWith(
        step: 2,
        downloadState: BunjiModelDownloadState.idle,
        downloadProgress: 0.0,
        downloadedBytes: 0,
        errorMessage: null,
      ),
    );
  }

  /// Resets to step 2 for choosing another model after a failure or storage error.
  void chooseAnotherModel() {
    emit(
      state.copyWith(
        step: 2,
        downloadState: BunjiModelDownloadState.idle,
        downloadProgress: 0.0,
        errorMessage: null,
        storageError: null,
      ),
    );
  }

  /// Completes the entire onboarding flow and navigates to [Routes.home].
  Future<void> completeOnboarding() async {
    emit(state.copyWith(isLoading: true));
    await _modelManager.setOnboardingCompleted(true);
    emit(
      state.copyWith(
        isLoading: false,
        ui: state.ui.navigateTo(Routes.home, replace: true),
      ),
    );
  }

  void clearAction() {
    emit(state.copyWith(ui: state.ui.clearAction()));
  }

  @override
  Future<void> close() {
    _downloadSub?.cancel();
    return super.close();
  }
}

/// Fallback repository implementation used when BunjiModelRepository is not in GetIt
/// (e.g., in unit tests initializing OnboardingViewController with a mock manager only).
class _FallbackOnboardingRepository implements BunjiModelRepository {
  final BunjiModelManager _manager;

  _FallbackOnboardingRepository(this._manager);

  @override
  Future<List<BunjiModel>> getAvailableModels() async => _manager.availableModels;

  @override
  Future<List<BunjiModel>> getOnboardingModels() async => _manager.availableModels;

  @override
  Future<BunjiModel?> getModel(String id) async {
    for (final m in _manager.availableModels) {
      if (m.id == id) return m;
    }
    return null;
  }

  @override
  Future<List<BunjiModel>> getInstalledModels() async {
    final installed = <BunjiModel>[];
    for (final m in _manager.availableModels) {
      if (await _manager.isInstalled(m.id)) {
        installed.add(m);
      }
    }
    return installed;
  }

  @override
  Future<BunjiModel?> getRecommendedModel() async => _manager.defaultModel;

  @override
  Future<void> refreshCatalog() async {}

  @override
  ModelCatalog? get currentCatalog => null;

  @override
  bool get isUsingRemoteCatalog => false;

  @override
  CatalogCacheMetadata? get cacheMetadata => null;

  @override
  ModelManagementRule getRuleForStatus(BunjiModelStatus status) =>
      const ModelManagementRule();
}

