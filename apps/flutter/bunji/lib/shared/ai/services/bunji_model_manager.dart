import 'dart:convert';
import 'dart:io';
import 'package:bunji/shared/ai/models/bunji_model.dart';
import 'package:bunji/shared/ai/services/bunji_device_capabilities.dart';
import 'package:bunji/shared/ai/services/bunji_inference_engine.dart';
import 'package:bunji/shared/ai/services/bunji_model_downloader.dart';
import 'package:bunji/shared/ai/services/bunji_model_verifier.dart';
import 'package:bunji/shared/ai/services/bunji_model_repository.dart';
import 'package:bunji/shared/services/database/app_database.dart';
import 'package:bunji/shared/services/database/database_service.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central coordinator contract for model management, downloads, verification,
/// local persistence, and inference lifecycle per Section 28.
abstract interface class BunjiModelManager {
  /// Executes full installation of a model (download -> SHA-256 verify -> load -> persist).
  Future<void> install(BunjiModel model);

  /// Uninstalls an installed model (deletes file from disk and database record).
  Future<void> uninstall(BunjiModel model);

  /// Updates an installed model to the latest revision.
  Future<void> update(BunjiModel model);

  /// Switches the active AI model to [model].
  Future<void> activate(BunjiModel model);

  /// Checks if [modelId] is installed on disk and recorded in the database.
  Future<bool> isInstalled(String modelId);

  /// Retrieves the currently active model entity.
  Future<BunjiModel?> getActiveModel();

  // Helper properties & methods
  BunjiModelDownloader get downloader;
  BunjiModelVerifier get verifier;
  BunjiDeviceCapabilities get deviceCapabilities;
  BunjiInferenceEngine get inferenceEngine;
  BunjiModelRepository? get repository;

  Future<List<BunjiModel>> getAvailableModels();
  Future<BunjiModel> getDefaultModel();
  List<BunjiModel> get availableModels;
  BunjiModel get defaultModel;

  Future<bool> hasValidInstalledModel();
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool value);
  Future<BunjiModel?> detectIncompleteDownload();

  Future<bool> installModel({
    required BunjiModel model,
    bool simulatedDemo = false,
    void Function(String stepMessage)? onStepUpdate,
    void Function(double progress)? onProgress,
  });

  Future<bool> switchActiveModel(String modelId);
  Future<bool> deleteModel(String modelId);
  Future<InstalledModelRecord?> getActiveInstalledModelRecord();
  Future<List<UserAiModel>> getInstalledModels();
  Stream<List<UserAiModel>> watchInstalledModels();
  Stream<UserAiModel?> watchActiveModel();

  factory BunjiModelManager({
    required BunjiModelDownloader downloader,
    required BunjiModelVerifier verifier,
    required BunjiDeviceCapabilities deviceCapabilities,
    required BunjiInferenceEngine inferenceEngine,
    DatabaseService? databaseService,
    BunjiModelRepository? repository,
  }) = BunjiModelManagerImpl;
}

/// Implementation of [BunjiModelManager].
class BunjiModelManagerImpl implements BunjiModelManager {
  @override
  final BunjiModelDownloader downloader;
  @override
  final BunjiModelVerifier verifier;
  @override
  final BunjiDeviceCapabilities deviceCapabilities;
  @override
  final BunjiInferenceEngine inferenceEngine;
  final DatabaseService? databaseService;
  @override
  final BunjiModelRepository? repository;

  static const String _prefKeyInstalledRecord = 'bunji_installed_model_record';
  static const String _prefKeyOnboardingCompleted = 'bunji_onboarding_completed';

  BunjiModelManagerImpl({
    required this.downloader,
    required this.verifier,
    required this.deviceCapabilities,
    required this.inferenceEngine,
    this.databaseService,
    this.repository,
  });

  // Fallback model for offline/uninitialized state
  static final BunjiModel _fallbackModel = BunjiModel(
    id: 'qwen3_0_6b_q4_0',
    status: BunjiModelStatus.active,
    name: 'Qwen3 0.6B',
    provider: 'Qwen',
    tier: BunjiModelTier.fast,
    description: 'Small and fast model for everyday conversations and tasks.',
    shortDescription: 'Fast and lightweight for everyday use.',
    recommended: true,
    tags: const ['fast', 'mobile', 'everyday', 'low_memory'],
    parameters: '0.6B',
    quantization: 'Q4_0',
    fileName: 'Qwen3-0.6B-Q4_0.gguf',
    fileSizeBytes: 429000000,
    fileSizeDisplay: '429 MB',
    minimumRecommendedRamMb: 2048,
    huggingFace: const HuggingFaceMetadata(
      repository: 'ggml-org/Qwen3-0.6B-GGUF',
      revision: 'main',
      downloadUrl:
          'https://huggingface.co/ggml-org/Qwen3-0.6B-GGUF/resolve/main/Qwen3-0.6B-Q4_0.gguf?download=true',
    ),
    integrity: const ModelIntegrity(
      sha256: 'da2572f16c06133561ce56accaa822216f2391ef4d37fba427801cd6736417d4',
    ),
  );

  @override
  List<BunjiModel> get availableModels {
    if (repository?.currentCatalog != null) {
      return repository!.currentCatalog!.models;
    }
    return BunjiModel.availableModels;
  }

  @override
  BunjiModel get defaultModel {
    if (repository?.currentCatalog != null) {
      return repository!.currentCatalog!.recommendedModel ?? _fallbackModel;
    }
    return _fallbackModel;
  }

  @override
  Future<List<BunjiModel>> getAvailableModels() async {
    if (repository != null) {
      return await repository!.getAvailableModels();
    }
    return [_fallbackModel];
  }

  @override
  Future<BunjiModel> getDefaultModel() async {
    if (repository != null) {
      final rec = await repository!.getRecommendedModel();
      if (rec != null) return rec;
    }
    return _fallbackModel;
  }

  @override
  Future<List<UserAiModel>> getInstalledModels() async {
    if (databaseService != null) {
      return await databaseService!.getInstalledAiModels();
    }
    return [];
  }

  @override
  Stream<List<UserAiModel>> watchInstalledModels() {
    if (databaseService != null) {
      return databaseService!.watchInstalledAiModels();
    }
    return Stream.value([]);
  }

  @override
  Future<BunjiModel?> getActiveModel() async {
    if (databaseService != null) {
      final active = await databaseService!.getActiveAiModel();
      if (active != null) {
        BunjiModel? model;
        if (repository != null) {
          model = await repository!.getModel(active.id);
        }
        if (model != null) {
          return BunjiModel(
            id: model.id,
            status: model.status,
            visibility: model.visibility,
            name: model.name,
            provider: model.provider,
            tier: model.tier,
            description: model.description,
            shortDescription: model.shortDescription,
            recommended: model.recommended,
            tags: model.tags,
            parameters: model.parameters,
            quantization: model.quantization,
            format: model.format,
            fileName: model.fileName,
            fileSizeBytes: model.fileSizeBytes,
            fileSizeDisplay: model.fileSizeDisplay,
            minimumRecommendedRamMb: model.minimumRecommendedRamMb,
            contextLength: model.contextLength,
            architecture: model.architecture,
            license: model.license,
            licenseUrl: model.licenseUrl,
            huggingFace: model.huggingFace,
            integrity: model.integrity,
            runtime: model.runtime,
            availability: model.availability,
            isActive: true,
          );
        }
        return BunjiModel(
          id: active.id,
          name: active.displayName,
          tier: BunjiModelTier.fromString(active.tier),
          description: 'Active model',
          fileName: File(active.filePath).uri.pathSegments.last,
          fileSizeBytes: active.fileSizeBytes.toInt(),
          minimumRecommendedRamMb: 2048,
          huggingFace: HuggingFaceMetadata(
            repository: 'local',
            revision: active.version,
            downloadUrl: '',
          ),
          integrity: ModelIntegrity(sha256: active.sha256),
          isActive: true,
        );
      }
    }
    return null;
  }

  @override
  Stream<UserAiModel?> watchActiveModel() {
    if (databaseService != null) {
      return databaseService!.watchActiveAiModel();
    }
    return Stream.value(null);
  }

  @override
  Future<bool> isInstalled(String modelId) async {
    if (databaseService != null) {
      final record = await databaseService!.getAiModel(modelId);
      if (record != null && record.isVerified) {
        final file = File(record.filePath);
        return await file.exists() && await file.length() > 0;
      }
    }
    return false;
  }

  @override
  Future<void> install(BunjiModel model) async {
    // Check management rules for installation policy
    if (repository != null) {
      final rule = repository!.getRuleForStatus(model.status);
      if (!rule.allowNewInstall) {
        final installed = await isInstalled(model.id);
        if (!installed) {
          throw StateError(
            'Cannot install model "${model.name}" because its status is "${model.status.name}".',
          );
        }
      }
    }

    final success = await installModel(model: model);
    if (!success) {
      throw StateError('Failed to install model ${model.name}');
    }
  }

  @override
  Future<void> uninstall(BunjiModel model) async {
    await deleteModel(model.id);
  }

  @override
  Future<void> update(BunjiModel model) async {
    if (repository != null) {
      final rule = repository!.getRuleForStatus(model.status);
      if (!rule.allowUpdates) {
        throw StateError(
          'Model updates are disabled for status "${model.status.name}".',
        );
      }
    }
    await installModel(model: model);
  }

  @override
  Future<void> activate(BunjiModel model) async {
    await switchActiveModel(model.id);
  }

  @override
  Future<bool> switchActiveModel(String modelId) async {
    if (databaseService != null) {
      await databaseService!.setActiveAiModel(modelId);
      final modelRecord = await databaseService!.getAiModel(modelId);
      if (modelRecord != null) {
        final file = File(modelRecord.filePath);
        if (await file.exists()) {
          await inferenceEngine.unloadModel();
          return await inferenceEngine.loadModel(file);
        }
      }
    }
    return false;
  }

  @override
  Future<bool> deleteModel(String modelId) async {
    try {
      final modelRecord = await databaseService?.getAiModel(modelId);
      if (modelRecord != null) {
        final file = File(modelRecord.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await databaseService?.deleteAiModel(modelId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<InstalledModelRecord?> getActiveInstalledModelRecord() async {
    if (databaseService != null) {
      final active = await databaseService!.getActiveAiModel();
      if (active != null) {
        return InstalledModelRecord(
          modelId: active.id,
          modelVersion: active.version,
          modelChecksum: active.sha256,
          filePath: active.filePath,
          installedAt: active.installedAt,
          isVerified: active.isVerified,
          isActive: active.isActive,
        );
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefKeyInstalledRecord);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return InstalledModelRecord.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> hasValidInstalledModel() async {
    if (databaseService != null) {
      final active = await databaseService!.getActiveAiModel();
      if (active != null && active.isVerified) {
        final file = File(active.filePath);
        if (await file.exists() && await file.length() > 0) {
          return true;
        }
      }
    }

    final record = await getActiveInstalledModelRecord();
    if (record == null || !record.isVerified || !record.isActive) {
      return false;
    }
    final file = File(record.filePath);
    return await file.exists() && await file.length() > 0;
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_prefKeyOnboardingCompleted) ?? false;
    if (!completed) return false;
    return await hasValidInstalledModel();
  }

  @override
  Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyOnboardingCompleted, value);
  }

  @override
  Future<BunjiModel?> detectIncompleteDownload() async {
    final models = await getAvailableModels();
    for (final model in models) {
      final partFile = await downloader.getPartModelFile(model);
      if (await partFile.exists() && await partFile.length() > 0) {
        return model;
      }
    }
    return null;
  }

  @override
  Future<bool> installModel({
    required BunjiModel model,
    bool simulatedDemo = false,
    void Function(String stepMessage)? onStepUpdate,
    void Function(double progress)? onProgress,
  }) async {
    onStepUpdate?.call('Preparing Bunji AI...');

    // 1. Download
    final downloadedFile = await downloader.startDownload(
      model: model,
      simulatedDemo: simulatedDemo,
    );
    if (downloadedFile == null || !await downloadedFile.exists()) {
      return false;
    }

    // 2. Verification per Section 19:
    // Download -> SHA-256 -> Compare catalog.integrity.sha256 -> Match? YES -> install / NO -> reject
    // Never install a model when the checksum doesn't match.
    // Show: Model verification failed.
    onStepUpdate?.call('Verifying Bunji AI...\nChecking model integrity...');
    final verification = await verifier.verifyChecksum(
      file: downloadedFile,
      expectedHash: model.sha256,
      onProgress: onProgress,
    );

    final isVerified = simulatedDemo || verification.isValid;
    if (!isVerified) {
      onStepUpdate?.call('Model verification failed.');
      await verifier.safelyDeleteCorruptedFile(downloadedFile);
      return false;
    }

    // 3. Engine Initialization & Model Load
    onStepUpdate?.call('Initializing inference engine...');
    final loaded = await inferenceEngine.loadModel(downloadedFile);
    if (!loaded) {
      return false;
    }

    // 4. Lightweight local health check
    onStepUpdate?.call('Running lightweight health check...');
    final health = await inferenceEngine.runHealthCheck();
    if (!health.isHealthy) {
      return false;
    }

    // 5. Persist installed model metadata in Drift Database
    if (databaseService != null) {
      await databaseService!.saveAiModel(
        UserAiModelsCompanion.insert(
          id: model.id,
          displayName: model.name,
          tier: model.tier.name,
          version: Value(model.revision),
          filePath: downloadedFile.path,
          fileSizeBytes: BigInt.from(model.fileSizeBytes),
          sha256: model.sha256,
          isVerified: const Value(true),
          isActive: const Value(true),
          installedAt: Value(DateTime.now()),
          lastUsedAt: Value(DateTime.now()),
        ),
      );
      await databaseService!.setActiveAiModel(model.id);
    }

    // Also persist SharedPreferences fallback record
    final record = InstalledModelRecord(
      modelId: model.id,
      modelVersion: model.revision,
      modelChecksum: model.sha256,
      filePath: downloadedFile.path,
      installedAt: DateTime.now(),
      isVerified: true,
      isActive: true,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyInstalledRecord, jsonEncode(record.toJson()));

    onStepUpdate?.call('Bunji is ready');
    return true;
  }
}
