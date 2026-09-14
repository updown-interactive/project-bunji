import 'dart:io';
import 'package:bunji/shared/ai/services/bunji_model_verifier.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BunjiModelVerifier Tests', () {
    late BunjiModelVerifier verifier;
    late Directory tempDir;

    setUp(() async {
      verifier = BunjiModelVerifier();
      tempDir = await Directory.systemTemp.createTemp('bunji_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('verifies valid file checksum successfully', () async {
      final file = File('${tempDir.path}/test_model.bin');
      const testContent = 'BUNJI_AI_TEST_PAYLOAD_FOR_HASHING';
      await file.writeAsString(testContent);

      final expectedHash = sha256.convert(testContent.codeUnits).toString();

      final result = await verifier.verifyChecksum(
        file: file,
        expectedHash: expectedHash,
      );

      expect(result.isValid, isTrue);
      expect(result.actualHash, equals(expectedHash));
      expect(result.errorMessage, isNull);
    });

    test('returns invalid when checksum mismatches', () async {
      final file = File('${tempDir.path}/mismatch_model.bin');
      await file.writeAsString('SOME_CORRUPTED_DATA');

      final result = await verifier.verifyChecksum(
        file: file,
        expectedHash: '0000000000000000000000000000000000000000000000000000000000000000',
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
    });

    test('safely deletes corrupted file', () async {
      final file = File('${tempDir.path}/to_delete.bin');
      await file.writeAsString('CORRUPT');
      expect(await file.exists(), isTrue);

      await verifier.safelyDeleteCorruptedFile(file);
      expect(await file.exists(), isFalse);
    });
  });
}
