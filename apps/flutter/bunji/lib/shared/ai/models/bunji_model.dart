import 'package:equatable/equatable.dart';
import 'catalog/model_catalog.dart';

export 'catalog/model_catalog.dart';

/// Semantic tiers for Bunji local models.
enum BunjiModelTier {
  fast,
  balanced,
  reasoning,
  quality;

  static BunjiModelTier fromString(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'balanced':
        return BunjiModelTier.balanced;
      case 'reasoning':
        return BunjiModelTier.reasoning;
      case 'quality':
        return BunjiModelTier.quality;
      case 'fast':
      default:
        return BunjiModelTier.fast;
    }
  }
}

extension BunjiModelTierX on BunjiModelTier {
  String get label {
    switch (this) {
      case BunjiModelTier.fast:
        return 'Fast';
      case BunjiModelTier.balanced:
        return 'Balanced';
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
      case BunjiModelTier.balanced:
        return 'balanced';
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
  final BunjiModelStatus status;
  final String visibility;
  final String name;
  final String provider;
  final BunjiModelTier tier;
  final String description;
  final String? shortDescription;
  final bool recommended;
  final List<String> tags;
  final String parameters;
  final String quantization;
  final String format;
  final String fileName;
  final int fileSizeBytes;
  final String? fileSizeDisplay;
  final int minimumRecommendedRamMb;
  final int contextLength;
  final String architecture;
  final String license;
  final String? licenseUrl;

  final HuggingFaceMetadata huggingFace;
  final ModelIntegrity integrity;
  final ModelRuntime runtime;
  final ModelAvailability availability;
  final bool isActive;

  const BunjiModel({
    required this.id,
    this.status = BunjiModelStatus.active,
    this.visibility = 'public',
    required this.name,
    this.provider = 'Bunji',
    required this.tier,
    required this.description,
    this.shortDescription,
    this.recommended = false,
    this.tags = const [],
    this.parameters = '',
    this.quantization = 'Q4_0',
    this.format = 'GGUF',
    required this.fileName,
    required this.fileSizeBytes,
    this.fileSizeDisplay,
    required this.minimumRecommendedRamMb,
    this.contextLength = 32768,
    this.architecture = 'generic',
    this.license = 'Apache-2.0',
    this.licenseUrl,
    required this.huggingFace,
    required this.integrity,
    this.runtime = const ModelRuntime(name: 'llama.cpp'),
    this.availability = const ModelAvailability(),
    this.isActive = false,
  });

  /// Backward-compatibility constructor supporting legacy field names.
  factory BunjiModel.legacy({
    required String id,
    required String displayName,
    required String description,
    required String repository,
    required String revision,
    required String filename,
    required int parameterCount,
    required int fileSizeBytes,
    required String sha256,
    required BunjiModelTier tier,
    required int minimumRecommendedRamMb,
    bool recommended = false,
    List<String> highlights = const [],
    BunjiModelStatus status = BunjiModelStatus.active,
  }) {
    return BunjiModel(
      id: id,
      status: status,
      name: displayName,
      description: description,
      tier: tier,
      recommended: recommended,
      tags: highlights,
      parameters: '${(parameterCount / 1000000000).toStringAsFixed(1)}B',
      fileName: filename,
      fileSizeBytes: fileSizeBytes,
      minimumRecommendedRamMb: minimumRecommendedRamMb,
      huggingFace: HuggingFaceMetadata(
        repository: repository,
        revision: revision,
        downloadUrl:
            'https://huggingface.co/$repository/resolve/$revision/$filename?download=true',
      ),
      integrity: ModelIntegrity(sha256: sha256),
    );
  }

  /// Strict validation and deserialization from Catalog JSON per Section 20.
  factory BunjiModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final statusStr = json['status'] as String?;
    final name = (json['name'] ?? json['displayName']) as String?;
    final fileName = (json['fileName'] ?? json['filename']) as String?;
    final fileSizeBytes = json['fileSizeBytes'] is num
        ? (json['fileSizeBytes'] as num).toInt()
        : null;

    if (id == null || id.trim().isEmpty) {
      throw const FormatException('Required field "id" is missing or empty');
    }
    if (statusStr == null || statusStr.trim().isEmpty) {
      throw const FormatException('Required field "status" is missing or empty');
    }
    if (name == null || name.trim().isEmpty) {
      throw const FormatException('Required field "name" is missing or empty');
    }
    if (fileName == null || fileName.trim().isEmpty) {
      throw const FormatException('Required field "fileName" is missing or empty');
    }
    if (fileSizeBytes == null || fileSizeBytes <= 0) {
      throw const FormatException('Required field "fileSizeBytes" is missing or non-positive');
    }

    final hfRaw = json['huggingFace'];
    HuggingFaceMetadata hf;
    if (hfRaw is Map<String, dynamic>) {
      hf = HuggingFaceMetadata.fromJson(hfRaw);
    } else if (json['repository'] != null) {
      final repo = json['repository'] as String;
      final rev = json['revision'] as String? ?? 'main';
      hf = HuggingFaceMetadata(
        repository: repo,
        revision: rev,
        downloadUrl: json['downloadUrl'] as String? ??
            'https://huggingface.co/$repo/resolve/$rev/$fileName?download=true',
      );
    } else {
      throw const FormatException('Required field "huggingFace" is missing');
    }

    final integrityRaw = json['integrity'];
    ModelIntegrity integrity;
    if (integrityRaw is Map<String, dynamic>) {
      integrity = ModelIntegrity.fromJson(integrityRaw);
    } else if (json['sha256'] != null) {
      integrity = ModelIntegrity(sha256: json['sha256'] as String);
    } else {
      throw const FormatException('Required field "integrity" is missing');
    }

    final runtimeRaw = json['runtime'];
    ModelRuntime runtime;
    if (runtimeRaw is Map<String, dynamic>) {
      runtime = ModelRuntime.fromJson(runtimeRaw);
    } else {
      runtime = const ModelRuntime(name: 'llama.cpp');
    }

    final availRaw = json['availability'];
    ModelAvailability availability;
    if (availRaw is Map<String, dynamic>) {
      availability = ModelAvailability.fromJson(availRaw);
    } else {
      availability = const ModelAvailability();
    }

    final rawTags = json['tags'] ?? json['highlights'];
    final tags = rawTags is List
        ? rawTags.map((e) => e.toString()).toList()
        : <String>[];

    return BunjiModel(
      id: id,
      status: BunjiModelStatus.fromString(statusStr),
      visibility: json['visibility'] as String? ?? 'public',
      name: name,
      provider: json['provider'] as String? ?? 'Bunji',
      tier: BunjiModelTier.fromString(json['tier'] as String?),
      description: json['description'] as String? ?? '',
      shortDescription: json['shortDescription'] as String?,
      recommended: json['recommended'] as bool? ?? false,
      tags: tags,
      parameters: json['parameters'] as String? ?? '',
      quantization: json['quantization'] as String? ?? 'Q4_0',
      format: json['format'] as String? ?? 'GGUF',
      fileName: fileName,
      fileSizeBytes: fileSizeBytes,
      fileSizeDisplay: json['fileSizeDisplay'] as String?,
      minimumRecommendedRamMb:
          (json['minimumRecommendedRamMb'] as num?)?.toInt() ?? 2048,
      contextLength: (json['contextLength'] as num?)?.toInt() ?? 32768,
      architecture: json['architecture'] as String? ?? 'generic',
      license: json['license'] as String? ?? 'Apache-2.0',
      licenseUrl: json['licenseUrl'] as String?,
      huggingFace: hf,
      integrity: integrity,
      runtime: runtime,
      availability: availability,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status.name,
        'visibility': visibility,
        'name': name,
        'provider': provider,
        'tier': tier.name,
        'description': description,
        'shortDescription': shortDescription,
        'recommended': recommended,
        'tags': tags,
        'parameters': parameters,
        'quantization': quantization,
        'format': format,
        'fileName': fileName,
        'fileSizeBytes': fileSizeBytes,
        'fileSizeDisplay': fileSizeDisplay,
        'minimumRecommendedRamMb': minimumRecommendedRamMb,
        'contextLength': contextLength,
        'architecture': architecture,
        'license': license,
        'licenseUrl': licenseUrl,
        'huggingFace': huggingFace.toJson(),
        'integrity': integrity.toJson(),
        'runtime': runtime.toJson(),
        'availability': availability.toJson(),
      };

  // Backward compatibility getters
  String get displayName => name;
  String get filename => fileName;
  String get sha256 => integrity.sha256;
  String get repository => huggingFace.repository;
  String get revision => huggingFace.revision;
  String get downloadUrl => huggingFace.downloadUrl;
  List<String> get highlights => tags;
  bool get isDeprecated => status == BunjiModelStatus.deprecated;
  bool get isDisabled => status == BunjiModelStatus.disabled;
  bool get isRetired => status == BunjiModelStatus.retired;

  /// Parameter count as integer for comparison algorithms.
  int get parameterCount {
    final clean = parameters.replaceAll(RegExp(r'[^0-9.]'), '');
    final numVal = double.tryParse(clean);
    if (numVal != null) {
      if (parameters.toUpperCase().contains('B')) {
        return (numVal * 1000000000).toInt();
      } else if (parameters.toUpperCase().contains('M')) {
        return (numVal * 1000000).toInt();
      }
    }
    return 1000000000;
  }

  /// Formatted size string, e.g. "429 MB" or "~1.2 GB".
  String get formattedSize {
    if (fileSizeDisplay != null && fileSizeDisplay!.isNotEmpty) {
      return fileSizeDisplay!;
    }
    if (fileSizeBytes >= 1024 * 1024 * 1024) {
      final gb = fileSizeBytes / (1024 * 1024 * 1024);
      return '~${gb.toStringAsFixed(1)} GB';
    }
    final mb = fileSizeBytes / (1024 * 1024);
    return '~${mb.toStringAsFixed(0)} MB';
  }

  @override
  List<Object?> get props => [
        id,
        status,
        visibility,
        name,
        provider,
        tier,
        description,
        shortDescription,
        recommended,
        tags,
        parameters,
        quantization,
        format,
        fileName,
        fileSizeBytes,
        fileSizeDisplay,
        minimumRecommendedRamMb,
        contextLength,
        architecture,
        license,
        licenseUrl,
        huggingFace,
        integrity,
        runtime,
        availability,
        isActive,
      ];

  /// Predefined default Bunji models for offline fallback / compatibility.
  static const List<BunjiModel> availableModels = [
    BunjiModel(
      id: 'qwen3_0_6b_q4_0',
      status: BunjiModelStatus.active,
      name: 'Qwen3 0.6B',
      provider: 'Qwen',
      tier: BunjiModelTier.fast,
      description: 'Small and fast model for everyday conversations and tasks.',
      shortDescription: 'Fast and lightweight for everyday use.',
      recommended: true,
      tags: ['fast', 'mobile', 'everyday', 'low_memory'],
      parameters: '0.6B',
      quantization: 'Q4_0',
      format: 'GGUF',
      fileName: 'Qwen3-0.6B-Q4_0.gguf',
      fileSizeBytes: 429000000,
      fileSizeDisplay: '429 MB',
      minimumRecommendedRamMb: 2048,
      huggingFace: HuggingFaceMetadata(
        repository: 'ggml-org/Qwen3-0.6B-GGUF',
        revision: 'main',
        downloadUrl:
            'https://huggingface.co/ggml-org/Qwen3-0.6B-GGUF/resolve/main/Qwen3-0.6B-Q4_0.gguf?download=true',
      ),
      integrity: ModelIntegrity(
        sha256: 'da2572f16c06133561ce56accaa822216f2391ef4d37fba427801cd6736417d4',
      ),
    ),
    BunjiModel(
      id: 'gemma3_1b_it_q4_k_m',
      status: BunjiModelStatus.active,
      name: 'Gemma 3 1B',
      provider: 'Google',
      tier: BunjiModelTier.balanced,
      description:
          'A stronger general-purpose model with a good balance of quality and mobile performance.',
      shortDescription: 'Balanced quality and performance.',
      recommended: false,
      tags: ['balanced', 'mobile', 'general'],
      parameters: '1.0B',
      quantization: 'Q4_K_M',
      format: 'GGUF',
      fileName: 'gemma-3-1b-it-Q4_K_M.gguf',
      fileSizeBytes: 806000000,
      fileSizeDisplay: '806 MB',
      minimumRecommendedRamMb: 3072,
      huggingFace: HuggingFaceMetadata(
        repository: 'ggml-org/gemma-3-1b-it-GGUF',
        revision: 'main',
        downloadUrl:
            'https://huggingface.co/ggml-org/gemma-3-1b-it-GGUF/resolve/main/gemma-3-1b-it-Q4_K_M.gguf?download=true',
      ),
      integrity: ModelIntegrity(
        sha256: '8ccc5cd1f1b3602548715ae25a66ed73fd5dc68a210412eea643eb20eb75a135',
      ),
    ),
    BunjiModel(
      id: 'qwen3_1_7b_q4_0',
      status: BunjiModelStatus.active,
      name: 'Qwen3 1.7B',
      provider: 'Qwen',
      tier: BunjiModelTier.quality,
      description:
          'The highest-quality option in this mobile-oriented catalog for more demanding conversations and reasoning.',
      shortDescription: 'Higher quality for demanding tasks.',
      recommended: false,
      tags: ['quality', 'reasoning', 'advanced'],
      parameters: '1.7B',
      quantization: 'Q4_0',
      format: 'GGUF',
      fileName: 'Qwen3-1.7B-Q4_0.gguf',
      fileSizeBytes: 1380000000,
      fileSizeDisplay: '1.38 GB',
      minimumRecommendedRamMb: 4096,
      huggingFace: HuggingFaceMetadata(
        repository: 'ggml-org/Qwen3-1.7B-GGUF',
        revision: 'main',
        downloadUrl:
            'https://huggingface.co/ggml-org/Qwen3-1.7B-GGUF/resolve/main/Qwen3-1.7B-Q4_0.gguf?download=true',
      ),
      integrity: ModelIntegrity(
        sha256: '9a930ffc873dfa105021e05d21bb1e63a155de89d6e4be1b8c2c8f619e1a87b5',
      ),
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
