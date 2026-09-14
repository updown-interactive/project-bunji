import 'dart:io';
import 'package:bunji/shared/ai/services/bunji_inference_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BunjiInferenceEngine Tests', () {
    late BunjiLocalInferenceEngine engine;
    late Directory tempDir;
    late File testModelFile;

    setUp(() async {
      engine = BunjiLocalInferenceEngine();
      tempDir = await Directory.systemTemp.createTemp('engine_test_');
      testModelFile = File('${tempDir.path}/model.bin');
      await testModelFile.writeAsString('MODEL_DATA');
    });

    tearDown(() async {
      await engine.unloadModel();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('health check fails if no model loaded', () async {
      final result = await engine.runHealthCheck();
      expect(result.isHealthy, isFalse);
    });

    test('loads model and passes health check successfully', () async {
      final loaded = await engine.loadModel(testModelFile);
      expect(loaded, isTrue);
      expect(engine.isModelLoaded, isTrue);

      final health = await engine.runHealthCheck();
      expect(health.isHealthy, isTrue);
      expect(health.testResponse, isNotNull);
      expect(health.testResponse, contains('Bunji'));
    });

    test('token stream generates offline response correctly', () async {
      await engine.loadModel(testModelFile);
      final tokens = <String>[];
      await for (final token in engine.generateStream('Hello')) {
        tokens.add(token);
      }
      expect(tokens, isNotEmpty);
      expect(tokens.join(), contains('companion'));
    });
  });
}
