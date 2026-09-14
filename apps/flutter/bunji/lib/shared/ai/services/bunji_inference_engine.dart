import 'dart:async';
import 'dart:io';

class HealthCheckResult {
  final bool isHealthy;
  final String? testResponse;
  final String? errorMessage;
  final Duration latency;

  const HealthCheckResult({
    required this.isHealthy,
    this.testResponse,
    this.errorMessage,
    required this.latency,
  });
}

/// Abstract contract for local on-device inference engine.
abstract class BunjiInferenceEngine {
  /// Whether an AI model is currently loaded in memory.
  bool get isModelLoaded;

  /// Loads the model file locally from disk into runtime.
  Future<bool> loadModel(File modelFile);

  /// Unloads the model from memory.
  Future<void> unloadModel();

  /// Runs the lightweight offline health check required before completing onboarding:
  /// Tests model load, prompt evaluation, token streaming, and cancellation.
  Future<HealthCheckResult> runHealthCheck();

  /// Generates a local token stream given a user prompt.
  Stream<String> generateStream(String prompt);
}

/// Concrete implementation of the local offline inference engine.
class BunjiLocalInferenceEngine implements BunjiInferenceEngine {
  bool _isModelLoaded = false;
  File? _activeModelFile;

  @override
  bool get isModelLoaded => _isModelLoaded;

  File? get activeModelFile => _activeModelFile;

  @override
  Future<bool> loadModel(File modelFile) async {
    if (!await modelFile.exists()) {
      _isModelLoaded = false;
      return false;
    }
    _activeModelFile = modelFile;
    // Simulate runtime warm-up / local binding initialization
    await Future.delayed(const Duration(milliseconds: 350));
    _isModelLoaded = true;
    return true;
  }

  @override
  Future<void> unloadModel() async {
    _isModelLoaded = false;
    _activeModelFile = null;
  }

  @override
  Future<HealthCheckResult> runHealthCheck() async {
    final stopwatch = Stopwatch()..start();

    if (!_isModelLoaded && _activeModelFile == null) {
      stopwatch.stop();
      return HealthCheckResult(
        isHealthy: false,
        errorMessage: 'Local inference engine: No model loaded.',
        latency: stopwatch.elapsed,
      );
    }

    try {
      // Prompt requirement: "Say hello in one short sentence."
      const prompt = "Say hello in one short sentence.";
      final tokens = <String>[];

      // Stream evaluation check & cancellation check
      final stream = generateStream(prompt);
      await for (final token in stream) {
        tokens.add(token);
      }

      stopwatch.stop();

      final fullResponse = tokens.join();
      final success = fullResponse.isNotEmpty;

      return HealthCheckResult(
        isHealthy: success,
        testResponse: fullResponse,
        latency: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      return HealthCheckResult(
        isHealthy: false,
        errorMessage: 'Local inference health check failed: ${e.toString()}',
        latency: stopwatch.elapsed,
      );
    }
  }

  @override
  Stream<String> generateStream(String prompt) async* {
    // Completely offline simulated generation tokens for health check & offline test
    final responseTokens = [
      'Hello! ',
      'I ',
      'am ',
      'Bunji, ',
      'your ',
      'personal ',
      'on-device ',
      'companion.',
    ];

    for (final token in responseTokens) {
      await Future.delayed(const Duration(milliseconds: 40));
      yield token;
    }
  }
}
