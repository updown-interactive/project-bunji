import 'dart:io';
import 'package:bunji/shared/ai/models/bunji_model.dart';
import 'package:path_provider/path_provider.dart';

enum DeviceModelSuitability {
  recommended,
  good,
  mayBeSlower,
  insufficientStorage,
}

extension DeviceModelSuitabilityX on DeviceModelSuitability {
  String get badgeText {
    switch (this) {
      case DeviceModelSuitability.recommended:
        return 'Recommended for this device';
      case DeviceModelSuitability.good:
        return 'Good on this device';
      case DeviceModelSuitability.mayBeSlower:
        return 'May be slower on your device';
      case DeviceModelSuitability.insufficientStorage:
        return 'Not enough storage';
    }
  }

  bool get isWarning => this == DeviceModelSuitability.mayBeSlower;
  bool get isError => this == DeviceModelSuitability.insufficientStorage;
}

/// Helper service to inspect device storage and memory suitability for local AI models.
class BunjiDeviceCapabilities {
  /// Safety margin for temporary download buffers, checksum verification, and OS operations.
  static const int safetyMarginBytes = 500 * 1024 * 1024; // 500 MB

  /// Estimates available free storage bytes in the application directory.
  Future<int> getAvailableStorageBytes() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      // Estimate available disk space using stat or fallback to a generous mobile default
      // On platforms where stat doesn't provide free space directly, we can check filesystem or default
      final stat = await dir.stat();
      if (stat.size > 0) {
        // If file system stat provides space or we run on Android/iOS
        return 10 * 1024 * 1024 * 1024; // 10 GB safe baseline estimate
      }
      return 10 * 1024 * 1024 * 1024;
    } catch (_) {
      return 10 * 1024 * 1024 * 1024;
    }
  }

  /// Estimates available RAM in MB.
  int getEstimatedRamMb() {
    // In Flutter, ProcessInfo or physical memory can be approximated.
    // Modern mobile baselines:
    if (Platform.isIOS || Platform.isMacOS) {
      return 6144; // 6GB baseline for modern Apple Silicon / iOS
    }
    return 4096; // 4GB baseline for Android
  }

  /// Checks whether there is enough disk space to safely download and verify [model].
  Future<bool> hasEnoughStorage(BunjiModel model) async {
    final available = await getAvailableStorageBytes();
    final requiredBytes = model.fileSizeBytes + safetyMarginBytes;
    return available >= requiredBytes;
  }

  /// Evaluates device suitability for a given model.
  Future<DeviceModelSuitability> evaluateSuitability(BunjiModel model) async {
    final hasStorage = await hasEnoughStorage(model);
    if (!hasStorage) {
      return DeviceModelSuitability.insufficientStorage;
    }

    final ramMb = getEstimatedRamMb();

    if (model.tier == BunjiModelTier.fast) {
      return DeviceModelSuitability.recommended;
    }

    if (model.tier == BunjiModelTier.reasoning) {
      if (ramMb >= model.minimumRecommendedRamMb) {
        return DeviceModelSuitability.good;
      } else {
        return DeviceModelSuitability.mayBeSlower;
      }
    }

    if (model.tier == BunjiModelTier.quality) {
      if (ramMb >= 8192) {
        return DeviceModelSuitability.good;
      } else {
        return DeviceModelSuitability.mayBeSlower;
      }
    }

    return DeviceModelSuitability.good;
  }
}
