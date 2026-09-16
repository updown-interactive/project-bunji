import 'dart:async';
import 'package:bunji/app/di.dart';
import 'package:bunji/features/settings/viewcontroller/settings_state.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsViewController extends Cubit<SettingsState> {
  final DatabaseService _databaseService;
  final BunjiModelRepository? modelRepository;
  final BunjiModelCatalog? modelCatalog;
  final BunjiModelManager? modelManager;
  StreamSubscription<UserSetting?>? _settingsSubscription;

  SettingsViewController({
    DatabaseService? databaseService,
    this.modelRepository,
    this.modelCatalog,
    this.modelManager,
  })  : _databaseService = databaseService ?? sl<DatabaseService>(),
        super(const SettingsState.initial());

  BunjiModelRepository get _repository =>
      modelRepository ?? sl<BunjiModelRepository>();
  BunjiModelCatalog get _catalog =>
      modelCatalog ?? sl<BunjiModelCatalog>();
  BunjiModelManager get _manager =>
      modelManager ?? sl<BunjiModelManager>();

  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    return super.close();
  }

  /// Initializes settings from the local database and subscribes to changes.
  Future<void> init() async {
    await _loadCatalogAndModels();
    try {
      final saved = await _databaseService.getUserSettings();
      if (saved != null) {
        _applySavedSettings(saved);
      } else {
        // Initialize default settings row in the database
        await _databaseService.saveUserSettings(
          UserSettingsCompanion(
            id: const Value('default'),
            themeMode: const Value('system'),
            messageDensity: const Value('comfortable'),
            activeModelId: const Value('qwen3_0_6b_q4_0'),
            responseStyle: const Value('Balanced'),
            reasoningMode: const Value(false),
            streamingTokens: const Value(true),
            localAiOnly: const Value(true),
            allowInternetForDownloads: const Value(true),
            sendDiagnostics: const Value(false),
            saveChatHistory: const Value(true),
            autoDeleteChats: const Value('Never'),
            bunjiMemory: const Value(true),
            enterToSend: const Value(true),
            showAiIndicator: const Value(true),
            autoScroll: const Value(true),
            codeSyntaxHighlighting: const Value(true),
            markdownRendering: const Value(true),
            autoNameConversations: const Value(true),
            reduceMotion: const Value(false),
            enableNotifications: const Value(true),
            notifyTaskCompletion: const Value(true),
            notifyDownloads: const Value(true),
            notifyReminders: const Value(true),
            launchBehavior: const Value('Open Home'),
            hapticFeedback: const Value(true),
            soundEffects: const Value(false),
            confirmBeforeDeleting: const Value(true),
            appLanguage: const Value('en'),
            aiLanguage: const Value('auto'),
            developerMode: const Value(false),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      // Keep in sync with reactive stream
      await _settingsSubscription?.cancel();
      _settingsSubscription = _databaseService.watchUserSettings().listen((setting) {
        if (setting != null) {
          _applySavedSettings(setting);
        }
      });
    } catch (_) {
      // In-memory fallback if database is unavailable
    }
  }

  void _applySavedSettings(UserSetting s) {
    String formattedTheme = 'System';
    switch (s.themeMode.toLowerCase()) {
      case 'light':
        formattedTheme = 'Light';
        break;
      case 'dark':
        formattedTheme = 'Dark';
        break;
      default:
        formattedTheme = 'System';
        break;
    }

    String formattedDensity = 'Comfortable';
    switch (s.messageDensity.toLowerCase()) {
      case 'compact':
        formattedDensity = 'Compact';
        break;
      case 'spacious':
        formattedDensity = 'Spacious';
        break;
      default:
        formattedDensity = 'Comfortable';
        break;
    }

    emit(state.copyWith(
      themeMode: formattedTheme,
      messageDensity: formattedDensity,
      selectedModelId: s.activeModelId,
      responseStyle: s.responseStyle,
      reasoningMode: s.reasoningMode,
      streamingResponses: s.streamingTokens,
      localAiOnly: s.localAiOnly,
      allowInternetForDownloads: s.allowInternetForDownloads,
      sendDiagnostics: s.sendDiagnostics,
      saveChatHistory: s.saveChatHistory,
      autoDeleteChats: s.autoDeleteChats,
      bunjiMemory: s.bunjiMemory,
      enterToSend: s.enterToSend,
      showAiIndicator: s.showAiIndicator,
      autoScroll: s.autoScroll,
      codeSyntaxHighlighting: s.codeSyntaxHighlighting,
      markdownRendering: s.markdownRendering,
      autoNameConversations: s.autoNameConversations,
      reduceMotion: s.reduceMotion,
      enableNotifications: s.enableNotifications,
      notifyTaskCompletion: s.notifyTaskCompletion,
      notifyDownloads: s.notifyDownloads,
      notifyReminders: s.notifyReminders,
      launchBehavior: s.launchBehavior,
      hapticFeedback: s.hapticFeedback,
      soundEffects: s.soundEffects,
      confirmBeforeDeleting: s.confirmBeforeDeleting,
      developerMode: s.developerMode,
    ));
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query.trim()));
  }

  /// Switches the theme mode ('System', 'Light', 'Dark') and persists to SQLite.
  Future<void> updateThemeMode(String theme) async {
    emit(state.copyWith(themeMode: theme));
    await _persist(UserSettingsCompanion(
      themeMode: Value(theme.toLowerCase()),
    ));
  }

  Future<void> updateMessageDensity(String density) async {
    emit(state.copyWith(messageDensity: density));
    await _persist(UserSettingsCompanion(
      messageDensity: Value(density.toLowerCase()),
    ));
  }

  Future<void> updateSelectedModel(String modelId) async {
    emit(state.copyWith(selectedModelId: modelId));
    await _persist(UserSettingsCompanion(
      activeModelId: Value(modelId),
    ));
    try {
      await _manager.switchActiveModel(modelId);
    } catch (_) {}
  }

  Future<void> updateResponseStyle(String style) async {
    emit(state.copyWith(responseStyle: style));
    await _persist(UserSettingsCompanion(
      responseStyle: Value(style),
    ));
  }

  Future<void> toggleReasoningMode(bool value) async {
    emit(state.copyWith(reasoningMode: value));
    await _persist(UserSettingsCompanion(
      reasoningMode: Value(value),
    ));
  }

  Future<void> toggleStreamingResponses(bool value) async {
    emit(state.copyWith(streamingResponses: value));
    await _persist(UserSettingsCompanion(
      streamingTokens: Value(value),
    ));
  }

  Future<void> toggleLocalAiOnly(bool value) async {
    emit(state.copyWith(localAiOnly: value));
    await _persist(UserSettingsCompanion(
      localAiOnly: Value(value),
    ));
  }

  Future<void> toggleAllowInternetForDownloads(bool value) async {
    emit(state.copyWith(allowInternetForDownloads: value));
    await _persist(UserSettingsCompanion(
      allowInternetForDownloads: Value(value),
    ));
  }

  Future<void> toggleSendDiagnostics(bool value) async {
    emit(state.copyWith(sendDiagnostics: value));
    await _persist(UserSettingsCompanion(
      sendDiagnostics: Value(value),
    ));
  }

  Future<void> toggleSaveChatHistory(bool value) async {
    emit(state.copyWith(saveChatHistory: value));
    await _persist(UserSettingsCompanion(
      saveChatHistory: Value(value),
    ));
  }

  Future<void> updateAutoDeleteChats(String value) async {
    emit(state.copyWith(autoDeleteChats: value));
    await _persist(UserSettingsCompanion(
      autoDeleteChats: Value(value),
    ));
  }

  Future<void> toggleBunjiMemory(bool value) async {
    emit(state.copyWith(bunjiMemory: value));
    await _persist(UserSettingsCompanion(
      bunjiMemory: Value(value),
    ));
  }

  Future<void> toggleEnterToSend(bool value) async {
    emit(state.copyWith(enterToSend: value));
    await _persist(UserSettingsCompanion(
      enterToSend: Value(value),
    ));
  }

  Future<void> toggleShowAiIndicator(bool value) async {
    emit(state.copyWith(showAiIndicator: value));
    await _persist(UserSettingsCompanion(
      showAiIndicator: Value(value),
    ));
  }

  Future<void> toggleAutoScroll(bool value) async {
    emit(state.copyWith(autoScroll: value));
    await _persist(UserSettingsCompanion(
      autoScroll: Value(value),
    ));
  }

  Future<void> toggleCodeSyntaxHighlighting(bool value) async {
    emit(state.copyWith(codeSyntaxHighlighting: value));
    await _persist(UserSettingsCompanion(
      codeSyntaxHighlighting: Value(value),
    ));
  }

  Future<void> toggleMarkdownRendering(bool value) async {
    emit(state.copyWith(markdownRendering: value));
    await _persist(UserSettingsCompanion(
      markdownRendering: Value(value),
    ));
  }

  Future<void> toggleAutoNameConversations(bool value) async {
    emit(state.copyWith(autoNameConversations: value));
    await _persist(UserSettingsCompanion(
      autoNameConversations: Value(value),
    ));
  }

  Future<void> toggleReduceMotion(bool value) async {
    emit(state.copyWith(reduceMotion: value));
    await _persist(UserSettingsCompanion(
      reduceMotion: Value(value),
    ));
  }

  Future<void> toggleEnableNotifications(bool value) async {
    emit(state.copyWith(enableNotifications: value));
    await _persist(UserSettingsCompanion(
      enableNotifications: Value(value),
    ));
  }

  Future<void> toggleNotifyTaskCompletion(bool value) async {
    emit(state.copyWith(notifyTaskCompletion: value));
    await _persist(UserSettingsCompanion(
      notifyTaskCompletion: Value(value),
    ));
  }

  Future<void> toggleNotifyDownloads(bool value) async {
    emit(state.copyWith(notifyDownloads: value));
    await _persist(UserSettingsCompanion(
      notifyDownloads: Value(value),
    ));
  }

  Future<void> toggleNotifyReminders(bool value) async {
    emit(state.copyWith(notifyReminders: value));
    await _persist(UserSettingsCompanion(
      notifyReminders: Value(value),
    ));
  }

  Future<void> updateLaunchBehavior(String value) async {
    emit(state.copyWith(launchBehavior: value));
    await _persist(UserSettingsCompanion(
      launchBehavior: Value(value),
    ));
  }

  Future<void> toggleHapticFeedback(bool value) async {
    emit(state.copyWith(hapticFeedback: value));
    await _persist(UserSettingsCompanion(
      hapticFeedback: Value(value),
    ));
  }

  Future<void> toggleSoundEffects(bool value) async {
    emit(state.copyWith(soundEffects: value));
    await _persist(UserSettingsCompanion(
      soundEffects: Value(value),
    ));
  }

  Future<void> toggleConfirmBeforeDeleting(bool value) async {
    emit(state.copyWith(confirmBeforeDeleting: value));
    await _persist(UserSettingsCompanion(
      confirmBeforeDeleting: Value(value),
    ));
  }

  Future<void> toggleDeveloperMode(bool value) async {
    emit(state.copyWith(developerMode: value));
    await _persist(UserSettingsCompanion(
      developerMode: Value(value),
    ));
  }

  Future<void> _loadCatalogAndModels() async {
    try {
      final available = await _repository.getAvailableModels();
      final installed = await _repository.getInstalledModels();
      final active = await _manager.getActiveModel();

      String source = 'Bundled';
      if (_catalog.isUsingRemoteCatalog) {
        source = _catalog.cacheMetadata?.source == 'remote' ? 'Remote' : 'Cache';
      }

      emit(state.copyWith(
        availableModels: available,
        installedModels: installed,
        selectedModelId: active?.id ?? state.selectedModelId,
        catalogSource: source,
        catalogVersion: _catalog.current?.catalogVersion ?? '2026-09-14',
        catalogSchemaVersion: _catalog.current?.schemaVersion ?? 2,
        catalogStatus: _catalog.current != null ? 'Valid' : 'Uninitialized',
        catalogLastRefresh: _catalog.lastRefreshTime,
      ));
    } catch (e) {
      emit(state.copyWith(catalogError: e.toString()));
    }
  }

  /// Refreshes the remote catalog on demand (Section 32).
  Future<void> refreshCatalog() async {
    emit(state.copyWith(isRefreshingCatalog: true, catalogError: null));
    try {
      await _catalog.refresh(force: true);
      await _loadCatalogAndModels();
      emit(state.copyWith(
        isRefreshingCatalog: false,
        ui: state.ui.showSuccess('Catalog refreshed successfully'),
      ));
    } catch (e) {
      emit(state.copyWith(
        isRefreshingCatalog: false,
        catalogError: e.toString(),
        ui: state.ui.showError('Refresh failed: ${e.toString()}'),
      ));
    }
  }

  /// Clears local catalog cache (Section 32).
  Future<void> clearCatalogCache() async {
    await _catalog.clearCache();
    await _loadCatalogAndModels();
    emit(state.copyWith(
      ui: state.ui.showSuccess('Catalog cache cleared'),
    ));
  }

  /// Forces reloading bundled catalog from assets (Section 32).
  Future<void> loadBundledCatalog() async {
    await _catalog.loadBundledCatalog();
    await _loadCatalogAndModels();
    emit(state.copyWith(
      ui: state.ui.showSuccess('Loaded bundled catalog'),
    ));
  }

  /// Validates the current in-memory catalog schema and integrity (Section 32).
  Future<void> validateCatalog() async {
    final cat = _catalog.current;
    if (cat != null && cat.schemaVersion == 2 && cat.models.isNotEmpty) {
      emit(state.copyWith(
        catalogStatus: 'Valid (${cat.models.length} models verified)',
        ui: state.ui.showSuccess('Catalog verified: Schema 2 with ${cat.models.length} models'),
      ));
    } else {
      emit(state.copyWith(
        catalogStatus: 'Invalid catalog schema',
        ui: state.ui.showError('Catalog validation failed!'),
      ));
    }
  }

  /// Downloads and installs a model from the remote catalog.
  Future<void> downloadAndInstallModel(BunjiModel model) async {
    // Check if another download is in progress
    if (state.downloadingModelId != null) {
      emit(state.copyWith(
        ui: state.ui.showError('Another model download is already in progress.'),
      ));
      return;
    }

    // Check storage availability
    final hasStorage =
        await _manager.deviceCapabilities.hasEnoughStorage(model);
    if (!hasStorage) {
      emit(state.copyWith(
        ui: state.ui.showError(
          'Insufficient storage. This model requires ${model.formattedSize}.',
        ),
      ));
      return;
    }

    emit(state.copyWith(
      downloadingModelId: model.id,
      downloadProgress: 0.0,
      downloadStatusMessage: 'Preparing download...',
    ));

    try {
      final success = await _manager.installModel(
        model: model,
        onStepUpdate: (msg) {
          emit(state.copyWith(downloadStatusMessage: msg));
        },
        onProgress: (p) {
          emit(state.copyWith(downloadProgress: p));
        },
      );

      if (success) {
        await _loadCatalogAndModels();
        await updateSelectedModel(model.id);
        emit(state.copyWith(
          clearDownloadingModelId: true,
          clearDownloadStatus: true,
          downloadProgress: 1.0,
          ui: state.ui.showSuccess('Model "${model.name}" installed and activated!'),
        ));
      } else {
        emit(state.copyWith(
          clearDownloadingModelId: true,
          clearDownloadStatus: true,
          ui: state.ui.showError('Failed to verify or install "${model.name}".'),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        clearDownloadingModelId: true,
        clearDownloadStatus: true,
        ui: state.ui.showError('Download error: ${e.toString()}'),
      ));
    }
  }

  /// Deletes a downloaded model from local storage and database.
  Future<void> deleteModel(String modelId) async {
    emit(state.copyWith(deletingModelId: modelId));
    try {
      final success = await _manager.deleteModel(modelId);
      if (success) {
        // Refresh models list
        final installed = await _repository.getInstalledModels();
        String newSelected = state.selectedModelId;

        // If the deleted model was the currently selected model
        if (state.selectedModelId == modelId) {
          if (installed.isNotEmpty) {
            newSelected = installed.first.id;
            await updateSelectedModel(newSelected);
          } else {
            newSelected = '';
            await _persist(const UserSettingsCompanion(
              activeModelId: Value(''),
            ));
            await _manager.inferenceEngine.unloadModel();
          }
        }

        emit(state.copyWith(
          installedModels: installed,
          selectedModelId: newSelected,
          clearDeletingModelId: true,
          ui: state.ui.showSuccess('Model deleted and storage freed.'),
        ));
      } else {
        emit(state.copyWith(
          clearDeletingModelId: true,
          ui: state.ui.showError('Could not delete model.'),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        clearDeletingModelId: true,
        ui: state.ui.showError('Delete error: ${e.toString()}'),
      ));
    }
  }

  Future<void> _persist(UserSettingsCompanion update) async {
    try {
      final companion = update.copyWith(
        id: const Value('default'),
        updatedAt: Value(DateTime.now()),
      );
      await _databaseService.saveUserSettings(companion);
    } catch (_) {}
  }
}
