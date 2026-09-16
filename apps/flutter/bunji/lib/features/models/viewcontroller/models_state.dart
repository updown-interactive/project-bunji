import 'package:bunji/shared/ai/config/bunji_catalog_config.dart';
import 'package:bunji/shared/ai/models/bunji_model.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:equatable/equatable.dart';

class ModelsState extends Equatable {
  final UI ui;
  final String searchQuery;
  final String selectedTierFilter; // 'all', 'installed', 'fast', 'balanced', 'quality'

  // AI & Models
  final String selectedModelId;
  final List<BunjiModel> availableModels;
  final List<BunjiModel> installedModels;
  final String? downloadingModelId;
  final double downloadProgress;
  final String? downloadStatusMessage;
  final String? deletingModelId;
  final String responseStyle;
  final bool reasoningMode;
  final bool streamingResponses;

  // Catalog Diagnostics
  final bool isRefreshingCatalog;
  final String? catalogError;
  final String catalogSource; // 'Remote', 'Cache', 'Bundled'
  final String catalogVersion;
  final int catalogSchemaVersion;
  final String catalogStatus;
  final DateTime? catalogLastRefresh;
  final String catalogUrl;

  const ModelsState({
    required this.ui,
    this.searchQuery = '',
    this.selectedTierFilter = 'all',
    this.selectedModelId = 'qwen3_0_6b_q4_0',
    this.availableModels = const [],
    this.installedModels = const [],
    this.downloadingModelId,
    this.downloadProgress = 0.0,
    this.downloadStatusMessage,
    this.deletingModelId,
    this.responseStyle = 'Balanced',
    this.reasoningMode = false,
    this.streamingResponses = true,
    this.isRefreshingCatalog = false,
    this.catalogError,
    this.catalogSource = 'Bundled',
    this.catalogVersion = '2026-09-14',
    this.catalogSchemaVersion = 2,
    this.catalogStatus = 'Valid',
    this.catalogLastRefresh,
    this.catalogUrl = BunjiCatalogConfig.remoteUrl,
  });

  const ModelsState.initial()
      : ui = const UI(),
        searchQuery = '',
        selectedTierFilter = 'all',
        selectedModelId = 'qwen3_0_6b_q4_0',
        availableModels = const [],
        installedModels = const [],
        downloadingModelId = null,
        downloadProgress = 0.0,
        downloadStatusMessage = null,
        deletingModelId = null,
        responseStyle = 'Balanced',
        reasoningMode = false,
        streamingResponses = true,
        isRefreshingCatalog = false,
        catalogError = null,
        catalogSource = 'Bundled',
        catalogVersion = '2026-09-14',
        catalogSchemaVersion = 2,
        catalogStatus = 'Valid',
        catalogLastRefresh = null,
        catalogUrl = BunjiCatalogConfig.remoteUrl;

  /// Returns unique list of all displayable models (catalog + installed)
  List<BunjiModel> get displayModels {
    final list = <BunjiModel>[...availableModels];
    for (final inst in installedModels) {
      if (!list.any((m) => m.id == inst.id)) {
        list.add(inst);
      }
    }
    return list;
  }

  /// Filtered display models according to search query and tier filter
  List<BunjiModel> get filteredModels {
    return displayModels.where((m) {
      // 1. Tier / status filter
      if (selectedTierFilter == 'installed') {
        final isInstalled = installedModels.any((inst) => inst.id == m.id);
        if (!isInstalled) return false;
      } else if (selectedTierFilter == 'fast') {
        if (m.tier != BunjiModelTier.fast) return false;
      } else if (selectedTierFilter == 'balanced') {
        if (m.tier != BunjiModelTier.balanced) return false;
      } else if (selectedTierFilter == 'quality') {
        if (m.tier != BunjiModelTier.quality) return false;
      }

      // 2. Search query filter
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchesName = m.name.toLowerCase().contains(q);
        final matchesDesc = m.description.toLowerCase().contains(q);
        final matchesTier = m.tier.label.toLowerCase().contains(q);
        if (!matchesName && !matchesDesc && !matchesTier) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  BunjiModel? get activeModel {
    final all = displayModels;
    try {
      return all.firstWhere((m) => m.id == selectedModelId);
    } catch (_) {
      return all.isNotEmpty ? all.first : null;
    }
  }

  ModelsState copyWith({
    UI? ui,
    String? searchQuery,
    String? selectedTierFilter,
    String? selectedModelId,
    List<BunjiModel>? availableModels,
    List<BunjiModel>? installedModels,
    String? downloadingModelId,
    bool clearDownloadingModelId = false,
    double? downloadProgress,
    String? downloadStatusMessage,
    bool clearDownloadStatus = false,
    String? deletingModelId,
    bool clearDeletingModelId = false,
    String? responseStyle,
    bool? reasoningMode,
    bool? streamingResponses,
    bool? isRefreshingCatalog,
    String? catalogError,
    String? catalogSource,
    String? catalogVersion,
    int? catalogSchemaVersion,
    String? catalogStatus,
    DateTime? catalogLastRefresh,
    String? catalogUrl,
  }) {
    return ModelsState(
      ui: ui ?? this.ui,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTierFilter: selectedTierFilter ?? this.selectedTierFilter,
      selectedModelId: selectedModelId ?? this.selectedModelId,
      availableModels: availableModels ?? this.availableModels,
      installedModels: installedModels ?? this.installedModels,
      downloadingModelId: clearDownloadingModelId
          ? null
          : (downloadingModelId ?? this.downloadingModelId),
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadStatusMessage: clearDownloadStatus
          ? null
          : (downloadStatusMessage ?? this.downloadStatusMessage),
      deletingModelId: clearDeletingModelId
          ? null
          : (deletingModelId ?? this.deletingModelId),
      responseStyle: responseStyle ?? this.responseStyle,
      reasoningMode: reasoningMode ?? this.reasoningMode,
      streamingResponses: streamingResponses ?? this.streamingResponses,
      isRefreshingCatalog: isRefreshingCatalog ?? this.isRefreshingCatalog,
      catalogError: catalogError ?? this.catalogError,
      catalogSource: catalogSource ?? this.catalogSource,
      catalogVersion: catalogVersion ?? this.catalogVersion,
      catalogSchemaVersion: catalogSchemaVersion ?? this.catalogSchemaVersion,
      catalogStatus: catalogStatus ?? this.catalogStatus,
      catalogLastRefresh: catalogLastRefresh ?? this.catalogLastRefresh,
      catalogUrl: catalogUrl ?? this.catalogUrl,
    );
  }

  @override
  List<Object?> get props => [
        ui,
        searchQuery,
        selectedTierFilter,
        selectedModelId,
        availableModels,
        installedModels,
        downloadingModelId,
        downloadProgress,
        downloadStatusMessage,
        deletingModelId,
        responseStyle,
        reasoningMode,
        streamingResponses,
        isRefreshingCatalog,
        catalogError,
        catalogSource,
        catalogVersion,
        catalogSchemaVersion,
        catalogStatus,
        catalogLastRefresh,
        catalogUrl,
      ];
}
