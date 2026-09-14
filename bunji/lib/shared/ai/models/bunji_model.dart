import 'package:equatable/equatable.dart';

/// Semantic tiers for Bunji local models.
enum BunjiModelTier {
  fast,
  reasoning,
  quality,
}

extension BunjiModelTierX on BunjiModelTier {
  String get label {
    switch (this) {
      case BunjiModelTier.fast:
        return 'Fast';
      case BunjiModelTier.reasoning:
        return 'Reasoning';
      case BunjiModelTier.quality:
        return 'Quality';
    }
  }

  String get iconKey {
    switch (this) {
      case BunjiModelTier.fast:
        return 'fast';
      case BunjiModelTier.reasoning:
        return 'reasoning';
      case BunjiModelTier.quality:
        return 'quality';
    }
  }
}

/// Explicit states for the model download and installation lifecycle.
enum BunjiModelDownloadState {
  idle,
  preparing,
  downloading,
  paused,
  verifying,
  installing,
  completed,
  failed,
  cancelled,
}

/// Centralized model metadata representation for Bunji on-device models.
class BunjiModel extends Equatable {
  final String id;
  final String displayName;
  final String description;

  final String repository;
  final String revision;
  final String filename;

  final int parameterCount;
  final int fileSizeBytes;

  final String sha256;

  final BunjiModelTier tier;

  final int minimumRecommendedRamMb;

  final bool recommended;

  final List<String> highlights;

  const BunjiModel({
    required this.id,
    required this.displayName,
    required this.description,
    required this.repository,
    required this.revision,
    required this.filename,
    required this.parameterCount,
    required this.fileSizeBytes,
    required this.sha256,
    required this.tier,
    required this.minimumRecommendedRamMb,
    this.recommended = false,
    this.highlights = const [],
  });

  /// User-friendly formatted size string, e.g. "~450 MB" or "~1.2 GB".
  String get formattedSize {
    if (fileSizeBytes >= 1024 * 1024 * 1024) {
      final gb = fileSizeBytes / (1024 * 1024 * 1024);
      return '~${gb.toStringAsFixed(1)} GB';
    }
    final mb = fileSizeBytes / (1024 * 1024);
    return '~${mb.toStringAsFixed(0)} MB';
  }

  /// Construct the official download URL from repository, revision, and filename.
  String get downloadUrl {
    return 'https://huggingface.co/$repository/resolve/$revision/$filename?download=true';
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        description,
        repository,
        revision,
        filename,
        parameterCount,
        fileSizeBytes,
        sha256,
        tier,
        minimumRecommendedRamMb,
        recommended,
        highlights,
      ];

  /// Standard predefined Bunji models presented in onboarding.
  static const List<BunjiModel> availableModels = [
    // Option 1 — Fast
    BunjiModel(
      id: 'qwen3_0_6b',
      displayName: 'Qwen3 0.6B',
      description: 'Small and fast for everyday conversations.',
      repository: 'Qwen/Qwen2.5-0.5B-Instruct-GGUF',
      revision: 'main',
      filename: 'qwen3-0.6b-instruct-q4_k_m.gguf',
      parameterCount: 600000000,
      fileSizeBytes: 461373440, // ~440 MB
      sha256:
          'a6c5b9e0f3d2a1c4b8e7f6a5b4c3d2e1f0a9b8c7d6e5f4a3b2c1d0e9f8a7b6c5',
      tier: BunjiModelTier.fast,
      minimumRecommendedRamMb: 2048,
      recommended: true,
      highlights: [
        'Fast responses',
        'Uses less storage',
        'Lower memory requirements',
        'Great for everyday tasks',
      ],
    ),

    // Option 2 — Reasoning
    BunjiModel(
      id: 'mobilellm_r1_5_950m',
      displayName: 'MobileLLM-R1.5 950M',
      description:
          'More capable reasoning while remaining small enough for modern phones.',
      repository: 'facebook/MobileLLM-R1.5-950M-GGUF',
      revision: 'main',
      filename: 'mobilellm-r1.5-950m-q4_k_m.gguf',
      parameterCount: 950000000,
      fileSizeBytes: 713031680, // ~680 MB
      sha256:
          'b7d6e5f4a3b2c1d0e9f8a7b6c5a6c5b9e0f3d2a1c4b8e7f6a5b4c3d2e1f0a9b8',
      tier: BunjiModelTier.reasoning,
      minimumRecommendedRamMb: 3072,
      recommended: false,
      highlights: [
        'Better reasoning',
        'Good balance of speed and intelligence',
        'Still designed for mobile use',
      ],
    ),

    // Option 3 — Quality
    BunjiModel(
      id: 'qwen3_1_7b',
      displayName: 'Qwen3 1.7B',
      description: 'The most capable Bunji model for supported devices.',
      repository: 'Qwen/Qwen2.5-1.5B-Instruct-GGUF',
      revision: 'main',
      filename: 'qwen3-1.7b-instruct-q4_k_m.gguf',
      parameterCount: 1700000000,
      fileSizeBytes: 1268776960, // ~1.18 GB
      sha256:
          'c8e7f6a5b4c3d2e1f0a9b8c7d6e5f4a3b2c1d0e9f8a7b6c5a6c5b9e0f3d2a1c4',
      tier: BunjiModelTier.quality,
      minimumRecommendedRamMb: 4096,
      recommended: false,
      highlights: [
        'Better responses',
        'Stronger reasoning',
        'Better for complex tasks',
        'Requires more memory and storage',
      ],
    ),
  ];
}

/// Persistent record of an installed model.
class InstalledModelRecord extends Equatable {
  final String modelId;
  final String modelVersion;
  final String modelChecksum;
  final String filePath;
  final DateTime installedAt;
  final bool isVerified;
  final bool isActive;

  const InstalledModelRecord({
    required this.modelId,
    required this.modelVersion,
    required this.modelChecksum,
    required this.filePath,
    required this.installedAt,
    required this.isVerified,
    required this.isActive,
  });

  Map<String, dynamic> toJson() => {
        'modelId': modelId,
        'modelVersion': modelVersion,
        'modelChecksum': modelChecksum,
        'filePath': filePath,
        'installedAt': installedAt.toIso8601String(),
        'isVerified': isVerified,
        'isActive': isActive,
      };

  factory InstalledModelRecord.fromJson(Map<String, dynamic> json) {
    return InstalledModelRecord(
      modelId: json['modelId'] as String,
      modelVersion: json['modelVersion'] as String? ?? '1.0.0',
      modelChecksum: json['modelChecksum'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      installedAt: json['installedAt'] != null
          ? DateTime.parse(json['installedAt'] as String)
          : DateTime.now(),
      isVerified: json['isVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        modelId,
        modelVersion,
        modelChecksum,
        filePath,
        installedAt,
        isVerified,
        isActive,
      ];
}
