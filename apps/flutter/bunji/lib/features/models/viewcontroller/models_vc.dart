import 'dart:async';
import 'package:bunji/app/di.dart';
import 'package:bunji/features/models/viewcontroller/models_state.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ModelsViewController extends Cubit<ModelsState> {
  final DatabaseService _databaseService;
  final BunjiModelRepository? modelRepository;
  final BunjiModelCatalog? modelCatalog;
  final BunjiModelManager? modelManager;
  StreamSubscription<UserSetting?>? _settingsSubscription;

  ModelsViewController({
    DatabaseService? databaseService,
    this.modelRepository,
    this.modelCatalog,
    this.modelManager,
  })  : _databaseService = databaseService ?? sl<DatabaseService>(),
        super(const ModelsState.initial());

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

  Future<void> init() async {
    await _loadCatalogAndModels();
    try {
      final saved = await _databaseService.getUserSettings();
      if (saved != null) {
        _applySavedSettings(saved);
      }

      await _settingsSubscription?.cancel();
      _settingsSubscription =
          _databaseService.watchUserSettings().listen((setting) {
        if (setting != null) {
          _applySavedSettings(setting);
        }
      });
    } catch (_) {
      // In-memory fallback
    }
  }

  void _applySavedSettings(UserSetting s) {
    emit(state.copyWith(
      selectedModelId: s.activeModelId,
      responseStyle: s.responseStyle,
      reasoningMode: s.reasoningMode,
      streamingResponses: s.streamingTokens,
    ));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query.trim()));
  }

  void setTierFilter(String filter) {
    emit(state.copyWith(selectedTierFilter: filter));
  }

  void clearAction() {
    emit(state.copyWith(ui: state.ui.clearAction()));
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

  /// Downloads and installs a model from catalog.
  Future<void> downloadAndInstallModel(BunjiModel model) async {
    if (state.downloadingModelId != null) {
      emit(state.copyWith(
        ui: state.ui.showError('Another model download is already in progress.'),
      ));
      return;
    }

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

  /// Deletes a downloaded model from local storage.
  Future<void> deleteModel(String modelId) async {
    emit(state.copyWith(deletingModelId: modelId));
    try {
      final success = await _manager.deleteModel(modelId);
      if (success) {
        final installed = await _repository.getInstalledModels();
        String newSelected = state.selectedModelId;

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

  Future<void> clearCatalogCache() async {
    await _catalog.clearCache();
    await _loadCatalogAndModels();
    emit(state.copyWith(
      ui: state.ui.showSuccess('Catalog cache cleared'),
    ));
  }

  Future<void> loadBundledCatalog() async {
    await _catalog.loadBundledCatalog();
    await _loadCatalogAndModels();
    emit(state.copyWith(
      ui: state.ui.showSuccess('Loaded bundled catalog'),
    ));
  }

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
