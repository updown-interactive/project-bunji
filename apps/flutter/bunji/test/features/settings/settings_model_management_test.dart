import 'dart:async';
import 'package:bunji/features/settings/settings.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSettingsDb implements DatabaseService {
  UserSetting? storedSettings;
  final List<UserAiModel> storedModels = [];

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
      themeMode: settings.themeMode.present
          ? settings.themeMode.value
          : (storedSettings?.themeMode ?? 'system'),
      messageDensity: settings.messageDensity.present
          ? settings.messageDensity.value
          : (storedSettings?.messageDensity ?? 'comfortable'),
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
      localAiOnly: settings.localAiOnly.present
          ? settings.localAiOnly.value
          : (storedSettings?.localAiOnly ?? true),
      allowInternetForDownloads: settings.allowInternetForDownloads.present
          ? settings.allowInternetForDownloads.value
          : (storedSettings?.allowInternetForDownloads ?? true),
      sendDiagnostics: settings.sendDiagnostics.present
          ? settings.sendDiagnostics.value
          : (storedSettings?.sendDiagnostics ?? false),
      saveChatHistory: settings.saveChatHistory.present
          ? settings.saveChatHistory.value
          : (storedSettings?.saveChatHistory ?? true),
      autoDeleteChats: settings.autoDeleteChats.present
          ? settings.autoDeleteChats.value
          : (storedSettings?.autoDeleteChats ?? 'Never'),
      bunjiMemory: settings.bunjiMemory.present
          ? settings.bunjiMemory.value
          : (storedSettings?.bunjiMemory ?? true),
      enterToSend: settings.enterToSend.present
          ? settings.enterToSend.value
          : (storedSettings?.enterToSend ?? true),
      showAiIndicator: settings.showAiIndicator.present
          ? settings.showAiIndicator.value
          : (storedSettings?.showAiIndicator ?? true),
      autoScroll: settings.autoScroll.present
          ? settings.autoScroll.value
          : (storedSettings?.autoScroll ?? true),
      codeSyntaxHighlighting: settings.codeSyntaxHighlighting.present
          ? settings.codeSyntaxHighlighting.value
          : (storedSettings?.codeSyntaxHighlighting ?? true),
      markdownRendering: settings.markdownRendering.present
          ? settings.markdownRendering.value
          : (storedSettings?.markdownRendering ?? true),
      autoNameConversations: settings.autoNameConversations.present
          ? settings.autoNameConversations.value
          : (storedSettings?.autoNameConversations ?? true),
      reduceMotion: settings.reduceMotion.present
          ? settings.reduceMotion.value
          : (storedSettings?.reduceMotion ?? false),
      enableNotifications: settings.enableNotifications.present
          ? settings.enableNotifications.value
          : (storedSettings?.enableNotifications ?? true),
      notifyTaskCompletion: settings.notifyTaskCompletion.present
          ? settings.notifyTaskCompletion.value
          : (storedSettings?.notifyTaskCompletion ?? true),
      notifyDownloads: settings.notifyDownloads.present
          ? settings.notifyDownloads.value
          : (storedSettings?.notifyDownloads ?? true),
      notifyReminders: settings.notifyReminders.present
          ? settings.notifyReminders.value
          : (storedSettings?.notifyReminders ?? true),
      launchBehavior: settings.launchBehavior.present
          ? settings.launchBehavior.value
          : (storedSettings?.launchBehavior ?? 'Open Home'),
      hapticFeedback: settings.hapticFeedback.present
          ? settings.hapticFeedback.value
          : (storedSettings?.hapticFeedback ?? true),
      soundEffects: settings.soundEffects.present
          ? settings.soundEffects.value
          : (storedSettings?.soundEffects ?? false),
      confirmBeforeDeleting: settings.confirmBeforeDeleting.present
          ? settings.confirmBeforeDeleting.value
          : (storedSettings?.confirmBeforeDeleting ?? true),
      appLanguage: settings.appLanguage.present
          ? settings.appLanguage.value
          : (storedSettings?.appLanguage ?? 'en'),
      aiLanguage: settings.aiLanguage.present
          ? settings.aiLanguage.value
          : (storedSettings?.aiLanguage ?? 'auto'),
      developerMode: settings.developerMode.present
          ? settings.developerMode.value
          : (storedSettings?.developerMode ?? false),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> setActiveAiModel(String id) async {
    for (int i = 0; i < storedModels.length; i++) {
      final current = storedModels[i];
      final isTarget = current.id == id;
      storedModels[i] = current.copyWith(
        isActive: isTarget,
      );
    }
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

  @override
  BunjiDeviceCapabilities get deviceCapabilities => _caps;

  @override
  BunjiInferenceEngine get inferenceEngine => engine;

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
    onStepUpdate?.call('Downloading chunks...');
    onProgress?.call(0.5);
    onStepUpdate?.call('Verifying SHA-256...');
    onProgress?.call(1.0);
    return installResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeRepo implements BunjiModelRepository {
  List<BunjiModel> installedList = [];

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
  Future<ModelCatalog> load() async => catalog!;

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

  group('SettingsViewController Model Management Tests', () {
    late FakeSettingsDb db;
    late FakeManager manager;
    late FakeRepo repo;
    late FakeCatalog catalog;
    late SettingsViewController controller;

    final modelA = BunjiModel.legacy(
      id: 'model_a',
      displayName: 'Model A',
      description: 'First model',
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
      displayName: 'Model B',
      description: 'Second model',
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

      controller = SettingsViewController(
        databaseService: db,
        modelManager: manager,
        modelRepository: repo,
        modelCatalog: catalog,
      );
    });

    tearDown(() async {
      await controller.close();
    });

    test('downloadAndInstallModel downloads, verifies, and activates model',
        () async {
      repo.installedList = [modelA];

      await controller.downloadAndInstallModel(modelA);

      expect(manager.installedModel, modelA);
      expect(controller.state.selectedModelId, 'model_a');
      expect(controller.state.downloadingModelId, isNull);
      expect(controller.state.downloadProgress, 1.0);
      expect(controller.state.ui.action, isA<ShowSuccess>());
      final action = controller.state.ui.action as ShowSuccess;
      expect(action.message, contains('installed and activated'));
    });

    test('deleteModel unlinks active model and falls back to remaining installed model',
        () async {
      repo.installedList = [modelA, modelB];
      controller.emit(controller.state.copyWith(
        selectedModelId: 'model_a',
        installedModels: [modelA, modelB],
      ));

      // After modelA is deleted, repo only has modelB
      repo.installedList = [modelB];

      await controller.deleteModel('model_a');

      expect(manager.deletedModelId, 'model_a');
      expect(controller.state.deletingModelId, isNull);
      expect(controller.state.selectedModelId, 'model_b');
      expect(controller.state.installedModels, [modelB]);
      expect(controller.state.ui.action, isA<ShowSuccess>());
      final action = controller.state.ui.action as ShowSuccess;
      expect(action.message, contains('Model deleted and storage freed'));
    });

    test('deleteModel unloads engine and clears selection when last model deleted',
        () async {
      repo.installedList = [modelA];
      controller.emit(controller.state.copyWith(
        selectedModelId: 'model_a',
        installedModels: [modelA],
      ));

      // After modelA is deleted, repo has no models left
      repo.installedList = [];

      await controller.deleteModel('model_a');

      expect(manager.deletedModelId, 'model_a');
      expect(manager.engine.unloaded, true);
      expect(controller.state.selectedModelId, isEmpty);
      expect(controller.state.installedModels, isEmpty);
      expect(db.storedSettings?.activeModelId, isEmpty);
    });

    test('deleteModel handles failure gracefully', () async {
      manager.deleteResult = false;
      controller.emit(controller.state.copyWith(
        selectedModelId: 'model_a',
        installedModels: [modelA],
      ));

      await controller.deleteModel('model_a');

      expect(controller.state.deletingModelId, isNull);
      expect(controller.state.ui.action, isA<ShowError>());
      final action = controller.state.ui.action as ShowError;
      expect(action.message, contains('Could not delete model'));
    });
  });
}
