import 'dart:convert';
import 'package:bunji/shared/ai/models/bunji_model.dart';
import 'package:bunji/shared/ai/models/catalog/model_catalog.dart';
import 'package:bunji/shared/ai/services/bunji_model_catalog.dart';
import 'package:bunji/shared/ai/services/bunji_model_repository.dart';
import 'package:bunji/shared/services/database/app_database.dart';
import 'package:bunji/shared/services/database/database_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTestCatalog implements BunjiModelCatalog {
  final ModelCatalog _catalog;
  bool refreshed = false;

  FakeTestCatalog(this._catalog);

  @override
  ModelCatalog? get current => _catalog;

  @override
  bool get isUsingRemoteCatalog => true;

  @override
  CatalogCacheMetadata? get cacheMetadata => CatalogCacheMetadata(
        source: 'remote',
        catalogVersion: _catalog.catalogVersion,
        downloadedAt: DateTime.now(),
      );

  @override
  DateTime? get lastRefreshTime => null;

  @override
  Future<ModelCatalog> load() async => _catalog;

  @override
  Future<ModelCatalog> refresh({bool force = false}) async {
    refreshed = true;
    return _catalog;
  }

  @override
  Future<void> clearCache() async {}

  @override
  Future<ModelCatalog> loadBundledCatalog() async => _catalog;
}

class FakeRepoDatabaseService implements DatabaseService {
  final List<UserAiModel> records = [];

  @override
  AppDatabase get db => throw UnimplementedError();

  @override
  Future<UserProfile?> getActiveUserProfile() async => null;

  @override
  Future<UserProfile?> getUserProfile(String id) async => null;

  @override
  Future<void> saveUserProfile(UserProfilesCompanion profile) async {}

  @override
  Future<int> deleteUserProfile(String id) async => 0;

  @override
  Stream<UserProfile?> watchUserProfile(String id) => Stream.value(null);

  @override
  Future<List<UserAiModel>> getInstalledAiModels() async => records;

  @override
  Stream<List<UserAiModel>> watchInstalledAiModels() => Stream.value(records);

  @override
  Future<UserAiModel?> getActiveAiModel() async => records.isEmpty ? null : records.first;

  @override
  Stream<UserAiModel?> watchActiveAiModel() => Stream.value(records.isEmpty ? null : records.first);

  @override
  Future<UserAiModel?> getAiModel(String id) async {
    try {
      return records.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveAiModel(UserAiModelsCompanion model) async {}

  @override
  Future<void> setActiveAiModel(String id) async {}

  @override
  Future<int> deleteAiModel(String id) async => 0;

  @override
  Future<UserSetting?> getUserSettings([String id = 'default']) async => null;

  @override
  Stream<UserSetting?> watchUserSettings([String id = 'default']) => Stream.value(null);

  @override
  Future<void> saveUserSettings(UserSettingsCompanion settings) async {}

  @override
  Future<ChatSession?> getChatSession(String id) async => null;

  @override
  Stream<List<ChatSession>> watchRecentChatSessions({int limit = 50}) =>
      Stream.value([]);

  @override
  Future<List<ChatSession>> getRecentChatSessions({int limit = 50}) async => [];

  @override
  Future<void> saveChatSession(ChatSessionsCompanion session) async {}

  @override
  Future<void> updateChatSessionTitle(String id, String title) async {}

  @override
  Future<void> updateChatSessionCover(String id, String coverImagePath) async {}

  @override
  Future<void> updateChatSessionPin(String id, bool isPinned) async {}

  @override
  Future<void> deleteChatSession(String id) async {}

  @override
  Future<List<DbChatMessage>> getChatMessages(String chatId) async => [];

  @override
  Stream<List<DbChatMessage>> watchChatMessages(String chatId) =>
      Stream.value([]);

  @override
  Future<void> saveChatMessage(ChatMessagesCompanion message) async {}

  @override
  Future<DbChatMessage?> getLatestChatMessage(String chatId) async => null;

  @override
  Future<DbChatMessage?> getLatestAiChatMessage(String chatId) async => null;

  @override
  Future<void> close() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ModelCatalog testCatalog;
  late FakeTestCatalog fakeCatalog;
  late FakeRepoDatabaseService fakeDb;
  late BunjiModelRepository repository;

  setUp(() {
    const rawJson = '''
    {
      "schemaVersion": 2,
      "catalogVersion": "2026-09-14",
      "defaults": {
        "onboardingModelId": "model_1",
        "recommendedModelId": "model_1"
      },
      "onboarding": {
        "enabled": true,
        "selectionRequired": true,
        "showDeprecatedModels": false,
        "modelIds": ["model_1", "model_2"]
      },
      "catalogPolicy": {
        "allowDownload": true,
        "allowUpdate": true,
        "allowInstallDeprecated": false,
        "allowInstallDisabled": false,
        "allowInstallRetired": false,
        "verifySha256": true,
        "requireKnownRevision": true
      },
      "models": [
        {
          "id": "model_1",
          "status": "active",
          "name": "Model 1 Active",
          "tier": "fast",
          "recommended": true,
          "fileName": "model1.gguf",
          "fileSizeBytes": 500000000,
          "fileSizeDisplay": "500 MB",
          "minimumRecommendedRamMb": 2048,
          "huggingFace": {
            "repository": "test/model-1",
            "revision": "main",
            "downloadUrl": "https://example.com/model-1.gguf"
          },
          "integrity": {
            "sha256": "aaaa"
          }
        },
        {
          "id": "model_2",
          "status": "deprecated",
          "name": "Model 2 Deprecated",
          "tier": "balanced",
          "recommended": false,
          "fileName": "model2.gguf",
          "fileSizeBytes": 800000000,
          "fileSizeDisplay": "800 MB",
          "minimumRecommendedRamMb": 3072,
          "huggingFace": {
            "repository": "test/model-2",
            "revision": "main",
            "downloadUrl": "https://example.com/model-2.gguf"
          },
          "integrity": {
            "sha256": "bbbb"
          }
        },
        {
          "id": "model_3",
          "status": "disabled",
          "name": "Model 3 Disabled",
          "tier": "quality",
          "recommended": false,
          "fileName": "model3.gguf",
          "fileSizeBytes": 1200000000,
          "fileSizeDisplay": "1.2 GB",
          "minimumRecommendedRamMb": 4096,
          "huggingFace": {
            "repository": "test/model-3",
            "revision": "main",
            "downloadUrl": "https://example.com/model-3.gguf"
          },
          "integrity": {
            "sha256": "cccc"
          }
        }
      ],
      "managementRules": {
        "active": {
          "showInOnboarding": true,
          "showInModelPicker": true,
          "allowNewInstall": true,
          "allowUpdates": true,
          "keepExistingInstallation": true,
          "migrationRequired": false
        },
        "deprecated": {
          "showInOnboarding": false,
          "showInModelPicker": true,
          "allowNewInstall": false,
          "allowUpdates": false,
          "keepExistingInstallation": true,
          "migrationRequired": false
        },
        "disabled": {
          "showInOnboarding": false,
          "showInModelPicker": false,
          "allowNewInstall": false,
          "allowUpdates": false,
          "keepExistingInstallation": true,
          "migrationRequired": false
        },
        "retired": {
          "showInOnboarding": false,
          "showInModelPicker": false,
          "allowNewInstall": false,
          "allowUpdates": false,
          "keepExistingInstallation": false,
          "migrationRequired": true
        }
      }
    }
    ''';

    testCatalog = ModelCatalog.fromJson(jsonDecode(rawJson) as Map<String, dynamic>);
    fakeCatalog = FakeTestCatalog(testCatalog);
    fakeDb = FakeRepoDatabaseService();
    repository = BunjiModelRepositoryImpl(
      catalog: fakeCatalog,
      databaseService: fakeDb,
    );
  });

  group('BunjiModelRepository Tests', () {
    test('getAvailableModels returns active and deprecated models visible in picker', () async {
      final available = await repository.getAvailableModels();

      // Active and Deprecated should show in picker; Disabled should not
      final ids = available.map((m) => m.id).toList();
      expect(ids, contains('model_1'));
      expect(ids, contains('model_2'));
      expect(ids, isNot(contains('model_3')));
    });

    test('getOnboardingModels returns only designated onboarding models', () async {
      final onboarding = await repository.getOnboardingModels();
      final ids = onboarding.map((m) => m.id).toList();

      expect(ids, contains('model_1'));
      // model_2 has showInOnboarding: false in its management rule, so it should not be in onboarding
      expect(ids, isNot(contains('model_3')));
    });

    test('getRecommendedModel returns the catalog recommended model', () async {
      final recommended = await repository.getRecommendedModel();

      expect(recommended, isNotNull);
      expect(recommended?.id, equals('model_1'));
      expect(recommended?.displayName, equals('Model 1 Active'));
    });

    test('getModel retrieves by ID from catalog', () async {
      final model = await repository.getModel('model_2');
      expect(model, isNotNull);
      expect(model?.id, equals('model_2'));
      expect(model?.status, equals(BunjiModelStatus.deprecated));
    });

    test('getModel finds retired model from installed database records if absent from catalog', () async {
      fakeDb.records.add(
        UserAiModel(
          id: 'old_legacy_model',
          displayName: 'Old Legacy Model',
          tier: 'fast',
          version: '1.0',
          filePath: '/path/to/legacy.gguf',
          fileSizeBytes: BigInt.from(1000000),
          sha256: 'deadbeef',
          isVerified: true,
          isActive: true,
          installedAt: DateTime.now(),
        ),
      );

      final model = await repository.getModel('old_legacy_model');
      expect(model, isNotNull);
      expect(model?.id, equals('old_legacy_model'));
      expect(model?.status, equals(BunjiModelStatus.retired));
      expect(model?.displayName, equals('Old Legacy Model'));
    });

    test('getInstalledModels marries database records with catalog definitions', () async {
      fakeDb.records.add(
        UserAiModel(
          id: 'model_1',
          displayName: 'Model 1 Active',
          tier: 'fast',
          version: 'main',
          filePath: '/path/to/model1.gguf',
          fileSizeBytes: BigInt.from(500000000),
          sha256: 'aaaa',
          isVerified: true,
          isActive: true,
          installedAt: DateTime.now(),
        ),
      );

      final installed = await repository.getInstalledModels();
      expect(installed.length, equals(1));
      expect(installed.first.id, equals('model_1'));
      expect(installed.first.status, equals(BunjiModelStatus.active));
    });

    test('refreshCatalog delegates to BunjiModelCatalog', () async {
      expect(fakeCatalog.refreshed, isFalse);
      await repository.refreshCatalog();
      expect(fakeCatalog.refreshed, isTrue);
    });

    test('getRuleForStatus returns appropriate lifecycle policies', () {
      final activeRule = repository.getRuleForStatus(BunjiModelStatus.active);
      expect(activeRule.allowNewInstall, isTrue);
      expect(activeRule.allowUpdates, isTrue);
      expect(activeRule.migrationRequired, isFalse);

      final deprecatedRule = repository.getRuleForStatus(BunjiModelStatus.deprecated);
      expect(deprecatedRule.allowNewInstall, isFalse);
      expect(deprecatedRule.allowUpdates, isFalse);
      expect(BunjiModelStatus.deprecated.label, equals('Deprecated'));

      final disabledRule = repository.getRuleForStatus(BunjiModelStatus.disabled);
      expect(disabledRule.allowNewInstall, isFalse);
      expect(disabledRule.showInModelPicker, isFalse);
      expect(BunjiModelStatus.disabled.label, equals('Disabled'));

      final retiredRule = repository.getRuleForStatus(BunjiModelStatus.retired);
      expect(retiredRule.migrationRequired, isTrue);
      expect(retiredRule.allowNewInstall, isFalse);
      expect(BunjiModelStatus.retired.label, equals('Retired'));
    });
  });
}
