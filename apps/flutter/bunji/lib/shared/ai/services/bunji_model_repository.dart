import 'dart:io';
import 'package:bunji/shared/services/database/database_service.dart';
import '../models/bunji_model.dart';
import 'bunji_model_catalog.dart';

/// Repository interface hiding catalog parsing, caching, remote fetching,
/// bundled fallback, and status filtering from the UI.
abstract interface class BunjiModelRepository {
  /// All models available for selection and installation on the current platform.
  Future<List<BunjiModel>> getAvailableModels();

  /// Models specifically designated for display in the onboarding sequence.
  Future<List<BunjiModel>> getOnboardingModels();

  /// Retrieves a specific model by ID (from catalog or installed records).
  Future<BunjiModel?> getModel(String id);

  /// Models currently downloaded and installed locally on the device.
  Future<List<BunjiModel>> getInstalledModels();

  /// Default recommended model determined by catalog configuration.
  Future<BunjiModel?> getRecommendedModel();

  /// Refreshes the catalog from remote.
  Future<void> refreshCatalog();

  /// The active catalog instance.
  ModelCatalog? get currentCatalog;

  /// Whether the catalog was retrieved from remote or cache.
  bool get isUsingRemoteCatalog;

  /// Cache metadata for developer diagnostics.
  CatalogCacheMetadata? get cacheMetadata;

  /// Lifecycle rule associated with a status.
  ModelManagementRule getRuleForStatus(BunjiModelStatus status);
}

class BunjiModelRepositoryImpl implements BunjiModelRepository {
  final BunjiModelCatalog catalog;
  final DatabaseService? databaseService;

  BunjiModelRepositoryImpl({
    required this.catalog,
    this.databaseService,
  });

  @override
  ModelCatalog? get currentCatalog => catalog.current;

  @override
  bool get isUsingRemoteCatalog => catalog.isUsingRemoteCatalog;

  @override
  CatalogCacheMetadata? get cacheMetadata => catalog.cacheMetadata;

  Future<ModelCatalog> _ensureCatalog() async {
    if (catalog.current != null) return catalog.current!;
    return await catalog.load();
  }

  @override
  Future<List<BunjiModel>> getAvailableModels() async {
    final cat = await _ensureCatalog();
    final available = <BunjiModel>[];

    for (final model in cat.models) {
      final rule = cat.getRule(model.status);
      final isPlatformSupported =
          model.availability.isAvailableForCurrentPlatform();

      if (rule.showInModelPicker && isPlatformSupported) {
        available.add(model);
      }
    }
    return available;
  }

  @override
  Future<List<BunjiModel>> getOnboardingModels() async {
    final cat = await _ensureCatalog();
    return cat.onboardingModels;
  }

  @override
  Future<BunjiModel?> getModel(String id) async {
    final cat = await _ensureCatalog();
    final fromCatalog = cat.findModel(id);
    if (fromCatalog != null) return fromCatalog;

    // Check installed models in database in case it is a retired or legacy model
    if (databaseService != null) {
      final installedRecord = await databaseService!.getAiModel(id);
      if (installedRecord != null) {
        return BunjiModel(
          id: installedRecord.id,
          status: BunjiModelStatus.retired,
          name: installedRecord.displayName,
          tier: BunjiModelTier.fromString(installedRecord.tier),
          description: 'Previously installed model on device.',
          fileName: File(installedRecord.filePath).uri.pathSegments.last,
          fileSizeBytes: installedRecord.fileSizeBytes.toInt(),
          minimumRecommendedRamMb: 2048,
          huggingFace: HuggingFaceMetadata(
            repository: 'unknown',
            revision: installedRecord.version,
            downloadUrl: '',
          ),
          integrity: ModelIntegrity(sha256: installedRecord.sha256),
        );
      }
    }
    return null;
  }

  @override
  Future<List<BunjiModel>> getInstalledModels() async {
    final cat = await _ensureCatalog();
    if (databaseService == null) return [];

    final installedList = await databaseService!.getInstalledAiModels();
    final result = <BunjiModel>[];

    for (final record in installedList) {
      final catalogMatch = cat.findModel(record.id);
      if (catalogMatch != null) {
        result.add(catalogMatch);
      } else {
        // Fallback representation for legacy / removed models
        result.add(
          BunjiModel(
            id: record.id,
            status: BunjiModelStatus.retired,
            name: record.displayName,
            tier: BunjiModelTier.fromString(record.tier),
            description: 'Installed on device.',
            fileName: File(record.filePath).uri.pathSegments.last,
            fileSizeBytes: record.fileSizeBytes.toInt(),
            minimumRecommendedRamMb: 2048,
            huggingFace: HuggingFaceMetadata(
              repository: 'local',
              revision: record.version,
              downloadUrl: '',
            ),
            integrity: ModelIntegrity(sha256: record.sha256),
          ),
        );
      }
    }
    return result;
  }

  @override
  Future<BunjiModel?> getRecommendedModel() async {
    final cat = await _ensureCatalog();
    return cat.recommendedModel;
  }

  @override
  Future<void> refreshCatalog() async {
    await catalog.refresh(force: true);
  }

  @override
  ModelManagementRule getRuleForStatus(BunjiModelStatus status) {
    if (catalog.current != null) {
      return catalog.current!.getRule(status);
    }
    return status == BunjiModelStatus.active
        ? const ModelManagementRule(
            showInOnboarding: true,
            showInModelPicker: true,
            allowNewInstall: true,
            allowUpdates: true,
          )
        : const ModelManagementRule();
  }
}
