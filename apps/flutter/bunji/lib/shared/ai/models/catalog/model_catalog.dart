import 'dart:io';
import 'package:equatable/equatable.dart';
import '../bunji_model.dart';

/// Supported lifecycle statuses for Bunji AI models.
enum BunjiModelStatus {
  active,
  deprecated,
  disabled,
  retired;

  static BunjiModelStatus fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'deprecated':
        return BunjiModelStatus.deprecated;
      case 'disabled':
        return BunjiModelStatus.disabled;
      case 'retired':
        return BunjiModelStatus.retired;
      case 'active':
      default:
        return BunjiModelStatus.active;
    }
  }

  String get label {
    switch (this) {
      case BunjiModelStatus.active:
        return 'Active';
      case BunjiModelStatus.deprecated:
        return 'Deprecated';
      case BunjiModelStatus.disabled:
        return 'Disabled';
      case BunjiModelStatus.retired:
        return 'Retired';
    }
  }
}

/// Hugging Face source repository metadata for a model.
class HuggingFaceMetadata extends Equatable {
  final String repository;
  final String revision;
  final String downloadUrl;

  const HuggingFaceMetadata({
    required this.repository,
    required this.revision,
    required this.downloadUrl,
  });

  factory HuggingFaceMetadata.fromJson(Map<String, dynamic> json) {
    final repo = json['repository'] as String?;
    final rev = json['revision'] as String?;
    final url = json['downloadUrl'] as String?;
    if (repo == null || rev == null || url == null) {
      throw const FormatException('Missing required huggingFace fields');
    }
    return HuggingFaceMetadata(
      repository: repo,
      revision: rev,
      downloadUrl: url,
    );
  }

  Map<String, dynamic> toJson() => {
        'repository': repository,
        'revision': revision,
        'downloadUrl': downloadUrl,
      };

  @override
  List<Object?> get props => [repository, revision, downloadUrl];
}

/// Integrity check data for model files.
class ModelIntegrity extends Equatable {
  final String sha256;

  const ModelIntegrity({required this.sha256});

  factory ModelIntegrity.fromJson(Map<String, dynamic> json) {
    final hash = json['sha256'] as String?;
    if (hash == null || hash.isEmpty) {
      throw const FormatException('Missing required integrity.sha256');
    }
    return ModelIntegrity(sha256: hash.trim().toLowerCase());
  }

  Map<String, dynamic> toJson() => {'sha256': sha256};

  @override
  List<Object?> get props => [sha256];
}

/// Runtime engine requirements for executing the model.
class ModelRuntime extends Equatable {
  final String name;
  final String? minimumVersion;

  const ModelRuntime({
    required this.name,
    this.minimumVersion,
  });

  factory ModelRuntime.fromJson(Map<String, dynamic> json) {
    final n = json['name'] as String?;
    if (n == null || n.isEmpty) {
      throw const FormatException('Missing required runtime.name');
    }
    return ModelRuntime(
      name: n,
      minimumVersion: json['minimumVersion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'minimumVersion': minimumVersion,
      };

  @override
  List<Object?> get props => [name, minimumVersion];
}

/// Platform availability flags.
class ModelAvailability extends Equatable {
  final bool android;
  final bool ios;
  final bool linux;
  final bool macos;
  final bool windows;

  const ModelAvailability({
    this.android = true,
    this.ios = true,
    this.linux = true,
    this.macos = true,
    this.windows = true,
  });

  factory ModelAvailability.fromJson(Map<String, dynamic> json) {
    return ModelAvailability(
      android: json['android'] as bool? ?? true,
      ios: json['ios'] as bool? ?? true,
      linux: json['linux'] as bool? ?? true,
      macos: json['macos'] as bool? ?? true,
      windows: json['windows'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'android': android,
        'ios': ios,
        'linux': linux,
        'macos': macos,
        'windows': windows,
      };

  bool isAvailableForCurrentPlatform() {
    if (Platform.isAndroid) return android;
    if (Platform.isIOS) return ios;
    if (Platform.isMacOS) return macos;
    if (Platform.isLinux) return linux;
    if (Platform.isWindows) return windows;
    return true;
  }

  @override
  List<Object?> get props => [android, ios, linux, macos, windows];
}

/// Information about the catalog source.
class CatalogSource extends Equatable {
  final String name;
  final String type;
  final String managedBy;

  const CatalogSource({
    required this.name,
    required this.type,
    required this.managedBy,
  });

  factory CatalogSource.fromJson(Map<String, dynamic> json) {
    return CatalogSource(
      name: json['name'] as String? ?? 'Hugging Face',
      type: json['type'] as String? ?? 'hugging_face',
      managedBy: json['managedBy'] as String? ?? 'Bunji model catalog',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'managedBy': managedBy,
      };

  @override
  List<Object?> get props => [name, type, managedBy];
}

/// Default model configurations from catalog.
class CatalogDefaults extends Equatable {
  final String onboardingModelId;
  final String recommendedModelId;
  final String defaultInferenceFormat;
  final String defaultRuntime;

  const CatalogDefaults({
    required this.onboardingModelId,
    required this.recommendedModelId,
    required this.defaultInferenceFormat,
    required this.defaultRuntime,
  });

  factory CatalogDefaults.fromJson(Map<String, dynamic> json) {
    final onbId = json['onboardingModelId'] as String?;
    final recId = json['recommendedModelId'] as String?;
    if (onbId == null || recId == null) {
      throw const FormatException('Missing required defaults IDs');
    }
    return CatalogDefaults(
      onboardingModelId: onbId,
      recommendedModelId: recId,
      defaultInferenceFormat:
          json['defaultInferenceFormat'] as String? ?? 'GGUF',
      defaultRuntime: json['defaultRuntime'] as String? ?? 'llama.cpp',
    );
  }

  Map<String, dynamic> toJson() => {
        'onboardingModelId': onboardingModelId,
        'recommendedModelId': recommendedModelId,
        'defaultInferenceFormat': defaultInferenceFormat,
        'defaultRuntime': defaultRuntime,
      };

  @override
  List<Object?> get props => [
        onboardingModelId,
        recommendedModelId,
        defaultInferenceFormat,
        defaultRuntime,
      ];
}

/// Onboarding presentation rules from catalog.
class CatalogOnboarding extends Equatable {
  final bool enabled;
  final bool selectionRequired;
  final bool showDeprecatedModels;
  final List<String> modelIds;

  const CatalogOnboarding({
    required this.enabled,
    required this.selectionRequired,
    required this.showDeprecatedModels,
    required this.modelIds,
  });

  factory CatalogOnboarding.fromJson(Map<String, dynamic> json) {
    final rawIds = json['modelIds'];
    final ids = rawIds is List
        ? rawIds.map((e) => e.toString()).toList()
        : <String>[];
    return CatalogOnboarding(
      enabled: json['enabled'] as bool? ?? true,
      selectionRequired: json['selectionRequired'] as bool? ?? true,
      showDeprecatedModels: json['showDeprecatedModels'] as bool? ?? false,
      modelIds: ids,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'selectionRequired': selectionRequired,
        'showDeprecatedModels': showDeprecatedModels,
        'modelIds': modelIds,
      };

  @override
  List<Object?> get props => [
        enabled,
        selectionRequired,
        showDeprecatedModels,
        modelIds,
      ];
}

/// Catalog security & installation policies.
class CatalogPolicy extends Equatable {
  final bool allowDownload;
  final bool allowUpdate;
  final bool allowInstallDeprecated;
  final bool allowInstallDisabled;
  final bool allowInstallRetired;
  final bool verifySha256;
  final bool requireKnownRevision;

  const CatalogPolicy({
    this.allowDownload = true,
    this.allowUpdate = true,
    this.allowInstallDeprecated = false,
    this.allowInstallDisabled = false,
    this.allowInstallRetired = false,
    this.verifySha256 = true,
    this.requireKnownRevision = true,
  });

  factory CatalogPolicy.fromJson(Map<String, dynamic> json) {
    return CatalogPolicy(
      allowDownload: json['allowDownload'] as bool? ?? true,
      allowUpdate: json['allowUpdate'] as bool? ?? true,
      allowInstallDeprecated:
          json['allowInstallDeprecated'] as bool? ?? false,
      allowInstallDisabled: json['allowInstallDisabled'] as bool? ?? false,
      allowInstallRetired: json['allowInstallRetired'] as bool? ?? false,
      verifySha256: json['verifySha256'] as bool? ?? true,
      requireKnownRevision: json['requireKnownRevision'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'allowDownload': allowDownload,
        'allowUpdate': allowUpdate,
        'allowInstallDeprecated': allowInstallDeprecated,
        'allowInstallDisabled': allowInstallDisabled,
        'allowInstallRetired': allowInstallRetired,
        'verifySha256': verifySha256,
        'requireKnownRevision': requireKnownRevision,
      };

  @override
  List<Object?> get props => [
        allowDownload,
        allowUpdate,
        allowInstallDeprecated,
        allowInstallDisabled,
        allowInstallRetired,
        verifySha256,
        requireKnownRevision,
      ];
}

/// Operational rules for each model lifecycle status.
class ModelManagementRule extends Equatable {
  final bool showInOnboarding;
  final bool showInModelPicker;
  final bool allowNewInstall;
  final bool allowUpdates;
  final bool keepExistingInstallation;
  final bool migrationRequired;

  const ModelManagementRule({
    this.showInOnboarding = false,
    this.showInModelPicker = false,
    this.allowNewInstall = false,
    this.allowUpdates = false,
    this.keepExistingInstallation = true,
    this.migrationRequired = false,
  });

  factory ModelManagementRule.fromJson(Map<String, dynamic> json) {
    return ModelManagementRule(
      showInOnboarding: json['showInOnboarding'] as bool? ?? false,
      showInModelPicker: json['showInModelPicker'] as bool? ?? false,
      allowNewInstall: json['allowNewInstall'] as bool? ?? false,
      allowUpdates: json['allowUpdates'] as bool? ?? false,
      keepExistingInstallation:
          json['keepExistingInstallation'] as bool? ?? true,
      migrationRequired: json['migrationRequired'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'showInOnboarding': showInOnboarding,
        'showInModelPicker': showInModelPicker,
        'allowNewInstall': allowNewInstall,
        'allowUpdates': allowUpdates,
        'keepExistingInstallation': keepExistingInstallation,
        'migrationRequired': migrationRequired,
      };

  @override
  List<Object?> get props => [
        showInOnboarding,
        showInModelPicker,
        allowNewInstall,
        allowUpdates,
        keepExistingInstallation,
        migrationRequired,
      ];
}

/// Metadata stored alongside cached catalogs.
class CatalogCacheMetadata extends Equatable {
  final String catalogVersion;
  final DateTime downloadedAt;
  final String source; // "remote", "cache", "bundled"

  const CatalogCacheMetadata({
    required this.catalogVersion,
    required this.downloadedAt,
    required this.source,
  });

  factory CatalogCacheMetadata.fromJson(Map<String, dynamic> json) {
    return CatalogCacheMetadata(
      catalogVersion: json['catalogVersion'] as String? ?? 'unknown',
      downloadedAt: json['downloadedAt'] != null
          ? DateTime.tryParse(json['downloadedAt'] as String) ?? DateTime.now()
          : (json['fetchedAt'] != null
              ? DateTime.tryParse(json['fetchedAt'] as String) ?? DateTime.now()
              : DateTime.now()),
      source: json['source'] as String? ?? 'cache',
    );
  }

  Map<String, dynamic> toJson() => {
        'catalogVersion': catalogVersion,
        'downloadedAt': downloadedAt.toIso8601String(),
        'source': source,
      };

  @override
  List<Object?> get props => [catalogVersion, downloadedAt, source];
}

/// Complete Bunji AI Model Catalog object.
class ModelCatalog extends Equatable {
  final int schemaVersion;
  final String catalogVersion;
  final String catalogStatus;
  final CatalogSource source;
  final CatalogDefaults defaults;
  final CatalogOnboarding onboarding;
  final CatalogPolicy catalogPolicy;
  final List<BunjiModel> models;
  final Map<String, String> statusDefinitions;
  final Map<String, ModelManagementRule> managementRules;

  const ModelCatalog({
    required this.schemaVersion,
    required this.catalogVersion,
    required this.catalogStatus,
    required this.source,
    required this.defaults,
    required this.onboarding,
    required this.catalogPolicy,
    required this.models,
    required this.statusDefinitions,
    required this.managementRules,
  });

  /// Validates and parses catalog JSON.
  /// Throws [FormatException] if top-level schema validation fails.
  factory ModelCatalog.fromJson(Map<String, dynamic> json) {
    // 1. Validate top-level required fields per section 20
    final schemaVer = json['schemaVersion'];
    if (schemaVer is! int) {
      throw const FormatException('Missing or invalid schemaVersion');
    }
    if (schemaVer != 2) {
      throw FormatException(
        'Unsupported model catalog schema version: $schemaVer. Expected schemaVersion 2.',
      );
    }

    final catVersion = json['catalogVersion'] as String?;
    if (catVersion == null || catVersion.isEmpty) {
      throw const FormatException('Missing or empty catalogVersion');
    }

    final rawModels = json['models'];
    if (rawModels is! List) {
      throw const FormatException('Missing or invalid models list');
    }

    final rawDefaults = json['defaults'];
    if (rawDefaults is! Map<String, dynamic>) {
      throw const FormatException('Missing or invalid defaults block');
    }

    final rawOnboarding = json['onboarding'];
    if (rawOnboarding is! Map<String, dynamic>) {
      throw const FormatException('Missing or invalid onboarding block');
    }

    // 2. Parse nested sections
    final source = json['source'] is Map<String, dynamic>
        ? CatalogSource.fromJson(json['source'] as Map<String, dynamic>)
        : const CatalogSource(
            name: 'Hugging Face',
            type: 'hugging_face',
            managedBy: 'Bunji model catalog',
          );

    final defaults = CatalogDefaults.fromJson(rawDefaults);
    final onboarding = CatalogOnboarding.fromJson(rawOnboarding);
    final catalogPolicy = json['catalogPolicy'] is Map<String, dynamic>
        ? CatalogPolicy.fromJson(json['catalogPolicy'] as Map<String, dynamic>)
        : const CatalogPolicy();

    // 3. Parse and validate each model entry, ignoring malformed entries or duplicates
    final parsedModels = <BunjiModel>[];
    final seenIds = <String>{};

    for (final m in rawModels) {
      if (m is Map<String, dynamic>) {
        try {
          final model = BunjiModel.fromJson(m);
          if (!seenIds.contains(model.id)) {
            seenIds.add(model.id);
            parsedModels.add(model);
          }
        } catch (_) {
          // Reject malformed model entry per section 20 without failing whole catalog
        }
      }
    }

    if (parsedModels.isEmpty) {
      throw const FormatException('No valid models found in catalog');
    }

    // 4. Status definitions & Management rules
    final statusDefs = <String, String>{};
    if (json['statusDefinitions'] is Map) {
      (json['statusDefinitions'] as Map).forEach((k, v) {
        statusDefs[k.toString()] = v.toString();
      });
    }

    final rules = <String, ModelManagementRule>{};
    if (json['managementRules'] is Map) {
      (json['managementRules'] as Map).forEach((k, v) {
        if (v is Map<String, dynamic>) {
          rules[k.toString()] = ModelManagementRule.fromJson(v);
        }
      });
    }

    return ModelCatalog(
      schemaVersion: schemaVer,
      catalogVersion: catVersion,
      catalogStatus: json['catalogStatus'] as String? ?? 'active',
      source: source,
      defaults: defaults,
      onboarding: onboarding,
      catalogPolicy: catalogPolicy,
      models: parsedModels,
      statusDefinitions: statusDefs,
      managementRules: rules,
    );
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'catalogVersion': catalogVersion,
        'catalogStatus': catalogStatus,
        'source': source.toJson(),
        'defaults': defaults.toJson(),
        'onboarding': onboarding.toJson(),
        'catalogPolicy': catalogPolicy.toJson(),
        'models': models.map((m) => m.toJson()).toList(),
        'statusDefinitions': statusDefinitions,
        'managementRules': managementRules.map((k, v) => MapEntry(k, v.toJson())),
      };

  /// Returns models configured for onboarding, preserving onboarding.modelIds order.
  List<BunjiModel> get onboardingModels {
    final modelMap = {for (final m in models) m.id: m};
    final result = <BunjiModel>[];

    for (final id in onboarding.modelIds) {
      final model = modelMap[id];
      if (model != null) {
        final rule = managementRules[model.status.name];
        final showInOnb = rule?.showInOnboarding ?? (model.status == BunjiModelStatus.active);
        if (showInOnb && model.availability.isAvailableForCurrentPlatform()) {
          result.add(model);
        }
      }
    }
    return result;
  }

  /// Returns the recommended model.
  BunjiModel? get recommendedModel {
    for (final m in models) {
      if (m.id == defaults.recommendedModelId) return m;
    }
    for (final m in models) {
      if (m.recommended) return m;
    }
    return models.isNotEmpty ? models.first : null;
  }

  /// Lookup a model by ID.
  BunjiModel? findModel(String id) {
    for (final m in models) {
      if (m.id == id) return m;
    }
    return null;
  }

  /// Resolve the management rule for a status.
  ModelManagementRule getRule(BunjiModelStatus status) {
    return managementRules[status.name] ??
        (status == BunjiModelStatus.active
            ? const ModelManagementRule(
                showInOnboarding: true,
                showInModelPicker: true,
                allowNewInstall: true,
                allowUpdates: true,
              )
            : (status == BunjiModelStatus.retired
                ? const ModelManagementRule(
                    keepExistingInstallation: false,
                    migrationRequired: true,
                  )
                : const ModelManagementRule()));
  }

  @override
  List<Object?> get props => [
        schemaVersion,
        catalogVersion,
        catalogStatus,
        source,
        defaults,
        onboarding,
        catalogPolicy,
        models,
        statusDefinitions,
        managementRules,
      ];
}
