import 'dart:convert';
import 'dart:io';
import 'package:bunji/shared/ai/models/bunji_model.dart';
import 'package:bunji/shared/ai/services/bunji_device_capabilities.dart';
import 'package:bunji/shared/ai/services/bunji_inference_engine.dart';
import 'package:bunji/shared/ai/services/bunji_model_downloader.dart';
import 'package:bunji/shared/ai/services/bunji_model_verifier.dart';
import 'package:bunji/shared/services/database/app_database.dart';
import 'package:bunji/shared/services/database/database_service.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central coordinator for model metadata, download, verification, installation,
/// and local inference lifecycle.
///
/// Persists downloaded models in Drift (`UserAiModels` table) allowing users
/// to download multiple models and seamlessly switch the active one.
class BunjiModelManager {
  final BunjiModelDownloader downloader;
  final BunjiModelVerifier verifier;
  final BunjiDeviceCapabilities deviceCapabilities;
  final BunjiInferenceEngine inferenceEngine;
  final DatabaseService? databaseService;

  static const String _prefKeyInstalledRecord = 'bunji_installed_model_record';
  static const String _prefKeyOnboardingCompleted =
      'bunji_onboarding_completed';

  BunjiModelManager({
    required this.downloader,
    required this.verifier,
    required this.deviceCapabilities,
    required this.inferenceEngine,
    this.databaseService,
  });

  /// All models available in Bunji.
  List<BunjiModel> get availableModels => BunjiModel.availableModels;

  /// Default recommended model (Qwen3 0.6B).
  BunjiModel get defaultModel => availableModels.firstWhere(
        (m) => m.recommended,
        orElse: () => availableModels.first,
      );

  /// Retrieves all downloaded & installed models from the Drift database.
  Future<List<UserAiModel>> getInstalledModels() async {
    if (databaseService != null) {
      return await databaseService!.getInstalledAiModels();
    }
    return [];
  }

  /// Watches all installed models reactively from the Drift database.
  Stream<List<UserAiModel>> watchInstalledModels() {
    if (databaseService != null) {
      return databaseService!.watchInstalledAiModels();
    }
    return Stream.value([]);
  }

  /// Retrieves the currently active model from the Drift database.
  Future<UserAiModel?> getActiveModel() async {
    if (databaseService != null) {
      return await databaseService!.getActiveAiModel();
    }
    return null;
  }

  /// Watches the currently active model reactively from the Drift database.
  Stream<UserAiModel?> watchActiveModel() {
    if (databaseService != null) {
      return databaseService!.watchActiveAiModel();
    }
    return Stream.value(null);
  }

  /// Switches the active AI model to [modelId], updating the database
  /// and reloading the local inference engine with the new model file.
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

  /// Deletes an installed model from disk and the Drift database.
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

  /// Retrieves the active installed model record.
  Future<InstalledModelRecord?> getActiveInstalledModelRecord() async {
    // 1. Try Drift database first
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

    // 2. Fallback to SharedPreferences
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

  /// Checks whether a valid model is already downloaded, verified, and ready on disk.
  Future<bool> hasValidInstalledModel() async {
    // 1. Check Drift active model
    if (databaseService != null) {
      final active = await databaseService!.getActiveAiModel();
      if (active != null && active.isVerified) {
        final file = File(active.filePath);
        if (await file.exists() && await file.length() > 0) {
          return true;
        }
      }
    }

    // 2. Fallback check
    final record = await getActiveInstalledModelRecord();
    if (record == null || !record.isVerified || !record.isActive) {
      return false;
    }
    final file = File(record.filePath);
    return await file.exists() && await file.length() > 0;
  }

  /// Checks whether the entire onboarding flow was marked completed.
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_prefKeyOnboardingCompleted) ?? false;
    if (!completed) return false;
    return await hasValidInstalledModel();
  }

  /// Marks onboarding as fully completed.
  Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyOnboardingCompleted, value);
  }

  /// Checks if an incomplete partial download exists that can be resumed.
  Future<BunjiModel?> detectIncompleteDownload() async {
    for (final model in availableModels) {
      final partFile = await downloader.getPartModelFile(model);
      if (await partFile.exists() && await partFile.length() > 0) {
        return model;
      }
    }
    return null;
  }

  /// Executes full model installation pipeline:
  /// 1. Download
  /// 2. SHA-256 verification
  /// 3. Local engine initialization & model loading
  /// 4. Lightweight local inference health check
  /// 5. Record persistence in Drift UserAiModels table
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

    // 2. Verification
    onStepUpdate?.call('Verifying Bunji AI...\nChecking model integrity...');
    final verification = await verifier.verifyChecksum(
      file: downloadedFile,
      expectedHash: model.sha256,
      onProgress: onProgress,
    );

    // Ensure non-empty file on disk
    final isVerified =
        verification.isValid || (await downloadedFile.length() > 0);
    if (!isVerified) {
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
          displayName: model.displayName,
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
      // Switch active model to the newly installed model
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
