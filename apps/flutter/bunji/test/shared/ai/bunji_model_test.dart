import 'package:bunji/shared/ai/models/bunji_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BunjiModel Tests', () {
    test('predefined models list contains exactly three choices', () {
      expect(BunjiModel.availableModels.length, equals(3));
    });

    test('verifies Fast model (Qwen3 0.6B) specifications', () {
      final fastModel = BunjiModel.availableModels
          .firstWhere((m) => m.tier == BunjiModelTier.fast);

      expect(fastModel.displayName, equals('Qwen3 0.6B'));
      expect(fastModel.recommended, isTrue);
      expect(fastModel.formattedSize, contains('MB'));
      expect(fastModel.downloadUrl, contains('Qwen'));
      expect(fastModel.highlights, isNotEmpty);
    });

    test('verifies Balanced model (Gemma 3 1B) specifications', () {
      final balancedModel = BunjiModel.availableModels
          .firstWhere((m) => m.tier == BunjiModelTier.balanced);

      expect(balancedModel.displayName, equals('Gemma 3 1B'));
      expect(balancedModel.recommended, isFalse);
      expect(balancedModel.formattedSize, contains('MB'));
      expect(balancedModel.highlights, isNotEmpty);
    });

    test('verifies Quality model (Qwen3 1.7B) specifications', () {
      final qualityModel = BunjiModel.availableModels
          .firstWhere((m) => m.tier == BunjiModelTier.quality);

      expect(qualityModel.displayName, equals('Qwen3 1.7B'));
      expect(qualityModel.formattedSize, contains('GB'));
      expect(qualityModel.minimumRecommendedRamMb, greaterThanOrEqualTo(4096));
    });

    test('InstalledModelRecord serialization and deserialization', () {
      final record = InstalledModelRecord(
        modelId: 'qwen3_0_6b',
        modelVersion: 'main',
        modelChecksum: 'abcdef123456',
        filePath: '/tmp/test.gguf',
        installedAt: DateTime(2026, 9, 11),
        isVerified: true,
        isActive: true,
      );

      final json = record.toJson();
      final deserialized = InstalledModelRecord.fromJson(json);

      expect(deserialized.modelId, equals('qwen3_0_6b'));
      expect(deserialized.isVerified, isTrue);
      expect(deserialized.isActive, isTrue);
    });
  });
}
