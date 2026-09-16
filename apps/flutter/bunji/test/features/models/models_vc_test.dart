import 'package:bunji/features/models/models.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSettingsDb implements DatabaseService {
  UserSetting? storedSettings;

  @override
  Future<UserSetting?> getUserSettings([String id = 'default']) async =>
      storedSettings;

  @override
  Stream<UserSetting?> watchUserSettings([String id = 'default']) =>
      Stream.value(storedSettings);

  @override
  Future<void> saveUserSettings(UserSettingsCompanion settings) async {
    storedSettings = UserSetting(
      id: settings.id.present ? settings.id.value : 'default',
      themeMode: 'system',
      messageDensity: 'comfortable',
      activeModelId: settings.activeModelId.present
          ? settings.activeModelId.value
          : (storedSettings?.activeModelId ?? ''),
      responseStyle: settings.responseStyle.present
          ? settings.responseStyle.value
          : (storedSettings?.responseStyle ?? 'Balanced'),
      reasoningMode: settings.reasoningMode.present
          ? settings.reasoningMode.value
          : (storedSettings?.reasoningMode ?? false),
      streamingTokens: settings.streamingTokens.present
          ? settings.streamingTokens.value
          : (storedSettings?.streamingTokens ?? true),
      localAiOnly: true,
      allowInternetForDownloads: true,
      sendDiagnostics: false,
      saveChatHistory: true,
      autoDeleteChats: 'Never',
      bunjiMemory: true,
      enterToSend: true,
      showAiIndicator: true,
      autoScroll: true,
      codeSyntaxHighlighting: true,
      markdownRendering: true,
      autoNameConversations: true,
      reduceMotion: false,
      enableNotifications: true,
      notifyTaskCompletion: true,
      notifyDownloads: true,
      notifyReminders: true,
      launchBehavior: 'Open Home',
      hapticFeedback: true,
      soundEffects: false,
      confirmBeforeDeleting: true,
      appLanguage: 'en',
      aiLanguage: 'auto',
      developerMode: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDeviceCaps extends BunjiDeviceCapabilities {
  @override
  Future<bool> hasEnoughStorage(BunjiModel model) async => true;
}

class FakeInferenceEngineService implements BunjiInferenceEngine {
  bool unloaded = false;

  @override
  Future<void> unloadModel() async {
    unloaded = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeManager implements BunjiModelManager {
  final FakeDeviceCaps _caps = FakeDeviceCaps();
  final FakeInferenceEngineService engine = FakeInferenceEngineService();
  bool deleteResult = true;
  bool installResult = true;
  String? deletedModelId;
  BunjiModel? installedModel;
  BunjiModel? activeModel;

  @override
  BunjiDeviceCapabilities get deviceCapabilities => _caps;

  @override
  BunjiInferenceEngine get inferenceEngine => engine;

  @override
  Future<BunjiModel?> getActiveModel() async => activeModel;

  @override
  Future<bool> switchActiveModel(String modelId) async => true;

  @override
  Future<bool> deleteModel(String modelId) async {
    deletedModelId = modelId;
    return deleteResult;
  }

  @override
  Future<bool> installModel({
    required BunjiModel model,
    bool simulatedDemo = false,
    void Function(String stepMessage)? onStepUpdate,
    void Function(double progress)? onProgress,
  }) async {
    installedModel = model;
    onStepUpdate?.call('Downloading...');
    onProgress?.call(0.5);
    onStepUpdate?.call('Verifying...');
    onProgress?.call(1.0);
    return installResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeRepo implements BunjiModelRepository {
  List<BunjiModel> availableList = [];
  List<BunjiModel> installedList = [];

  @override
  Future<List<BunjiModel>> getAvailableModels() async => List.from(availableList);

  @override
  Future<List<BunjiModel>> getInstalledModels() async => List.from(installedList);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCatalog implements BunjiModelCatalog {
  ModelCatalog? catalog;

  @override
  ModelCatalog? get current => catalog;

  @override
  bool get isUsingRemoteCatalog => false;

  @override
  CatalogCacheMetadata? get cacheMetadata => null;

  @override
  DateTime? get lastRefreshTime => null;

  @override
  Future<ModelCatalog> refresh({bool force = false}) async => catalog!;

  @override
  Future<ModelCatalog> loadBundledCatalog() async => catalog!;

  @override
  Future<void> clearCache() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ModelsViewController Tests', () {
    late FakeSettingsDb db;
    late FakeManager manager;
    late FakeRepo repo;
    late FakeCatalog catalog;
    late ModelsViewController controller;

    final modelA = BunjiModel.legacy(
      id: 'model_a',
      displayName: 'Model A Fast',
      description: 'First fast model',
      repository: 'test/model-a',
      revision: 'main',
      filename: 'model-a.gguf',
      parameterCount: 600000000,
      fileSizeBytes: 400000000,
      sha256: 'sha_a',
      tier: BunjiModelTier.fast,
      minimumRecommendedRamMb: 2048,
    );

    final modelB = BunjiModel.legacy(
      id: 'model_b',
      displayName: 'Model B Quality',
      description: 'Second quality model',
      repository: 'test/model-b',
      revision: 'main',
      filename: 'model-b.gguf',
      parameterCount: 1500000000,
      fileSizeBytes: 900000000,
      sha256: 'sha_b',
      tier: BunjiModelTier.quality,
      minimumRecommendedRamMb: 4096,
    );

    setUp(() {
      db = FakeSettingsDb();
      manager = FakeManager();
      repo = FakeRepo();
      catalog = FakeCatalog();

      repo.availableList = [modelA, modelB];
      repo.installedList = [modelA];
      manager.activeModel = modelA;

      controller = ModelsViewController(
        databaseService: db,
        modelManager: manager,
        modelRepository: repo,
        modelCatalog: catalog,
      );
    });

    tearDown(() async {
      await controller.close();
    });

    test('init loads catalog models and sets initial state', () async {
      await controller.init();

      expect(controller.state.availableModels.length, 2);
      expect(controller.state.installedModels.length, 1);
      expect(controller.state.selectedModelId, 'model_a');
      expect(controller.state.activeModel?.id, 'model_a');
    });

    test('downloadAndInstallModel completes and activates model', () async {
      await controller.init();
      repo.installedList = [modelA, modelB];

      await controller.downloadAndInstallModel(modelB);

      expect(manager.installedModel, modelB);
      expect(controller.state.selectedModelId, 'model_b');
      expect(controller.state.downloadingModelId, isNull);
      expect(controller.state.downloadProgress, 1.0);
      expect(controller.state.ui.action, isA<ShowSuccess>());
    });

    test('deleteModel frees storage and switches selection', () async {
      await controller.init();
      controller.emit(controller.state.copyWith(
        selectedModelId: 'model_a',
        installedModels: [modelA, modelB],
      ));

      repo.installedList = [modelB];

      await controller.deleteModel('model_a');

      expect(manager.deletedModelId, 'model_a');
      expect(controller.state.deletingModelId, isNull);
      expect(controller.state.selectedModelId, 'model_b');
      expect(controller.state.installedModels, [modelB]);
      expect(controller.state.ui.action, isA<ShowSuccess>());
    });

    test('tier filtering and search filter models accurately', () async {
      await controller.init();

      // All models
      expect(controller.state.filteredModels.length, 2);

      // Filter by Fast tier
      controller.setTierFilter('fast');
      expect(controller.state.filteredModels.length, 1);
      expect(controller.state.filteredModels.first.id, 'model_a');

      // Filter by Quality tier
      controller.setTierFilter('quality');
      expect(controller.state.filteredModels.length, 1);
      expect(controller.state.filteredModels.first.id, 'model_b');

      // Filter by Installed
      controller.setTierFilter('installed');
      expect(controller.state.filteredModels.length, 1);
      expect(controller.state.filteredModels.first.id, 'model_a');

      // Reset tier and test search query
      controller.setTierFilter('all');
      controller.setSearchQuery('quality');
      expect(controller.state.filteredModels.length, 1);
      expect(controller.state.filteredModels.first.id, 'model_b');
    });

    test('inference configuration toggles update state and persist', () async {
      await controller.updateResponseStyle('Concise');
      expect(controller.state.responseStyle, 'Concise');
      expect(db.storedSettings?.responseStyle, 'Concise');

      await controller.toggleReasoningMode(true);
      expect(controller.state.reasoningMode, true);
      expect(db.storedSettings?.reasoningMode, true);

      await controller.toggleStreamingResponses(false);
      expect(controller.state.streamingResponses, false);
      expect(db.storedSettings?.streamingTokens, false);
    });
  });
}
