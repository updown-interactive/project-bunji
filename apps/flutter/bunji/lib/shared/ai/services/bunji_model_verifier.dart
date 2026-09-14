import 'dart:io';
import 'package:crypto/crypto.dart';

class VerificationResult {
  final bool isValid;
  final String actualHash;
  final String expectedHash;
  final String? errorMessage;

  const VerificationResult({
    required this.isValid,
    required this.actualHash,
    required this.expectedHash,
    this.errorMessage,
  });
}

/// Service responsible for SHA-256 checksum verification and file integrity validation.
class BunjiModelVerifier {
  /// Verifies a downloaded file's SHA-256 hash against [expectedHash].
  /// Uses file streaming to compute the hash efficiently without loading the entire
  /// file into RAM at once.
  Future<VerificationResult> verifyChecksum({
    required File file,
    required String expectedHash,
    void Function(double progress)? onProgress,
  }) async {
    if (!await file.exists()) {
      return VerificationResult(
        isValid: false,
        actualHash: '',
        expectedHash: expectedHash,
        errorMessage: 'Model file does not exist on disk.',
      );
    }

    try {
      final fileSize = await file.length();
      if (fileSize == 0) {
        return VerificationResult(
          isValid: false,
          actualHash: '',
          expectedHash: expectedHash,
          errorMessage: 'Model file is empty (0 bytes).',
        );
      }

      int processedBytes = 0;
      Digest? digestResult;
      final output = _DigestSink((d) => digestResult = d);
      final input = sha256.startChunkedConversion(output);

      final stream = file.openRead();
      await for (final chunk in stream) {
        input.add(chunk);
        processedBytes += chunk.length;
        if (onProgress != null && fileSize > 0) {
          onProgress(processedBytes / fileSize);
        }
      }
      input.close();

      final actualDigest = (digestResult?.toString() ?? '').toLowerCase().trim();
      final targetHash = expectedHash.toLowerCase().trim();

      // Note: If expectedHash is a placeholder or during testing, we validate format
      final matches = actualDigest == targetHash;

      return VerificationResult(
        isValid: matches,
        actualHash: actualDigest,
        expectedHash: targetHash,
        errorMessage: matches ? null : 'Checksum mismatch (SHA-256 verification failed)',
      );
    } catch (e) {
      return VerificationResult(
        isValid: false,
        actualHash: '',
        expectedHash: expectedHash,
        errorMessage: 'Verification error: ${e.toString()}',
      );
    }
  }

  /// Safely deletes corrupted or incomplete model file.
  Future<void> safelyDeleteCorruptedFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignored
    }
  }
}

class _DigestSink implements Sink<Digest> {
  final void Function(Digest) onDigest;
  _DigestSink(this.onDigest);

  @override
  void add(Digest data) => onDigest(data);

  @override
  void close() {}
}

