import 'dart:convert';
import 'dart:io';
import 'package:bunji/shared/ai/models/bunji_model.dart';
import 'package:bunji/shared/ai/services/bunji_model_catalog.dart';
import 'package:bunji/shared/ai/services/bunji_model_verifier.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleCatalogJson = '''
  {
    "schemaVersion": 2,
    "catalogVersion": "2026-09-14",
    "catalogStatus": "active",
    "source": {
      "name": "Hugging Face",
      "type": "hugging_face",
      "managedBy": "Bunji model catalog"
    },
    "defaults": {
      "onboardingModelId": "test_fast",
      "recommendedModelId": "test_fast",
      "defaultInferenceFormat": "GGUF",
      "defaultRuntime": "llama.cpp"
    },
    "onboarding": {
      "enabled": true,
      "selectionRequired": true,
      "showDeprecatedModels": false,
      "modelIds": ["test_fast", "test_balanced"]
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
        "id": "test_fast",
        "status": "active",
        "visibility": "public",
        "name": "Test Fast 0.5B",
        "provider": "TestProvider",
        "tier": "fast",
        "description": "Fast model for testing",
        "shortDescription": "Quick and light",
        "recommended": true,
        "tags": ["fast", "test"],
        "parameters": "0.5B",
        "quantization": "Q4_0",
        "format": "GGUF",
        "fileName": "test-fast.gguf",
        "fileSizeBytes": 1024,
        "fileSizeDisplay": "1 KB",
        "minimumRecommendedRamMb": 1024,
        "huggingFace": {
          "repository": "test/fast-model",
          "revision": "main",
          "downloadUrl": "https://example.com/test-fast.gguf"
        },
        "integrity": {
          "sha256": "abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890"
        }
      },
      {
        "id": "test_balanced",
        "status": "deprecated",
        "visibility": "public",
        "name": "Test Balanced 1B",
        "provider": "TestProvider",
        "tier": "balanced",
        "description": "Balanced model for testing",
        "tags": ["balanced", "test"],
        "parameters": "1.0B",
        "quantization": "Q4_K_M",
        "format": "GGUF",
        "fileName": "test-balanced.gguf",
        "fileSizeBytes": 2048,
        "fileSizeDisplay": "2 KB",
        "minimumRecommendedRamMb": 2048,
        "huggingFace": {
          "repository": "test/balanced-model",
          "revision": "main",
          "downloadUrl": "https://example.com/test-balanced.gguf"
        },
        "integrity": {
          "sha256": "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        }
      },
      {
        "id": "test_retired",
        "status": "retired",
        "visibility": "public",
        "name": "Test Retired 2B",
        "provider": "TestProvider",
        "tier": "quality",
        "description": "Retired legacy model",
        "tags": ["retired"],
        "parameters": "2.0B",
        "quantization": "Q4_0",
        "format": "GGUF",
        "fileName": "test-retired.gguf",
        "fileSizeBytes": 4096,
        "fileSizeDisplay": "4 KB",
        "minimumRecommendedRamMb": 4096,
        "huggingFace": {
          "repository": "test/retired-model",
          "revision": "v1.0",
          "downloadUrl": "https://example.com/test-retired.gguf"
        },
        "integrity": {
          "sha256": "9999999999999999999999999999999999999999999999999999999999999999"
        }
      }
    ],
    "managementRules": {
      "active": {
        "showInOnboarding": true,
        "showInModelPicker": true,
        "allowNewInstall": true,
        "allowUpdates": true
      },
      "deprecated": {
        "showInOnboarding": false,
        "showInModelPicker": false,
        "allowNewInstall": false,
        "allowUpdates": false,
        "keepExistingInstallation": true
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

  group('ModelCatalog Parsing & Validation', () {
    test('successfully parses valid schema 2 catalog', () {
      final json = jsonDecode(sampleCatalogJson) as Map<String, dynamic>;
      final catalog = ModelCatalog.fromJson(json);

      expect(catalog.schemaVersion, equals(2));
      expect(catalog.catalogVersion, equals('2026-09-14'));
      expect(catalog.models.length, equals(3));
      expect(catalog.defaults.onboardingModelId, equals('test_fast'));
      expect(catalog.defaults.recommendedModelId, equals('test_fast'));
      expect(catalog.onboarding.modelIds, containsAll(['test_fast', 'test_balanced']));
      expect(catalog.catalogPolicy.verifySha256, isTrue);

      final fast = catalog.models.first;
      expect(fast.id, equals('test_fast'));
      expect(fast.status, equals(BunjiModelStatus.active));
      expect(fast.tier, equals(BunjiModelTier.fast));
      expect(fast.sha256, equals('abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890'));
      expect(fast.downloadUrl, equals('https://example.com/test-fast.gguf'));
    });

    test('rejects catalog with unsupported schemaVersion', () {
      final map = jsonDecode(sampleCatalogJson) as Map<String, dynamic>;
      map['schemaVersion'] = 3;

      expect(() => ModelCatalog.fromJson(map), throwsA(isA<FormatException>()));
    });

    test('gracefully deduplicates catalog with duplicate model IDs', () {
      final map = jsonDecode(sampleCatalogJson) as Map<String, dynamic>;
      final modelsList = (map['models'] as List).toList();
      modelsList.add(modelsList.first); // Duplicate test_fast
      map['models'] = modelsList;

      final catalog = ModelCatalog.fromJson(map);
      expect(catalog.models.length, equals(3));
    });

    test('rejects catalog missing required models list', () {
      final map = jsonDecode(sampleCatalogJson) as Map<String, dynamic>;
      map.remove('models');

      expect(() => ModelCatalog.fromJson(map), throwsA(isA<FormatException>()));
    });

    test('evaluates recommendedModel and onboardingModels shortcuts', () {
      final json = jsonDecode(sampleCatalogJson) as Map<String, dynamic>;
      final catalog = ModelCatalog.fromJson(json);

      expect(catalog.recommendedModel?.id, equals('test_fast'));
      expect(catalog.onboardingModels.first.id, equals('test_fast'));
    });
  });

  group('Model Management Rules & Statuses', () {
    test('active model has unrestricted permissions and no badge', () {
      final json = jsonDecode(sampleCatalogJson) as Map<String, dynamic>;
      final catalog = ModelCatalog.fromJson(json);
      final activeModel = catalog.models.firstWhere((m) => m.id == 'test_fast');

      final rule = catalog.getRule(activeModel.status);
      expect(rule.allowNewInstall, isTrue);
      expect(rule.allowUpdates, isTrue);
      expect(rule.showInOnboarding, isTrue);
      expect(rule.showInModelPicker, isTrue);
      expect(rule.migrationRequired, isFalse);
      expect(activeModel.status, equals(BunjiModelStatus.active));
      expect(activeModel.isDeprecated, isFalse);
    });

    test('deprecated model cannot be newly installed when policy disables it', () {
      final json = jsonDecode(sampleCatalogJson) as Map<String, dynamic>;
      final catalog = ModelCatalog.fromJson(json);
      final deprecatedModel = catalog.models.firstWhere((m) => m.id == 'test_balanced');

      final rule = catalog.getRule(deprecatedModel.status);
      expect(rule.allowNewInstall, isFalse);
      expect(rule.allowUpdates, isFalse);
      expect(rule.keepExistingInstallation, isTrue);
      expect(deprecatedModel.isDeprecated, isTrue);
      expect(deprecatedModel.status.label, equals('Deprecated'));
    });

    test('retired model cannot install or run and requires migration', () {
      final json = jsonDecode(sampleCatalogJson) as Map<String, dynamic>;
      final catalog = ModelCatalog.fromJson(json);
      final retiredModel = catalog.models.firstWhere((m) => m.id == 'test_retired');

      final rule = catalog.getRule(retiredModel.status);
      expect(rule.allowNewInstall, isFalse);
      expect(rule.allowUpdates, isFalse);
      expect(rule.migrationRequired, isTrue);
      expect(retiredModel.isRetired, isTrue);
      expect(retiredModel.status.label, equals('Retired'));
    });
  });

  group('BunjiModelCatalog Remote Fetch & Fallback', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('catalog_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('fetches remote catalog successfully and writes cache with metadata', () async {
      final mockClient = MockClient((request) async {
        return http.Response(sampleCatalogJson, 200, headers: {'content-type': 'application/json'});
      });

      final manager = BunjiModelCatalogManager(
        httpClient: mockClient,
        cacheDirectoryOverride: tempDir,
      );

      final catalog = await manager.load();
      expect(catalog.schemaVersion, equals(2));
      expect(manager.isUsingRemoteCatalog, isTrue);
      expect(manager.cacheMetadata?.source, equals('remote'));
      expect(manager.cacheMetadata?.catalogVersion, equals('2026-09-14'));

      // Check cache files created on disk in tempDir
      final cacheFile = File('${tempDir.path}/bunji_models.json');
      final metaFile = File('${tempDir.path}/metadata.json');
      expect(await cacheFile.exists(), isTrue);
      expect(await metaFile.exists(), isTrue);
    });

    test('falls back to cache when remote fetch fails with HTTP error', () async {
      // 1. Pre-seed cache
      final cacheFile = File('${tempDir.path}/bunji_models.json');
      await cacheFile.writeAsString(sampleCatalogJson);
      final metaFile = File('${tempDir.path}/metadata.json');
      await metaFile.writeAsString(jsonEncode({
        'source': 'cache',
        'catalogVersion': '2026-09-14',
        'downloadedAt': DateTime.now().toIso8601String(),
      }));

      // 2. Setup mock client returning 500
      final failingClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final manager = BunjiModelCatalogManager(
        httpClient: failingClient,
        cacheDirectoryOverride: tempDir,
      );

      final catalog = await manager.load();
      expect(catalog.models.length, equals(3));
      expect(manager.cacheMetadata?.source, equals('cache'));
    });

    test('does not overwrite valid cache when remote returns corrupted JSON', () async {
      // 1. Pre-seed cache with valid catalog
      final cacheFile = File('${tempDir.path}/bunji_models.json');
      await cacheFile.writeAsString(sampleCatalogJson);

      // 2. Mock client returning corrupted content
      final corruptClient = MockClient((request) async {
        return http.Response('{ "brokenJson": [', 200);
      });

      final manager = BunjiModelCatalogManager(
        httpClient: corruptClient,
        cacheDirectoryOverride: tempDir,
      );

      final catalog = await manager.load();
      // Should load from cache
      expect(catalog.models.length, equals(3));
      expect(catalog.models.first.id, equals('test_fast'));
    });

    test('does not overwrite cache when remote returns unsupported schemaVersion 3', () async {
      // 1. Pre-seed cache
      final cacheFile = File('${tempDir.path}/bunji_models.json');
      await cacheFile.writeAsString(sampleCatalogJson);

      // 2. Mock client returning schema 3
      final schema3Json = sampleCatalogJson.replaceFirst('"schemaVersion": 2', '"schemaVersion": 3');
      final futureClient = MockClient((request) async {
        return http.Response(schema3Json, 200);
      });

      final manager = BunjiModelCatalogManager(
        httpClient: futureClient,
        cacheDirectoryOverride: tempDir,
      );

      final catalog = await manager.load();
      // Schema 2 from cache is preserved
      expect(catalog.schemaVersion, equals(2));
    });
  });

  group('SHA-256 Checksum Verification', () {
    late Directory tempDir;
    late BunjiModelVerifier verifier;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('sha_test_');
      verifier = BunjiModelVerifier();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('validates matching SHA-256 and rejects corrupted file', () async {
      final file = File('${tempDir.path}/model.gguf');
      const payload = 'TEST_MODEL_BINARY_PAYLOAD_12345';
      await file.writeAsString(payload);

      final realHash = sha256.convert(utf8.encode(payload)).toString();

      // Matching checksum
      final validResult = await verifier.verifyChecksum(
        file: file,
        expectedHash: realHash,
      );
      expect(validResult.isValid, isTrue);
      expect(validResult.errorMessage, isNull);

      // Mismatched checksum
      final mismatchResult = await verifier.verifyChecksum(
        file: file,
        expectedHash: '0000000000000000000000000000000000000000000000000000000000000000',
      );
      expect(mismatchResult.isValid, isFalse);
      expect(mismatchResult.errorMessage, contains('Checksum mismatch'));

      // Clean up corrupted file
      await verifier.safelyDeleteCorruptedFile(file);
      expect(await file.exists(), isFalse);
    });
  });
}
